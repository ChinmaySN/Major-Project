`timescale 1ns / 1ps

module tb_dco;

    reg sys_clk;
    reg rst;
    reg [7:0] ctrl_word;

    wire dco_out;

    integer t1;
    integer t2;
    integer errors;

    // DUT
    dco dut (
        .sys_clk(sys_clk),
        .rst(rst),
        .ctrl_word(ctrl_word),
        .dco_out(dco_out)
    );

    // 50 MHz system clock (20 ns period)
    always #10 sys_clk = ~sys_clk;

    initial
    begin
        // Initialize signals
        sys_clk = 1'b0;
        rst = 1'b1;
        ctrl_word = 8'd10;
        errors = 0;

        // Release reset
        #40;
        rst = 1'b0;

        //---------------------------------------------------
        // Test 1 : ctrl_word = 10
        //---------------------------------------------------
        @(posedge dco_out);
        t1 = $time;

        @(posedge dco_out);
        t2 = $time;

        if ((t2 - t1) == (10 * 20))
        begin
            $display("PASS: dco_out period = %0d ns for ctrl_word = 10",
                     t2 - t1);
        end
        else
        begin
            $display("FAIL: dco_out period = %0d ns, expected %0d ns",
                     t2 - t1, (10 * 20));
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Test 2 : ctrl_word = 5
        //---------------------------------------------------
        ctrl_word = 8'd5;

        @(posedge dco_out);
        t1 = $time;

        @(posedge dco_out);
        t2 = $time;

        if ((t2 - t1) == (5 * 20))
        begin
            $display("PASS: dco_out period = %0d ns for ctrl_word = 5",
                     t2 - t1);
        end
        else
        begin
            $display("FAIL: dco_out period = %0d ns, expected %0d ns",
                     t2 - t1, (5 * 20));
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Summary
        //---------------------------------------------------
        $display("--------------------------------------");
        $display("TEST SUMMARY (tb_dco)");
        $display("Errors = %0d", errors);
        $display("--------------------------------------");

        $finish;
    end

endmodule