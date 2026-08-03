`timescale 1ns / 1ps
module ref_clk_gen (sys_clk, rst, ref_clk);
    parameter REF_DIV = 64;
    input sys_clk;
    input rst;
    output ref_clk;
    reg ref_clk;
    reg [15:0] cnt;
    always @(posedge sys_clk) begin
        if (rst) begin
            cnt <= 16'd0;
            ref_clk <= 1'b0;
        end else if (cnt == (REF_DIV/2)-1) begin
            cnt <= 16'd0;
            ref_clk <= ~ref_clk;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule