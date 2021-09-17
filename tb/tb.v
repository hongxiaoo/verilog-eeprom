
module tb();

    parameter AWIDTH = 10;
    parameter SLV_ADDR = 7'b1010000;

    // Ports
    reg clk = 0;
    reg rst = 0;
    reg [AWIDTH-1:0] paddr;
    reg pwrite = 0;
    reg psel = 0;
    reg penable = 0;
    reg [31:0] pwdata;
    wire [31:0] prdata;
    wire pready;
    wire pslverr;
    wire i2c_SCL;
    wire i2c_SDA;
    reg [15:0] cfg_clock_divider = 100 * 1000000 / (100 * 1000);

    pullup(i2c_SCL);
    pullup(i2c_SDA);

    parameter ACK_PHASE = 8;

    always @(*)
    begin
        // Hack the i2c_SDA_i as iverilog can't resolve it
        if (u_apb_eeprom.u_i2c_master.bit_count == ACK_PHASE)
            force u_apb_eeprom.i2c_SDA_i = 1'b0;
        release u_apb_eeprom.i2c_SDA_i;
    end

    apb_eeprom
        #(
            .AWIDTH    (AWIDTH),
            .SLV_ADDR  (SLV_ADDR)
        )
        u_apb_eeprom(
            .clk               (clk               ),
            .rst               (rst               ),
            .paddr             (paddr             ),
            .pwrite            (pwrite            ),
            .psel              (psel              ),
            .penable           (penable           ),
            .pwdata            (pwdata            ),
            .prdata            (prdata            ),
            .pready            (pready            ),
            .pslverr           (pslverr           ),
            .i2c_SCL           (i2c_SCL           ),
            .i2c_SDA           (i2c_SDA           ),
            .cfg_clock_divider (cfg_clock_divider )
        );


    M24LC32A u_M24LC32A(
                 .A0    (1'b0    ),
                 .A1    (1'b0    ),
                 .A2    (1'b0    ),
                 .WP    (1'b0    ),
                 .SDA   (i2c_SDA   ),
                 .SCL   (i2c_SCL   ),
                 .RESET (rst )
             );

    // Cocotb Simulation
`ifdef COCOTB_SIM
`ifdef DUMP

    initial
    begin
        $dumpfile ("dump.vcd");
        $dumpvars (0, tb);
        #1;
    end
`endif
`endif

endmodule
