module pwm_generator (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire [7:0]  duty,     // Duty cycle 0-255
    output reg         pwm_out
);

    // Frecuencia fija (ejemplo: 20 kHz con clk = 50 MHz)
    localparam integer PWM_PERIOD = 2500;

    reg [11:0] counter;         // Suficiente para contar hasta 2500
    wire [11:0] threshold;       // Umbral calculado con duty
    assign threshold = (PWM_PERIOD * duty) >> 8;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 12'd0;
            pwm_out <= 1'b0;
        end else if (en) begin
            // Contador principal
            if (counter >= PWM_PERIOD - 1)
                counter <= 12'd0;
            else
                counter <= counter + 1;

            // Comparación para activar salida PWM
            pwm_out <= (counter < threshold);
        end else begin
            counter <= 12'd0;
            pwm_out <= 1'b0;
        end
    end
endmodule
