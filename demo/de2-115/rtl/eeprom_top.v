///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name: EEPROM
// Module Name: eeprom_top.v
//
// Author: Heqing Huang
// Date Created: 09/21/2021
//
// ================== Description ==================
//
// EEPROM FPGA Demo
//
///////////////////////////////////////////////////////////////////////////////

module eeprom_top (
        input           clk,
        input           rst_n,
        input [7:0]     addr,
        input [7:0]     data,
        input           read_n,
        input           write_n,
        output [15:0]   display,
        output          complete,
        inout           i2c_SCL,
        inout           i2c_SDA
    );

    ///////////////////////////////////
    // State machine and parameter
    ///////////////////////////////////
    parameter IDLE = 0,
              READ = 1,
              WRITE = 2;

    parameter SLV_ADDR = 'h50;

    // cfg_clock_divider = CLK FEQ (in MHz) * 1000000 / (I2C CLK FRQ (in KHz) * 1000)
    parameter CLK_DIV = 100 * 1000000 / (100 * 1000);

    parameter AWIDTH = 10;


    ///////////////////////////////////
    // Signal Declaration
    ///////////////////////////////////

    wire                rst;

    reg [2:0]           ctrl_state;
    reg [2:0]           ctrl_state_next;

    wire [AWIDTH-1:0]   paddr;
    wire                pwrite;
    wire                psel;
    wire                penable;
    wire [31:0]         pwdata;
    wire [31:0]         prdata;
    wire                pready;
    wire                pslverr;

    wire                read;
    wire                write;

    ///////////////////////////////////
    // Logic
    ///////////////////////////////////

    // reset
    assign rst = ~rst_n;
    assign read = ~read_n;
    assign write = ~write_n;

    // state machine logic
    always @(posedge clk)
    begin
        if (rst)
            ctrl_state <= IDLE;
        else
            ctrl_state <= ctrl_state_next;
    end


    always @(*)
    begin
        ctrl_state_next = ctrl_state;
        case(ctrl_state)
            IDLE:
            begin
                if (read)
                    ctrl_state_next = READ;
                else if (write)
                    ctrl_state_next = WRITE;
            end
            READ:
            begin
                if (pready)
                    ctrl_state_next = IDLE;
            end
            WRITE:
            begin
                if (pready)
                    ctrl_state_next = IDLE;
            end
        endcase
    end

    // Output function logic
    assign paddr  = {{(AWIDTH-8){1'b0}}, addr};
    assign pwdata = {4{data}};
    assign pwrite = ((ctrl_state == IDLE) & write) | (ctrl_state == WRITE);
    assign penable = ((ctrl_state == IDLE) & (read | write)) | (ctrl_state != IDLE);
    assign psel = penable;
    assign display = {prdata[31:24], prdata[7:0]};
    assign complete = (ctrl_state != IDLE) & pready;

    ///////////////////////////////////
    // Sub-module Instantiation
    ///////////////////////////////////

    apb_eeprom
        #(
            .AWIDTH    (AWIDTH),
            .SLV_ADDR  (SLV_ADDR)
        )
        u_apb_eeprom(
            .clk               (clk),
            .rst               (rst),
            .paddr             (paddr),
            .pwrite            (pwrite),
            .psel              (psel),
            .penable           (penable),
            .pwdata            (pwdata),
            .prdata            (prdata),
            .pready            (pready),
            .pslverr           (pslverr),
            .i2c_SCL           (i2c_SCL),
            .i2c_SDA           (i2c_SDA),
            .cfg_clock_divider (CLK_DIV)
        );

endmodule
