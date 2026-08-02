`timescale 1ns / 1ps

module tb_loop_filter;

    reg sys_clk;
    reg rst;

    reg [7:0] phase_error;
    reg [7:0] p_step;
    reg [7:0] i_step;
    reg [7:0] held;

    wire [7:0] ctrl_word;

    integer errors;

    // DUT
    loop_filter dut (
        .sys_clk(sys_clk),
        .rst(rst),
        .phase_error(phase_error),
        .p_step(p_step),
        .i_step(i_step),
        .ctrl_word(ctrl_word)
    );

    // 50 MHz Clock
    always #10 sys_clk = ~sys_clk;

    initial
    begin
        // Initialize signals
        sys_clk = 1'b0;
        rst = 1'b1;
        phase_error = 8'd0;
        p_step = 8'd1;
        i_step = 8'd2;
        held = 8'd0;
        errors = 0;

        // Hold reset
        #40;
        rst = 1'b0;

        //---------------------------------------------------
        // Test 1 : Initial value
        //---------------------------------------------------
        #5;

        if (ctrl_word == 8'hFF)
        begin
            $display("PASS: ctrl_word starts at maximum (%0d)", ctrl_word);
        end
        else
        begin
            $display("FAIL: ctrl_word initial value = %0d", ctrl_word);
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Test 2 : Non-zero phase error
        //---------------------------------------------------
        phase_error = 8'd5;

        repeat (5)
            @(posedge sys_clk);

        #1;

        if (ctrl_word < 8'hFF)
        begin
            $display("PASS: ctrl_word decreased (%0d)", ctrl_word);
        end
        else
        begin
            $display("FAIL: ctrl_word did not decrease (%0d)", ctrl_word);
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Test 3 : Hold when phase_error = 0
        //---------------------------------------------------
        phase_error = 8'd0;

        @(posedge sys_clk);
        #1;
        held = ctrl_word;

        repeat (3)
            @(posedge sys_clk);

        #1;

        if (ctrl_word == held)
        begin
            $display("PASS: ctrl_word held constant (%0d)", ctrl_word);
        end
        else
        begin
            $display("FAIL: ctrl_word changed (%0d -> %0d)", held, ctrl_word);
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Summary
        //---------------------------------------------------
        $display("--------------------------------------");
        $display("TEST SUMMARY (tb_loop_filter)");
        $display("Errors = %0d", errors);
        $display("--------------------------------------");

        $finish;
    end

endmodule