module lookup_table (
    input  wire [7:0] vel_onehot,
    output reg  [31:0] T_value
);

    always @(*) begin
        case (vel_onehot)
            8'b00000001: T_value = 32'd2603;    // velocidad 0 → 400 Hz
            8'b00000010: T_value = 32'd1301;    // velocidad 1 → 800 Hz
            8'b00000100: T_value = 32'd650;     // velocidad 2 → 1.6 kHz
            8'b00001000: T_value = 32'd433;     // velocidad 3 → 2.4 kHz
            8'b00010000: T_value = 32'd325;     // velocidad 4 → 3.2 kHz
            8'b00100000: T_value = 32'd259;     // velocidad 5 → 4.0 kHz
            8'b01000000: T_value = 32'd185;     // velocidad 6 → 5.6 kHz
            8'b10000000: T_value = 32'd162;     // velocidad 7 → 6.4 kHz
            default:     T_value = 32'd0;       // default o error
        endcase
    end

endmodule
