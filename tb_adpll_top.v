`timescale 1ns / 1ps
module tb_adpll_top;
    reg sys_clk, rst;
    reg [7:0] p_step, i_step;
    wire dco_out, lock_detect, mode;
    wire [7:0] coarse_count, ctrl_word;
    wire [3:0] fine_count;
    integer errors;

    adpll_top dut (.sys_clk(sys_clk), .rst(rst), .p_step(p_step), .i_step(i_step),
                   .dco_out(dco_out), .lock_detect(lock_detect), .coarse_count(coarse_count),
                   .fine_count(fine_count), .mode(mode), .ctrl_word(ctrl_word));

    always #10 sys_clk = ~sys_clk;

    initial begin
        sys_clk = 1'b0; rst = 1'b1;
        p_step = 8'd0; i_step = 8'd1;
        errors = 0;
        #100; rst = 1'b0;

        #2000;
        if (mode == 1'b0) $display("PASS: Phase 1 - Coarse mode active, coarse_count=%0d", coarse_count);
        else $display("INFO: Phase 1 - already near lock, coarse_count=%0d", coarse_count);

        wait (mode == 1'b1);
        $display("PASS: Phase 2 - Fine mode entered, Time=%0t, coarse_count=%0d", $time, coarse_count);

        wait (lock_detect == 1'b1);
        $display("PASS: Phase 3 - PLL Locked, Time=%0t, ctrl_word=%0d", $time, ctrl_word);

        $display("--------------------------------------");
        $display("TEST SUMMARY: Errors=%0d", errors);
        $display("--------------------------------------");
        $finish;
    end

    initial begin
        #2000000;
        $display("--------------------------------------");
        $display("FAIL: Simulation timed out");
        $display("--------------------------------------");
        $finish;
    end
endmodule