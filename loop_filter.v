`timescale 1ns / 1ps
module loop_filter (sys_clk, rst, phase_error, phase_dir, meas_valid, mode, p_step, i_step, ctrl_word);
    parameter MAX = 8'd255;
    parameter MIN = 8'd2;
    parameter DEADBAND = 8'd16;

    input sys_clk, rst;
    input [7:0] phase_error;
    input phase_dir, meas_valid, mode;
    input [7:0] p_step, i_step;
    output [7:0] ctrl_word;

    reg [7:0] ctrl_word;
    reg [7:0] coarse_step;

    always @(phase_error) begin
        coarse_step = phase_error >> 4;
        if (coarse_step == 8'd0) coarse_step = 8'd1;
        // no upper cap -- >>4 scaling already tapers naturally as phase_error shrinks
    end

    wire [7:0] step_total = mode ? i_step : coarse_step;

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