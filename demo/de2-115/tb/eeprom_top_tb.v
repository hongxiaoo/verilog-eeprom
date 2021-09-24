module eeprom_top_tb;

    // Parameters
    localparam  IDLE = 1;
    localparam  SLV_ADDR = 1;
    localparam  CLK_DIV = 1;
    localparam  AWIDTH = 10;

    // Ports
    reg clk = 0;
    reg rst_n = 1;
    reg [7:0] addr;
    reg [7:0] data;
    reg read_n = 1;
    reg write_n = 1;
    wire [15:0] display;
    wire complete;
    wire i2c_SCL;
    wire i2c_SDA;

    pullup(i2c_SCL);
    pullup(i2c_SDA);

    eeprom_top eeprom_top_dut (
                   .clk (clk ),
                   .rst_n (rst_n ),
                   .addr (addr ),
                   .data (data ),
                   .read_n (read_n ),
                   .write_n (write_n ),
                   .display (display ),
                   .complete (complete),
                   .i2c_SCL (i2c_SCL ),
                   .i2c_SDA  ( i2c_SDA)
               );

    M24LC32A u_M24LC32A(
                 .A0    (1'b0    ),
                 .A1    (1'b0    ),
                 .A2    (1'b0    ),
                 .WP    (1'b0    ),
                 .SDA   (i2c_SDA   ),
                 .SCL   (i2c_SCL   ),
                 .RESET (~rst_n )
             );

    // Cocotb Simulation
`ifdef COCOTB_SIM
`ifdef DUMP

    initial
    begin
        $dumpfile ("dump.vcd");
        $dumpvars (0, eeprom_top_tb);
        #1;
    end
`endif
`endif

endmodule
