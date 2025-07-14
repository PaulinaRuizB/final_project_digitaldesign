module lookup_table (
    input  wire [7:0] vel_onehot,
    output reg  [31:0] T_value
);

    always @(*) begin
        case (vel_onehot)
            8'b00000001: T_value = 32'd125000; // velocidad 0 → 400 Hz
            8'b00000010: T_value = 32'd62500;  // velocidad 1 → 800 Hz
            8'b00000100: T_value = 32'd31250;  // velocidad 2 → 1.6 kHz
            8'b00001000: T_value = 32'd20833;  // velocidad 3 → 2.4 kHz
            8'b00010000: T_value = 32'd15625;  // velocidad 4 → 3.2 kHz
            8'b00100000: T_value = 32'd12500;  // velocidad 5 → 4.0 kHz
            8'b01000000: T_value = 32'd8929;   // velocidad 6 → 5.6 kHz
            8'b10000000: T_value = 32'd7813;   // velocidad 7 → 6.4 kHz
            default:     T_value = 32'd0;       // default o error
        endcase
    end

endmodule