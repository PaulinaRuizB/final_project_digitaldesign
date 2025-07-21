`timescale 1ns / 1ps

module tb_variable_frequency_wave_generator;

// --- Testbench Signal Declarations ---
reg         clk;
reg         rst;
reg [31:0]  T_value;
wire [2:0]  output_val;

// --- Instantiate the Device Under Test (DUT) ---
variable_frequency_wave_generator dut (
    .clk(clk),
    .rst(rst),
    .T_value(T_value),
    .output_val(output_val)
);

// --- Clock Generation ---
// Generate a clock with a 10ns period.
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// --- Test Sequence ---
initial begin
    // --- VCD Dump Setup ---
    // This will create a waveform file for analysis in a viewer like GTKWave.
    $dumpfile("vcd_results/tb_variable_frequency_wave_generator.vcd");
    $dumpvars(0); // Dump all signals in the design hierarchy

    $display("--------------------------------------------------");
    $display("Simulation Started. VCD dumping is enabled.");
    $display("--------------------------------------------------");

    // Initialize inputs and apply reset
    rst = 1'b0;
    T_value = 32'd0;
    #20;
    rst = 1'b1;
    $display("[%0t ns] Initial reset released.", $time);
    #5;

    // --- TEST CASE 1: T_value = 0 ---
    $display("\n--- TEST 1: T_value = 0 ---");
    $display("State counter should increment every clock cycle.");
    T_value = 32'd0;
    #1;
    repeat (150) @(posedge clk);
    $display("[%0t ns] Test 1 complete.", $time);

    // --- TEST CASE 2: T_value = 10 ---
    $display("\n--- TEST 2: T_value = 10 ---");
    $display("State counter should increment every 11 clock cycles.");
    T_value = 32'd10;
    #1;
    repeat (3500) @(posedge clk);
    $display("[%0t ns] Test 2 complete.", $time);

    // --- TEST CASE 3: Mid-operation Reset ---
    $display("\n--- TEST 3: Mid-operation Reset Test ---");
    $display("Running with T_value=50, then asserting reset.");
    T_value = 32'd50;
    #80;
    $display("[%0t ns] Asserting reset (rst=0).", $time);
    rst = 1'b0;
    #20;
    $display("[%0t ns] Releasing reset (rst=1). Counters should be zero.", $time);
    rst = 1'b1;
    #20;
    $display("[%0t ns] Test 3 complete.", $time);

    // --- TEST CASE 4: T_value = 1 (High Frequency) ---
    $display("\n--- TEST 4: T_value = 1 ---");
    $display("State counter should increment every 2 clock cycles.");
    T_value = 32'd1;
    #1;
    repeat (20) @(posedge clk);
    $display("[%0t ns] Test 4 complete.", $time);

    // --- TEST CASE 5: Changing T_value On-the-Fly ---
    $display("\n--- TEST 5: Changing T_value On-the-Fly ---");
    T_value = 32'd1000;
    #1;
    $display("[%0t ns] Set T_value=1000. Running for 60ns.", $time);
    #90; // main_counter will be at 6
    $display("[%0t ns] Changing T_value to 5 (a value already passed).", $time);
    T_value = 32'd5;
    #1;
    $display("Expected: The counter will reset back to 0, avoiding to follow counting higher.");
    repeat (500) @(posedge clk);
    $display("[%0t ns] Test 5 complete.", $time);

    // End simulation
    $display("\n--------------------------------------------------");
    $display("All tests completed. Finishing simulation.");
    $display("--------------------------------------------------");
    $finish;
end

endmodule
