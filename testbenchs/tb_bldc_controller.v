`timescale 1ns / 1ns

module tb_bldc_controller;

    reg clk, rst, write, read;
    reg [0:0] addr;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire [2:0] output_combined;

    // Instantiate the DUT
    bldc_controller uut (
        .clk(clk),
        .rst(rst),
        .write(write),
        .read(read),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out),
        .output_combined(output_combined)
    );

    // Clock generation
    initial clk = 0;
    always #10 clk = ~clk;  // 50 MHz clock

    initial begin
        $dumpfile("vcd_results/tb_bldc_controller.vcd");
        $dumpvars(0, tb_bldc_controller);
        // Initialize
        rst = 0;
        write = 0;
        read = 0;
        addr = 0;
        data_in = 0;

        // Hold reset
        #30;
        rst = 1;
        #30;
        rst = 0;
        #30

        // Write to CONFIG register: vel=6, duty=128 (50%), en=1
        addr = 0;
        data_in = {8'b00001000, 8'd128, 1'b1, 15'd0}; // vel=2 (1.6 kHz), duty=50%
        write = 1;
        #30;
        write = 0;

        // Read from OUT register
        #30;
        addr = 1;
        read = 1;
        #30;
        read = 0;

        // Let simulation run
        #250000;

        // Write to CONFIG register: vel=6, duty=128 (50%), en=0
        addr = 0;
        data_in = {8'b01000000, 8'd128, 1'b0, 15'd0}; // vel=2 (1.6 kHz), duty=50%
        write = 1;
        #30;
        write = 0;

        // Let simulation run
        #50000;

        // Write to CONFIG register: vel=6, duty=200 (78%), en=1
        addr = 0;
        data_in = {8'b10000000, 8'd200, 1'b1, 15'd0}; // vel=2 (1.6 kHz), duty=50%
        write = 1;
        #30;
        write = 0;

        #250000;
        // Read from OUT register
        #30;
        addr = 1;
        read = 1;
        #30;
        read = 0;

        // Write to CONFIG register: vel=NOT VALID, duty=128 (50%), en=1
        addr = 0;
        data_in = {8'b10100000, 8'd128, 1'b1, 15'd0}; // vel=2 (1.6 kHz), duty=50%
        write = 1;
        #30;
        write = 0;

        #25000;
        // Read from OUT register
        #30;
        addr = 1;
        read = 1;
        #30;
        read = 0;

        #25000;

        $finish;
    end

endmodule
