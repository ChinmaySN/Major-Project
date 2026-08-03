`timescale 1ns / 1ps
module dco (sys_clk, rst, ctrl_word, dco_out);
    input sys_clk, rst;
    input [7:0] ctrl_word;
    output dco_out;
    reg dco_out;
    reg [7:0] cnt;
    wire [7:0] divide_val = (ctrl_word == 8'd0) ? 8'd1 : ctrl_word;
    always @(posedge sys_clk) begin
        if (rst) begin
            cnt <= 8'd0;
            dco_out <= 1'b0;
        end else if (cnt >= divide_val - 1'b1) begin
            cnt <= 8'd0;
            dco_out <= ~dco_out;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule