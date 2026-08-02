`timescale 1ns / 1ps

module tb_divider;

    reg dco_out;
    reg rst;

    wire fbk_clk;

    integer t1;
    integer t2;
    integer errors;

    // DUT
    divider dut (
        .dco_out(dco_out),
        .rst(rst),
        .fbk_clk(fbk_clk)
    );

    // Parameter override
    defparam dut.DIV_N = 8;

    // 20 ns period DCO clock
    always #10 dco_out = ~dco_out;

    initial
    begin
        // Initialize signals
        dco_out = 1'b0;
        rst = 1'b1;
        errors = 0;

        // Release reset
        #40;
        rst = 1'b0;

        //---------------------------------------------------
        // Measure feedback clock period
        //---------------------------------------------------
        @(posedge fbk_clk);
        t1 = $time;

        @(posedge fbk_clk);
        t2 = $time;

        if ((t2 - t1) == (8 * 20))
        begin
            $display("PASS: fbk_clk period = %0d ns (Divide-by-8)", t2 - t1);
        end
        else
        begin
            $display("FAIL: fbk_clk period = %0d ns, expected %0d ns",
                     t2 - t1, (8 * 20));
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Summary
        //---------------------------------------------------
        $display("--------------------------------------");
        $display("TEST SUMMARY (tb_divider)");
        $display("Errors = %0d", errors);
        $display("--------------------------------------");

        $finish;
    end

endmodule