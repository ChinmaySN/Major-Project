`timescale 1ns / 1ps
module loop_filter (
    sys_clk,
    rst,
    phase_error,
    phase_dir,
    meas_valid,
    mode,
    p_step,
    i_step,
    ctrl_word
);
    parameter MAX      = 8'd255;
    parameter MIN      = 8'd1;
    parameter DEADBAND = 8'd4;

    input sys_clk;
    input rst;
    input [7:0] phase_error;
    input phase_dir;
    input meas_valid;
    input mode;
    input [7:0] p_step;
    input [7:0] i_step;
    output [7:0] ctrl_word;

    reg [7:0] ctrl_word;

    // Tiered step: large jumps only when far off (fast pull-in), shrinking to a
    // single-unit step well before the target -- prevents overshoot past lock,
    // since 1 unit of ctrl_word = 16 sys_clk cycles of period change (DIV_N=8).
    reg [7:0] coarse_step;
    always @(phase_error)
    begin
        if (phase_error > 8'd64)
            coarse_step = 8'd8;
        else if (phase_error > 8'd16)
            coarse_step = 8'd2;
        else
            coarse_step = 8'd1;
    end

    wire [7:0] step_total;
	 assign step_total = (mode) ? i_step : coarse_step;

    always @(posedge sys_clk) begin
        if (rst) begin
            ctrl_word <= MAX;
        end else if (meas_valid && phase_error > DEADBAND) begin
            if (phase_dir == 1'b0) begin
                if (ctrl_word > (MIN + step_total))
                    ctrl_word <= ctrl_word - step_total;
                else
                    ctrl_word <= MIN;
            end else begin
                if (ctrl_word < (MAX - step_total))
                    ctrl_word <= ctrl_word + step_total;
                else
                    ctrl_word <= MAX;
            end
        end
    end
endmodule