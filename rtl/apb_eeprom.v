///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name: EEPROM
// Module Name: apb_eeprom.v
//
// Author: Heqing Huang
// Date Created: 09/16/2021
//
// ================== Description ==================
//
// APB eeprom for 24LC32A/24AA32A
//
// We read/write 4 bytes at a time
//
///////////////////////////////////////////////////////////////////////////////

module apb_eeprom #(
        parameter AWIDTH = 10,
        parameter SLV_ADDR = 1
    )
    (
        input               clk,
        input               rst,
        // APB interface
        input [AWIDTH-1:0]  paddr,
        input               pwrite,
        input               psel,
        input               penable,
        input [31:0]        pwdata,
        output [31:0]       prdata,
        output              pready,
        output              pslverr,
        // I2C interface
        inout               i2c_SCL,
        inout               i2c_SDA,
        // CFG signal
        input [15:0]        cfg_clock_divider
    );

    ////////////////////////////////////////////
    // State Machine
    ////////////////////////////////////////////

    parameter   IDLE = 0,
                PUSH_CMD = 1,
                WAIT_DATA = 2,
                POP_DATA = 3,
                CMP_DATA = 4;

    ////////////////////////////////////////////
    // Signal Declaration
    ////////////////////////////////////////////

    wire        i2c_SDA_i;
    wire        i2c_SDA_e;
    wire        i2c_SDA_o;
    wire        i2c_SCL_i;
    wire        i2c_SCL_e;
    wire        i2c_SCL_o;

    wire        i2c_cmd_fifo_push;
    wire [9:0]  i2c_cmd_fifo_din;
    wire        i2c_cmd_fifo_full;
    wire        i2c_rxd_fifo_pop;
    wire [7:0]  i2c_rxd_fifo_dout;
    wire        i2c_rxd_fifo_empty;
    wire        i2c_rxd_cmp;
    wire [3:0]  i2c_rxd_cnt;
    wire        i2c_txd_cmp;
    wire        i2c_addr_noack_err;
    wire        i2c_data_noack_err;

    reg [3:0]   state;
    reg [3:0]   state_next;

    wire        start;

    wire        wait_data_done;
    wire        pop_data_done;
    wire [6:0]  slv_addr;
    wire [7:0]  addr_high;
    wire [7:0]  addr_low;
    wire        push_cmd_done;

    reg         pwrite_q;
    reg [31:0]  pwdata_q;
    reg [AWIDTH-1:0] paddr_q;
    reg [3:0]   cmd_cnt_q;
    reg [31:0]  pop_data_q;
    reg [2:0]   pop_cnt_q;
    reg         nak_err_q;

    ////////////////////////////////////////////
    // I2C Master
    ////////////////////////////////////////////

    assign i2c_SDA_i = i2c_SDA;
    assign i2c_SDA   = i2c_SDA_e ? i2c_SDA_o : 1'bz;
    assign i2c_SCL_i = i2c_SCL;
    assign i2c_SCL   = i2c_SCL_e ? i2c_SCL_o : 1'bz;

    i2c_master
        #(
            .CMD_FIFO_DEPTH(8),
            .RXD_FIFO_DEPTH(4),
            .MAX_RXD_CNT(4)
        )
        i2c_master_dut (
            .clk (clk),
            .rst (rst),
            .cfg_clock_divider  (cfg_clock_divider),
            .i2c_cmd_fifo_push  (i2c_cmd_fifo_push),
            .i2c_cmd_fifo_din   (i2c_cmd_fifo_din),
            .i2c_cmd_fifo_full  (i2c_cmd_fifo_full),
            .i2c_rxd_fifo_pop   (i2c_rxd_fifo_pop),
            .i2c_rxd_fifo_dout  (i2c_rxd_fifo_dout),
            .i2c_rxd_fifo_empty (i2c_rxd_fifo_empty),
            .i2c_rxd_cmp        (i2c_rxd_cmp),
            .i2c_rxd_cnt        (i2c_rxd_cnt),
            .i2c_txd_cmp        (i2c_txd_cmp),
            .i2c_SDA_i          (i2c_SDA_i),
            .i2c_SDA_e          (i2c_SDA_e),
            .i2c_SDA_o          (i2c_SDA_o),
            .i2c_SCL_i          (i2c_SCL_i),
            .i2c_SCL_e          (i2c_SCL_e),
            .i2c_SCL_o          (i2c_SCL_o),
            .i2c_addr_noack_err (i2c_addr_noack_err),
            .i2c_data_noack_err (i2c_data_noack_err)
        );

    ////////////////////////////////////////////
    // Control State machine
    ////////////////////////////////////////////

    assign start = psel & penable & pready;
    assign wait_data_done = i2c_rxd_cmp;

    always @(posedge clk) begin
        if (start) begin
            pwrite_q <= pwrite;
            pwdata_q <= pwdata;
            paddr_q <= paddr;
        end
    end

    always @(posedge clk) begin
        if (start) begin
            nak_err_q <= 1'b0;
        end
        else if (i2c_addr_noack_err || i2c_data_noack_err) begin
            nak_err_q <= 1'b1;
        end
    end

    always @(*)
    begin
        state_next = state;
        case(state)
            IDLE:
            begin
                if (start)
                begin
                    state_next = PUSH_CMD;
                end
            end
            PUSH_CMD:
            begin
                if (push_cmd_done)
                begin
                    state_next = WAIT_DATA;
                end
            end
            WAIT_DATA:
            begin
                if (wait_data_done)
                begin
                    state_next = POP_DATA;
                end
            end
            POP_DATA:
            begin
                if (pop_data_done)
                begin
                    state_next = CMP_DATA;
                end
            end
            CMP_DATA:
            begin
                state_next = IDLE;
            end
        endcase
    end

    always @(posedge clk)
    begin
        if (rst)
        begin
            state <= IDLE;
        end
        else
        begin
            state <= state_next;
        end
    end

    ////////////////////////////////////////////
    // PUSH CMD
    ////////////////////////////////////////////

    assign slv_addr = SLV_ADDR;
    assign addr_high = {{(16-AWIDTH){1'b0}}, paddr_q[AWIDTH-1:8]};
    assign addr_low = paddr_q[7:0];
    assign push_cmd_done = (cmd_cnt_q == 7);

    always @(posedge clk) begin
        if (rst) begin
            cmd_cnt_q <= 'b0;
        end
        else if (push_cmd_done) begin
            cmd_cnt_q <= 'b0;
        end
        else if (state == PUSH_CMD) begin
            cmd_cnt_q <= cmd_cnt_q + 1'b1;
        end
    end

    always @(*)
    begin
        i2c_cmd_fifo_push = 1'b0;
        if (state == PUSH_CMD)
        begin
            i2c_cmd_fifo_push = ~(pwrite_q & (cmd_cnt_q == 3));   // for write operation, don't push cmd 3
            i2c_cmd_fifo_din = 0;
            case(cmd_cnt_q)
                0:
                    i2c_cmd_fifo_din = {1'b1, 1'b0, slv_addr, 0};        // control byte with start
                1:
                    i2c_cmd_fifo_din = {1'b0, 1'b0, addr_high};          // Address High Byte
                2:
                    i2c_cmd_fifo_din = {1'b0, 1'b0, addr_low};           // Address Low Byte
                3:
                    i2c_cmd_fifo_din = {1'b1, 1'b0, slv_addr, 1};        // control byte with start - for read only
                4:
                    i2c_cmd_fifo_din = {1'b0, 1'b0, pwdata_q[31:24]};    // Data Byte 3 - MSB goest first
                5:
                    i2c_cmd_fifo_din = {1'b0, 1'b0, pwdata_q[23:16]};    // Data Byte 2
                6:
                    i2c_cmd_fifo_din = {1'b0, 1'b0, pwdata_q[15:8]};     // Data Byte 1
                7:
                    i2c_cmd_fifo_din = {1'b0, 1'b1, pwdata_q[7:0]};      // Data Byte 0 with stop
            endcase
        end
    end

    ////////////////////////////////////////////
    // POP DATA
    ////////////////////////////////////////////

    assign pop_data_done = pop_cnt_q == 3;

    always @(posedge clk)
    begin
        if (rst)
        begin
            pop_cnt_q <= 'b0;
        end
        else
        begin
            if (state == POP_DATA)
            begin
                if (pop_data_done)
                    pop_cnt_q <= 0;
                else
                    pop_cnt_q <= pop_cnt_q + 1'b1;
            end
        end
    end

    always @(posedge clk)
    begin
        if (state == POP_DATA)
        begin
            case(pop_cnt_q)
                0:
                    pop_data_q[31:24] <= i2c_rxd_fifo_dout;
                1:
                    pop_data_q[23:16] <= i2c_rxd_fifo_dout;
                2:
                    pop_data_q[15:8]  <= i2c_rxd_fifo_dout;
                3:
                    pop_data_q[7:0]   <= i2c_rxd_fifo_dout;
            endcase
        end
    end


    ////////////////////////////////////////////
    // APB Signal
    ////////////////////////////////////////////

    assign prdata = pop_data_q;
    assign pready = state == IDLE || state == CMP_DATA;
    assign pslverr = nak_err_q;

endmodule
