`timescale 1ns / 1ps

module bldc_tb;
    reg clk = 0;
    reg rst = 1;
    reg write = 0;
    reg read = 0;
    reg [0:0] addr = 0;
    reg [31:0] data_in;
    reg [2:0] phase_state = 3'b000;
    wire [31:0] data_out;
    wire [7:0] vel, duty;
    wire en;

    wire pwm_out;

    // Clock generation
    always #5 clk = ~clk; // 100MHz

    // Instantiate registers
    bldc_registers uut (
        .clk(clk),
        .rst(rst),
        .write(write),
        .read(read),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out),
        .vel(vel),
        .duty(duty),
        .en(en),
        .phase_state(phase_state)
    );

    // Instantiate PWM generator
    pwm_generator pwm_inst (
        .en(en),
        .clk(clk),
        .rst(rst),
        .duty(duty),
        .pwm_out(pwm_out)
    );

    initial begin
        $dumpfile("vcd_results/tb_bldc_pwm.vcd");
        $dumpvars(0, bldc_tb);

        // Initial Reset
        #10 rst = 0;

        // -------------------------------------
        // Test case 1: duty = 64 (25%), en = 1
        // -------------------------------------
        addr     = 0;
        data_in  = {8'd100, 8'd64, 1'b1, 15'd0}; // vel=100, duty=64, en=1
        write    = 1;
        #10 write = 0;

        // Read OUT
        addr  = 1;
        read  = 1;
        #10 read = 0;

        // Wait to observe PWM for 200ns
        #500000;

        // -------------------------------------
        // Test case 2: duty = 128 (50%), en = 1
        // -------------------------------------
        addr     = 0;
        data_in  = {8'd100, 8'd128, 1'b1, 15'd0}; // vel=100, duty=128, en=1
        write    = 1;
        #10 write = 0;

        addr = 1;
        read = 1;
        #10 read = 0;

        #500000;

        // -------------------------------------
        // Test case 3: duty = 192 (75%), en = 1
        // -------------------------------------
        addr     = 0;
        data_in  = {8'd100, 8'd192, 1'b1, 15'd0}; // vel=100, duty=192, en=1
        write    = 1;
        #10 write = 0;

        addr = 1;
        read = 1;
        #10 read = 0;

        #500000

        $finish;
    end
endmodule
