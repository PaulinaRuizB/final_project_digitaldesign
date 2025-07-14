`timescale 1ns/1ps
module tb_bldc_registers_lookup_combo;

    reg         clk, rst;
    reg         write, read;
    reg  [0:0]  addr;
    reg  [31:0] data_in;
    wire [31:0] data_out;
    wire [7:0]  vel, duty;
    wire        en;
    reg  [2:0]  phase_state;
    wire [31:0] T;

    // Clock 50 MHz
    always #10 clk = ~clk;

    // Instancias
    bldc_registers regs (
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

    lookup_table lut (
        .vel_index(vel[2:0]),
        .T_value(T)
    );

    // Variables auxiliares
    integer v, d;
    reg [7:0] vel_fixed = 8'd3;
    reg       en_fixed  = 1'b1;

    initial begin
        $dumpfile("tb_bldc_registers.vcd");
        $dumpvars(0, tb_bldc_registers_lookup_combo);

        clk = 0;
        rst = 1;
        write = 0;
        read = 0;
        addr = 0;
        data_in = 32'd0;
        phase_state = 3'b011;

        #40 rst = 0;

        // PWM test: velocidad fija, duty variable
        for (d = 0; d < 4; d = d + 1) begin
            #40;
            addr = 0;
            data_in = 32'd0;
            data_in[31:24] = vel_fixed;
            data_in[23:16] = d * 64;
            data_in[15]    = en_fixed;
            write = 1;
            #20 write = 0;

            addr = 1;
            read = 1;
            #20 read = 0;

            $display("PWM -> vel = %0d, duty = %0d, T = %0d", vel, duty, T);
            $display("data_out = %h | vel = %0d, duty = %0d, en = %b",
                      data_out, data_out[31:24], data_out[23:16], data_out[15]);
        end

        // FSM test: duty fijo, velocidad variable
        for (v = 0; v < 8; v = v + 1) begin
            #40;
            addr = 0;
            data_in = 32'd0;
            data_in[31:24] = v[7:0];
            data_in[23:16] = 8'd128;
            data_in[15]    = en_fixed;
            write = 1;
            #20 write = 0;

            addr = 1;
            read = 1;
            #20 read = 0;

            $display("FSM -> vel = %0d, duty = %0d, T = %0d", vel, duty, T);
            $display("data_out = %h | vel = %0d, duty = %0d, en = %b",
                      data_out, data_out[31:24], data_out[23:16], data_out[15]);
        end

        #100 $finish;
    end

endmodule