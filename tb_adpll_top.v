`timescale 1ns / 1ps

module tb_adpll_top;

    reg sys_clk;
    reg rst;

    reg [7:0] p_step;
    reg [7:0] i_step;

    wire dco_out;
    wire lock_detect;
    wire mode;

    wire [7:0] coarse_count;
    wire [7:0] ctrl_word;
    wire [3:0] fine_count;

    integer errors;

    // DUT
    adpll_top dut (
        .sys_clk(sys_clk),
        .rst(rst),
        .p_step(p_step),
        .i_step(i_step),
        .dco_out(dco_out),
        .lock_detect(lock_detect),
        .coarse_count(coarse_count),
        .fine_count(fine_count),
        .mode(mode),
        .ctrl_word(ctrl_word)
    );

    // 50 MHz system clock (20 ns period)
    always #10 sys_clk = ~sys_clk;

    //---------------------------------------------------------
    // Main Test
    //---------------------------------------------------------
    initial
    begin
        // Initialize signals
        sys_clk = 1'b0;
        rst = 1'b1;
        p_step = 8'd0;
		  i_step = 8'd1;
        errors = 0;

        // Hold reset
        #100;
        rst = 1'b0;

        //-------------------------------------------------
        // Phase 1 : Initial coarse mode
        //-------------------------------------------------
        #2000;

        if (mode == 1'b0)
        begin
            $display("PASS: Phase 1 - Coarse mode active");
            $display("      mode = %0d, coarse_count = %0d",
                     mode, coarse_count);
        end
        else
        begin
            $display("INFO: Phase 1 - Already close to lock");
            $display("      mode = %0d, coarse_count = %0d",
                     mode, coarse_count);
        end

        //-------------------------------------------------
        // Phase 2 : Wait for fine mode
        //-------------------------------------------------
        wait (mode == 1'b1);

        $display("PASS: Phase 2 - Fine mode entered");
        $display("      Time = %0t", $time);
        $display("      coarse_count = %0d", coarse_count);

        //-------------------------------------------------
        // Phase 3 : Wait for lock
        //-------------------------------------------------
        wait (lock_detect == 1'b1);

        $display("PASS: Phase 3 - PLL Locked");
        $display("      Time = %0t", $time);
        $display("      ctrl_word = %0d", ctrl_word);

        //-------------------------------------------------
        // Summary
        //-------------------------------------------------
        $display("--------------------------------------");
        $display("TEST SUMMARY (tb_adpll_top)");
        $display("Errors = %0d", errors);
        $display("--------------------------------------");

        $finish;
    end

    //---------------------------------------------------------
    // Safety Timeout
    //---------------------------------------------------------
    initial
    begin
        #4000000;

        $display("--------------------------------------");
        $display("FAIL: Simulation timed out");
        $display("PLL never reached lock.");
        $display("--------------------------------------");

        $finish;
    end

endmodule