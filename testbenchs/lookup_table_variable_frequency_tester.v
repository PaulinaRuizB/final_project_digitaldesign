`timescale 1ns / 1ns

// Top-level module to connect the LUT and the wave generator
module lookup_table_variable_frequency_tester (
    input  wire        clk,
    input  wire        rst_n,        // Active-low reset
    input  wire [7:0]  vel_onehot,   // One-hot velocity input for the LUT
    output wire [2:0]  output_val    // Final 3-bit output
);

    // Internal wire to connect the two modules
    wire [31:0] t_value_internal;

    // Instantiate the lookup table
    // It takes the one-hot velocity and outputs a corresponding T_value.
    lookup_table lut_inst (
        .vel_onehot(vel_onehot),
        .T_value(t_value_internal)
    );

    // Instantiate the wave generator
    // It uses the T_value from the LUT to generate the output wave.
    variable_frequency_wave_generator wave_gen_inst (
        .clk(clk),
        .rst(rst_n), // Note the connection to rst_n
        .T_value(t_value_internal),
        .output_val(output_val)
    );

endmodule
`timescale 1ns / 1ps


module testbench;

// --- Testbench Signal Declarations ---
reg         clk;
reg         rst_n;
reg  [7:0]  vel_onehot;
wire [2:0]  output_val;

// --- Instantiate the Device Under Test (DUT) ---
// Note: We are testing the integrated top-level module.
lookup_table_variable_frequency_tester dut (
    .clk(clk),
    .rst_n(rst_n),
    .vel_onehot(vel_onehot),
    .output_val(output_val)
);

// --- Clock Generation ---
// Generate a clock with a 10ns period (100 MHz).
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// --- Test Sequence ---
initial begin
    // --- VCD Dump Setup ---
    $dumpfile("vcd_results/lookup_table_variable_frequency_tester.vcd");
    $dumpvars(0, testbench); // Dump all variables in this testbench and below

    $display("--------------------------------------------------");
    $display("Simulation Started at %0t ns.", $time);
    $display("--------------------------------------------------");

    // --- Initial Reset ---
    // Apply an active-low reset pulse to start in a known state.
    rst_n      = 1'b0; // Assert reset
    vel_onehot = 8'b0;
    #20; // Hold reset for 2 clock cycles
    rst_n      = 1'b1; // De-assert reset
    $display("[%0t ns] Initial reset released.", $time);


    // --- TEST ALL VALID ONE-HOT INPUTS ---
    // This loop iterates through all 8 valid speeds.
    for (integer i = 7; i > 0; i = i - 1) begin
        vel_onehot = 1 << i; // Shift '1' to create 8'b00000001, 8'b00000010, etc.
        $display("\n--- Test Case %d: Testing vel_onehot = %b ---", i + 1, vel_onehot);

        // Wait long enough to observe at least one state counter increment.
        // For the slowest speed (T_value=125000), this takes a while.
        // We will wait a shorter, fixed time for demonstration.
        // To see a state change for the slowest speed, you would need to wait
        // at least (125000 + 1) * 10 ns = 1,250,010 ns.
        #500000; // Let simulation run for 5000 ns (500 clock cycles) for each speed.
    end


    // --- TEST THE DEFAULT/ERROR CASE ---
    $display("\n--- Test Case 9: Testing Default/Error case (vel_onehot = 0) ---");
    vel_onehot = 8'b0; // This is not a valid one-hot code
    #1; // Allow value to propagate
    $display("Expected behavior: T_value should be 0, causing state_counter to increment every cycle.");
    #1000; // Run for 100 cycles to observe rapid state changes.


    // --- End Simulation ---
    $display("\n--------------------------------------------------");
    $display("All tests completed. Finishing simulation at %0t ns.", $time);
    $display("--------------------------------------------------");
    $finish;
end

// --- Monitor Block ---
// This block will print values whenever a signal changes.
// It allows us to "peek" inside the DUT using hierarchical names to see the internal T_value.
initial begin
    $monitor(
        "[%0t ns] rst_n=%b | vel_onehot=%b | T_value=%d | main_cnt=%d | state_cnt=%d | output_val=%3b",
        $time, rst_n, vel_onehot, dut.t_value_internal, dut.wave_gen_inst.main_counter, dut.wave_gen_inst.state_counter, output_val
    );
end

endmodule
