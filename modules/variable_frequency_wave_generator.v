module variable_frequency_wave_generator (
    // Inputs
    input wire         clk,
    input wire         rst, // Active-low asynchronous reset
    input wire [31:0]  T_value,

    // Output
    output reg [2:0]   output_val
);

    // Internal registers for the two counters
    reg [31:0] main_counter;   // This counter increments on every clock edge up to T_value
    reg [5:0]  state_counter;  // This counter increments from 0-47 when the main_counter wraps

    // --- Sequential Logic Block ---
    // This block describes the behavior of the counters on each clock edge.
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset counters to zero if rst is asserted (low)
            main_counter  <= 32'd0;
            state_counter <= 6'd0;
        end
        else begin
            // Check if the main counter has reached its target value
            if (main_counter >= T_value) begin
                main_counter <= 32'd0; // Reset the main counter

                // Increment the state counter, wrapping from 47 back to 0
                if (state_counter == 6'd47) begin
                    state_counter <= 6'd0;
                end
                else begin
                    state_counter <= state_counter + 1;
                end
            end
            else begin
                // If the target is not reached, just increment the main counter
                main_counter <= main_counter + 1;
            end
        end
    end

    // --- Combinational Logic Block ---
    // This block determines the output value based on the current state of the state_counter.
    // It uses a priority-encoded if-else structure, which is efficient for synthesis.
    always @(*) begin
        if (state_counter <= 7) begin
            output_val = 3'b110;
        end
        else if (state_counter <= 15) begin
            output_val = 3'b100;
        end
        else if (state_counter <= 23) begin
            output_val = 3'b101;
        end
        else if (state_counter <= 31) begin
            output_val = 3'b001;
        end
        else if (state_counter <= 39) begin
            output_val = 3'b011;
        end
        else begin // Covers states from 40 to 47
            output_val = 3'b010;
        end
    end

endmodule
