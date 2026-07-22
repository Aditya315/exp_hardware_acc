module exp_lut (
    input  logic signed [`DATA_WIDTH-1:0] x_IntPart,    // Q16.16
    output logic signed [`DATA_WIDTH-1:0] exp_IntPart   // Q16.16
);

    localparam signed [`DATA_WIDTH-1:0] NEG_07 =  -7 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] NEG_06 =  -6 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] NEG_05 =  -5 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] NEG_04 =  -4 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] NEG_03 =  -3 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] NEG_02 =  -2 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] NEG_01 =  -1 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_00 =   0 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_01 =   1 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_02 =   2 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_03 =   3 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_04 =   4 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_05 =   5 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_06 =   6 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_07 =   7 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_08 =   8 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_09 =   9 <<< `FRAC_BITS;
    localparam signed [`DATA_WIDTH-1:0] POS_10 =  10 <<< `FRAC_BITS;

    always_comb begin
        case (x_IntPart)
            NEG_07 : exp_IntPart = 32'd60;          // exp( -7) = 0.000912
            NEG_06 : exp_IntPart = 32'd162;         // exp( -6) = 0.002479
            NEG_05 : exp_IntPart = 32'd442;         // exp( -5) = 0.006738
            NEG_04 : exp_IntPart = 32'd1200;        // exp( -4) = 0.018316
            NEG_03 : exp_IntPart = 32'd3263;        // exp( -3) = 0.049787
            NEG_02 : exp_IntPart = 32'd8869;        // exp( -2) = 0.135335
            NEG_01 : exp_IntPart = 32'd24109;       // exp( -1) = 0.367879
            POS_00 : exp_IntPart = 32'd65536;       // exp(  0) = 1.000000
            POS_01 : exp_IntPart = 32'd178145;      // exp(  1) = 2.718282
            POS_02 : exp_IntPart = 32'd484249;      // exp(  2) = 7.389056
            POS_03 : exp_IntPart = 32'd1316326;     // exp(  3) = 20.085537
            POS_04 : exp_IntPart = 32'd3578144;     // exp(  4) = 54.598150
            POS_05 : exp_IntPart = 32'd9726405;     // exp(  5) = 148.413159
            POS_06 : exp_IntPart = 32'd26439109;    // exp(  6) = 403.428793
            POS_07 : exp_IntPart = 32'd71868951;    // exp(  7) = 1096.633158
            POS_08 : exp_IntPart = 32'd195360063;   // exp(  8) = 2980.957987
            POS_09 : exp_IntPart = 32'd531043708;   // exp(  9) = 8103.083928
            POS_10 : exp_IntPart = 32'd1443526462;  // exp( 10) = 22026.465795
            default: exp_IntPart = '0;
        endcase
    end
endmodule
