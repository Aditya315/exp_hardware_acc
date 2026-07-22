`timescale 1ns/1ps
`include "../rtl/filelist.sv"
module tb_exp_rtl;

    localparam DATA_WIDTH = `DATA_WIDTH;
    localparam FRAC_BITS  = `FRAC_BITS;
    localparam LATENCY    = 3;

    logic signed [DATA_WIDTH-1:0] x_IntFrac, exp_x;
    logic clk, rst_n;

    exp_rtl dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    real x_q[$], exp_q[$];
    real worst_err;
    integer cycle_cnt;

    initial begin
        $dumpfile("output/exp_wave.vcd");
        $dumpvars(0, tb_exp_rtl);
    end

    // Reset
    initial begin
        rst_n = 0;
        x_IntFrac = 0;
        cycle_cnt = 0;
        worst_err = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
    end

    // Main Sequence
    initial begin
        wait (rst_n);
        $display("\n=========================================================================");
        $display("  x         Expected          Actual        %%Error");
        $display("=========================================================================");

        for (real x = -7.0; x <= 10.0; x += 0.1) begin
            real ref_val;
            x_IntFrac = $rtoi(x * (1 << FRAC_BITS));
            ref_val = ($exp(x) > 2147483647.0 / (1 << FRAC_BITS)) ?
                  2147483647.0 / (1 << FRAC_BITS) : $exp(x);
            x_q.push_back(x);
            exp_q.push_back(ref_val);
            @(posedge clk);
        end

        repeat (LATENCY + 4) @(posedge clk);
        $display("=========================================================================");
        $display("  Worst Error = %0.6f %%\n", worst_err);
        $finish;
    end

    // Scoreboard Check
    always @(posedge clk) begin
        if (rst_n) cycle_cnt <= cycle_cnt + 1;

        if (rst_n && cycle_cnt >= LATENCY && exp_q.size() > 0) begin
            real x_s, ref_s, act_s, err_s;
            x_s   = x_q.pop_front();
            ref_s = exp_q.pop_front();
            act_s = $itor(exp_x) / (1 << FRAC_BITS);
            err_s = (ref_s > 0) ? (100.0 * ((act_s > ref_s) ? act_s - ref_s : ref_s - act_s) / ref_s) : 0;
            if (err_s > worst_err) worst_err = err_s;
            $display("  %6.2f    %12.6f    %12.6f    %8.5f%%", x_s, ref_s, act_s, err_s);
        end
    end

endmodule
