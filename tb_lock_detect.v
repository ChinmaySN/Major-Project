`timescale 1ns / 1ps

module tb_lock_detect;

    reg sys_clk;
    reg rst;
    reg ref_clk;
    reg [7:0] phase_error;

    wire lock_detect;

    integer i;
    integer errors;

    // DUT
    lock_detect dut (
        .sys_clk(sys_clk),
        .rst(rst),
        .ref_clk(ref_clk),
        .phase_error(phase_error),
        .lock_detect(lock_detect)
    );

    // Parameter override
    defparam dut.LOCK_COUNT = 4;

    // System clock (20 ns period)
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

    initial
    begin
        // Initialize signals
        sys_clk = 1'b0;
        rst = 1'b1;
        ref_clk = 1'b0;
        phase_error = 8'd10;
        errors = 0;

        // Release reset
        #40;
        rst = 1'b0;

        //---------------------------------------------------
        // Test 1 : Large phase error
        //---------------------------------------------------
        for (i = 0; i < 3; i = i + 1)
            pulse_ref;

        #1;

        if (lock_detect == 1'b0)
        begin
            $display("PASS: lock_detect remains LOW for large phase_error");
        end
        else
        begin
            $display("FAIL: lock_detect asserted unexpectedly");
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Test 2 : Small phase error
        //---------------------------------------------------
        phase_error = 8'd0;

        for (i = 0; i < 4; i = i + 1)
            pulse_ref;

        #1;

        if (lock_detect == 1'b1)
        begin
            $display("PASS: lock_detect asserted after LOCK_COUNT reference pulses");
        end
        else
        begin
            $display("FAIL: lock_detect did not assert");
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Summary
        //---------------------------------------------------
        $display("--------------------------------------");
        $display("TEST SUMMARY (tb_lock_detect)");
        $display("Errors = %0d", errors);
        $display("--------------------------------------");

        $finish;
    end

endmodule