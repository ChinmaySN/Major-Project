`timescale 1ns / 1ps
module divider (
    sys_clk,
    dco_out,
    rst,
    fbk_clk
);
    parameter DIV_N = 8;

    input sys_clk;
    input dco_out;
    input rst;
    output fbk_clk;

    reg fbk_clk;
    reg dco_d;
    wire dco_pe = dco_out & ~dco_d;

    reg [3:0] cnt;

    always @(posedge sys_clk) begin
        if (rst) begin
            dco_d   <= 1'b0;
            cnt     <= 4'd0;
            fbk_clk <= 1'b0;
        end else begin
            dco_d <= dco_out;
            if (dco_pe) begin
                if (cnt >= (DIV_N/2) - 1) begin
                    cnt     <= 4'd0;
                    fbk_clk <= ~fbk_clk;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end
endmodule