module lookup_table (
    input  wire [2:0] vel_index,
    output reg  [31:0] T_value
);

    always @(*) begin
        case (vel_index)
            3'd0: T_value = 32'd125000;  // 400 Hz
            3'd1: T_value = 32'd62500;   // 800 Hz
            3'd2: T_value = 32'd31250;   // 1.6 kHz
            3'd3: T_value = 32'd20833;   // 2.4 kHz
            3'd4: T_value = 32'd15625;   // 3.2 kHz
            3'd5: T_value = 32'd12500;   // 4.0 kHz
            3'd6: T_value = 32'd8929;    // 5.6 kHz
            3'd7: T_value = 32'd7813;    // 6.4 kHz
        endcase
    end

endmodule