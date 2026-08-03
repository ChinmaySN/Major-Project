`timescale 1ns / 1ps
module lock_detect (sys_clk, rst, meas_valid, ctrl_word, lock_detect);
    parameter LOCK_COUNT = 8;
    input sys_clk, rst, meas_valid;
    input [7:0] ctrl_word;
    output lock_detect;
    reg lock_detect;
    reg [7:0] prev_ctrl_word;
    reg [7:0] cnt;

    always @(posedge sys_clk) begin
        if (rst) begin
            prev_ctrl_word <= 8'd0;
            cnt <= 8'd0;
            lock_detect <= 1'b0;
        end else if (meas_valid) begin
            if (ctrl_word == prev_ctrl_word) begin
                if (cnt < LOCK_COUNT) cnt <= cnt + 1'b1;
                if (cnt >= LOCK_COUNT-1'b1) lock_detect <= 1'b1;
            end else begin
                cnt <= 8'd0;
                lock_detect <= 1'b0;
            end
            prev_ctrl_word <= ctrl_word;
        end
    end
endmodule