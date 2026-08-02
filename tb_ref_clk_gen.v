`timescale 1ns/1ps
module tb_ref_clk_gen;

    reg sys_clk = 0;
    reg rst     = 1;
    wire ref_clk;

    integer t1, t2;
    integer errors = 0;

    ref_clk_gen dut (
    .sys_clk(sys_clk),
    .rst(rst),
    .ref_clk(ref_clk)
);

defparam dut.REF_DIV = 10;

    always #10 sys_clk = ~sys_clk;   // 50 MHz -> 20 ns period

    initial begin
        rst = 1;
        #40;
        rst = 0;

        @(posedge ref_clk); t1 = $time;
        @(posedge ref_clk); t2 = $time;

        if ((t2 - t1) == 10 * 20) begin
            $display("PASS: ref_clk period = %0d ns as expected", t2 - t1);
        end else begin
            $display("FAIL: ref_clk period = %0d ns, expected %0d ns", t2 - t1, 10*20);
            errors = errors + 1;
        end

        $display("TEST SUMMARY (tb_ref_clk_gen): %0d errors", errors);
        $finish;
    end

endmodule