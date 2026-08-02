`timescale 1ns / 1ps
module lock_detect (
    sys_clk,
    rst,
    ref_clk,
    phase_error,
    lock_detect
);
    parameter LOCK_COUNT  = 8;
    parameter LOCK_THRESH = 4;   // matches the minimum achievable quantized error
                                  // for REF_DIV=50, DIV_N=8 (see design note)

    input sys_clk;
    input rst;
    input ref_clk;
    input [7:0] phase_error;
    output lock_detect;

    reg lock_detect;
    reg ref_d;
    wire ref_pe = ref_clk & ~ref_d;
    wire in_range = (phase_error <= LOCK_THRESH);

    reg [7:0] cnt;

    always @(posedge sys_clk) begin
        if (rst) begin
            ref_d       <= 1'b0;
            cnt         <= 8'd0;
            lock_detect <= 1'b0;
        end else begin
            ref_d <= ref_clk;
            if (ref_pe) begin
                if (in_range) begin
                    if (cnt < LOCK_COUNT)
                        cnt <= cnt + 1'b1;
                    if (cnt >= LOCK_COUNT - 1'b1)
                        lock_detect <= 1'b1;
                end else begin
                    cnt         <= 8'd0;
                    lock_detect <= 1'b0;
                end
            end
        end
    end
endmodule