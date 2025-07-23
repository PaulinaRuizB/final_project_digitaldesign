module bldc_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire        write,
    input  wire        read,
    input  wire [31:0]  addr,
    input  wire [31:0] data_in,
    output wire [31:0] data_out,
    output wire [2:0]  output_combined
);

    // Internal signals
    wire [7:0] vel;
    wire [7:0] duty;
    wire [2:0] phase_state; // From FSM (external input for bldc_registers)
    wire [31:0] T_value;
    wire pwm_out;
    wire [2:0] output_val;
    wire rst_n;


    // --- Phase State (placeholder for integration with external FSM) ---
    assign phase_state = output_val; // Connect output of wave gen to phase state input

    assign rst_n = ~ rst;

    // -----------------------------
    // Module Instantiations
    // -----------------------------

    bldc_registers u_registers (
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

    lookup_table u_lookup (
        .vel_onehot(vel),
        .T_value(T_value)
    );

    variable_frequency_wave_generator u_wavegen (
        .clk(clk & T_value!=8'd0),
        .rst(rst_n),
        .T_value(T_value),
        .output_val(output_val)
    );

    pwm_generator u_pwm (
        .clk(clk),
        .rst(rst),
        .en(en),
        .duty(duty),
        .pwm_out(pwm_out)
    );

    assign output_combined = {3 {pwm_out}} & phase_state & {3{en}} & {3{T_value!=8'b0}};

endmodule
