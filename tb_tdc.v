`timescale 1ns / 1ps

module tb_tdc;

    reg sys_clk;
    reg rst;
    reg ref_clk;
    reg fbk_clk;

    wire [7:0] coarse_count;
    wire [3:0] fine_count;
    wire fine_en;

    integer errors;

    // DUT
    tdc dut (
        .sys_clk(sys_clk),
        .rst(rst),
        .ref_clk(ref_clk),
        .fbk_clk(fbk_clk),
        .coarse_count(coarse_count),
        .fine_count(fine_count),
        .fine_en(fine_en)
    );

    // Parameter override
    defparam dut.COARSE_THRESH = 2;

    // 50 MHz clock
    always #10 sys_clk = ~sys_clk;

    // Reference clock pulse
    task pulse_ref;
    begin
        @(posedge sys_clk);
        ref_clk = 1'b1;
        @(posedge sys_clk);
        ref_clk = 1'b0;
    end
    endtask

    // Feedback clock pulse
    task pulse_fbk;
    begin
        @(posedge sys_clk);
        fbk_clk = 1'b1;
        @(posedge sys_clk);
        fbk_clk = 1'b0;
    end
    endtask

    initial
    begin
        sys_clk = 1'b0;
        rst = 1'b1;
        ref_clk = 1'b0;
        fbk_clk = 1'b0;
        errors = 0;

        #40;
        rst = 1'b0;

        //---------------------------------------------------
        // Test 1 : Large phase error
        //---------------------------------------------------
        pulse_ref;

        repeat (5)
            @(posedge sys_clk);

        pulse_fbk;

        #20;

        if ((coarse_count >= 8'd4) &&
            (coarse_count <= 8'd6) &&
            (fine_en == 1'b0))
        begin
            $display("PASS: Test1 large phase error, coarse_count=%0d fine_en=%0d",
                     coarse_count, fine_en);
        end
        else
        begin
            $display("FAIL: Test1 coarse_count=%0d fine_en=%0d",
                     coarse_count, fine_en);
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Test 2 : Small phase error
        //---------------------------------------------------
        pulse_ref;

        @(posedge sys_clk);

        pulse_fbk;

        #20;

        if ((coarse_count <= 8'd2) &&
            (fine_en == 1'b1))
        begin
            $display("PASS: Test2 small phase error, coarse_count=%0d fine_en=%0d fine_count=%0d",
                     coarse_count, fine_en, fine_count);
        end
        else
        begin
            $display("FAIL: Test2 coarse_count=%0d fine_en=%0d",
                     coarse_count, fine_en);
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Summary
        //---------------------------------------------------
        $display("--------------------------------------");
        $display("TEST SUMMARY (tb_tdc)");
        $display("Errors = %0d", errors);
        $display("--------------------------------------");

        $finish;
    end

endmodule