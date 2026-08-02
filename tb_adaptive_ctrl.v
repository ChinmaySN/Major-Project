`timescale 1ns / 1ps

module tb_adaptive_ctrl;

    reg [7:0] coarse_count;
    reg [3:0] fine_count;
    reg fine_en;

    wire [7:0] phase_error;
    wire mode;

    integer errors;

    // DUT
    adaptive_ctrl dut (
        .coarse_count(coarse_count),
        .fine_count(fine_count),
        .fine_en(fine_en),
        .phase_error(phase_error),
        .mode(mode)
    );

    initial
    begin
        errors = 0;

        //---------------------------------------------------
        // Test 1 : Coarse Mode
        //---------------------------------------------------
        coarse_count = 8'd10;
        fine_count   = 4'd0;
        fine_en      = 1'b0;

        #10;

        if ((mode == 1'b0) && (phase_error == coarse_count))
        begin
            $display("PASS: Coarse mode selected (phase_error = %0d)", phase_error);
        end
        else
        begin
            $display("FAIL: Coarse mode test (phase_error = %0d, mode = %0d)",
                     phase_error, mode);
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Test 2 : Fine Mode
        //---------------------------------------------------
        coarse_count = 8'd1;
        fine_count   = 4'd3;
        fine_en      = 1'b1;

        #10;

        if ((mode == 1'b1) && (phase_error == 8'd3))
        begin
            $display("PASS: Fine mode selected (phase_error = %0d)", phase_error);
        end
        else
        begin
            $display("FAIL: Fine mode test (phase_error = %0d, mode = %0d)",
                     phase_error, mode);
            errors = errors + 1;
        end

        //---------------------------------------------------
        // Summary
        //---------------------------------------------------
        $display("--------------------------------------");
        $display("TEST SUMMARY (tb_adaptive_ctrl)");
        $display("Errors = %0d", errors);
        $display("--------------------------------------");

        $finish;
    end

endmodule