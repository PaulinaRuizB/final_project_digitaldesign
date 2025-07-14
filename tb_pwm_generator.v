`timescale 1ns/1ps

module tb_pwm_generator;

    // Señales del DUT
    reg clk;
    reg rst;
    reg en;
    reg [7:0] duty;
    wire pwm_out;

    // Instancia del DUT
    pwm_generator dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .duty(duty),
        .pwm_out(pwm_out)
    );

    // Reloj de 50 MHz => periodo de 20 ns
    initial clk = 0;
    always #10 clk = ~clk;  // 20 ns periodo

    // Secuencia de prueba
    initial begin
        // Dump de señales si usas GTKWave
        $dumpfile("pwm_generator_tb.vcd");
        $dumpvars(0, tb_pwm_generator);

        // Inicialización
        rst = 1;
        en  = 0;
        duty = 8'd0;
        #100;        // Esperar 100 ns

        rst = 0;
        en  = 1;

        // Prueba con 25% duty
        duty = 8'd64;
        #500000;     // 100 us

        // Prueba con 50% duty
        duty = 8'd128;
        #500000;     // 100 us

        // Prueba con 75% duty
        duty = 8'd192;
        #500000;     // 100 us

        // Apagar PWM
        en = 0;
        #50000;      // 50 us

        $finish;
    end

endmodule

