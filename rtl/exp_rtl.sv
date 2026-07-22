module exp_rtl #(
    parameter integer DATA_WIDTH = `DATA_WIDTH,
    parameter integer FRAC_BITS  = `FRAC_BITS
)(
    input  logic signed [DATA_WIDTH-1:0] x_IntFrac,
    input  logic                         clk,
    input  logic                         rst_n,
    output logic signed [DATA_WIDTH-1:0] exp_x
);

    // Slicing input x_IntFrac into integer and fraction parts
    // x_IntFrac    = x_IntPart_w + x_FracPart_w
    // x_IntPart_w  = { x_IntFrac [31:16], 16'd0 } 
    // x_FracPart_w =   x_IntFrac [15: 0]          Always positive [0,1)

    logic signed [DATA_WIDTH-1:0] x_IntPart_w;
    logic signed [DATA_WIDTH-1:0] x_FracPart_w;

    assign x_IntPart_w  = { x_IntFrac[DATA_WIDTH-1:FRAC_BITS],{FRAC_BITS{1'b0}} };
    assign x_FracPart_w = {1'b0, x_IntFrac[FRAC_BITS-1:0]};

    //------------------------------------------------------------------
    // Stage-1: exp(x_IntPart) from LUT and find polynomial coefficients
    //------------------------------------------------------------------

    logic signed [DATA_WIDTH-1:0] exp_IntPart_lut;

    exp_lut u_exp_lut (
        .x_IntPart   (x_IntPart_w),
        .exp_IntPart (exp_IntPart_lut)
    );

    // Chebyshev's Polynomial upto third order,
    // exp(t) = C0*T0(t) + C1*T1(t) + C2*T2(t) + C3*T3(t)
    // Here,
    //     T0(t) = 1
    //     T1(t) = t
    //     T2(t) = 2*t^2 - 1
    //     T3(t) = 4*t^3 - 3t
    // For Chebyshev on [-1,1], t = (2*x - 1) maps x in [0,1] to t in [-1,1]
    // Hence,
    // exp(t) = C0 + C1 * t + C2 * (2*t^2 -1) + C3 * (4*t^3 - 3*t)
    // Siimplifying and normalizing the coefficients,
    localparam signed [DATA_WIDTH-1:0] A0 = 32'sd65502;
    localparam signed [DATA_WIDTH-1:0] A1 = 32'sd66592;
    localparam signed [DATA_WIDTH-1:0] A2 = 32'sd27722;
    localparam signed [DATA_WIDTH-1:0] A3 = 32'sd18292;

    // exp(x) = A0 + A1 * x + A2 * x^2 + A3 * x^3
    // Estrin's Scheme,
    //        = (A0 + A1 * x) + x^2 ( A2 + A3 * x)

    logic signed [2*DATA_WIDTH-1:0] term0_s1;     // A0 + A1 *x
    logic signed [2*DATA_WIDTH-1:0] term1_s1;     // x*x
    logic signed [2*DATA_WIDTH-1:0] term2_s1;     // A2 + A3 * x
    logic signed [DATA_WIDTH-1:0] exp_IntPart_s1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            term0_s1           <= '0;
            term1_s1           <= '0;
            term2_s1           <= '0;
            exp_IntPart_s1     <= '0;
        end
        else begin
            term0_s1 <= A0 + ((A1 * x_FracPart_w) >>> FRAC_BITS);     // A0 + A1 * x
            term1_s1 <= (x_FracPart_w * x_FracPart_w) >>> FRAC_BITS;  // x*x
            term2_s1 <= A2 + ((A3 * x_FracPart_w) >>> FRAC_BITS);     // A2 + A3 * x

            exp_IntPart_s1 <= exp_IntPart_lut;
        end
    end

    //------------------------------------------------------------------
    // Stage-2: exp_FracPart = term0_s1 + term1_s1 * term2_s1
    //------------------------------------------------------------------
    logic signed [DATA_WIDTH-1:0] exp_IntPart_s2;
    logic signed [DATA_WIDTH-1:0] exp_FracPart_s2;

    logic signed [2*DATA_WIDTH-1:0] term_1x2_s2;

    always_comb begin // term1_s1 * term2_s1
        term_1x2_s2 = (term1_s1 * term2_s1) >>> FRAC_BITS;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            exp_IntPart_s2  <= '0;
            exp_FracPart_s2 <= '0;
        end
        else begin
            exp_IntPart_s2  <= exp_IntPart_s1;
            exp_FracPart_s2 <= term0_s1 + term_1x2_s2; // term0_s1 + term1_s1 * term2_s1
        end
    end

    //------------------------------------------------------------------
    // Stage-3 exp(x_IntFrac) = exp(x_IntPart) * exp(x_FracPart)
    //------------------------------------------------------------------
    logic signed [2*DATA_WIDTH - 1:0] product_w;

    assign product_w = (exp_IntPart_s2 * exp_FracPart_s2) >>> FRAC_BITS;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            exp_x <= '0;
        end
        else begin
            exp_x <= product_w;
        end
    end
endmodule
