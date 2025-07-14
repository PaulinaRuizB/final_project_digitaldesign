module bldc_registers (
    input  wire        clk,
    input  wire        rst,
    input  wire        write,
    input  wire        read,
    input  wire [0:0]  addr,       // 0: CONFIG, 1: OUT
    input  wire [31:0] data_in,
    output reg  [31:0] data_out,
    output wire [7:0]  vel,
    output wire [7:0]  duty,
    output wire        en,
    input  wire [2:0]  phase_state // desde FSM externa
);

    // -----------------------------
    // Registros internos
    // -----------------------------
    reg [7:0] vel_reg;
    reg [7:0] duty_reg;
    reg       en_reg;

    // -----------------------------
    // Escritura sincrónica
    // -----------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            vel_reg  <= 8'd0;
            duty_reg <= 8'd0;
            en_reg   <= 1'b0;
        end else if (write && addr == 1'b0) begin // CONFIG
            vel_reg  <= data_in[31:24];
            duty_reg <= data_in[23:16];
            en_reg   <= data_in[15];
        end
    end

    // -----------------------------
    // Lectura sincrónica (registrada)
    // -----------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 32'd0;
        end else if (read && addr == 1'b1) begin // OUT
            data_out <= {
                vel_reg,         // [31:24]
                duty_reg,        // [23:16]
                en_reg,          // [15]
                1'b0,            // padding
                phase_state,     // [13:11]
                11'd0            // padding
            };
        end
    end

    // -----------------------------
    // Conexiones de salida
    // -----------------------------
    assign vel  = vel_reg;
    assign duty = duty_reg;
    assign en   = en_reg;

endmodule