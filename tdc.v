`timescale 1ns / 1ps
module tdc (sys_clk, rst, ref_clk, fbk_clk, coarse_count, fine_count, fine_en, phase_dir, meas_valid);
    parameter COARSE_THRESH = 16;
    input sys_clk, rst, ref_clk, fbk_clk;
    output [7:0] coarse_count;
    output [3:0] fine_count;
    output fine_en, phase_dir, meas_valid;

    reg [7:0] coarse_count;
    reg [3:0] fine_count;
    reg fine_en, phase_dir, meas_valid;

    reg ref_d, fbk_d;
    wire ref_pe = ref_clk & ~ref_d;
    wire fbk_pe = fbk_clk & ~fbk_d;

    reg ref_ff, fbk_ff;
    wire pfd_reset = ref_ff & fbk_ff;

    reg first_was_ref;
    reg [15:0] cnt;
    reg [3:0] fine_free;

    always @(posedge sys_clk) begin
        if (rst) begin
            ref_d <= 1'b0; fbk_d <= 1'b0;
            ref_ff <= 1'b0; fbk_ff <= 1'b0;
            first_was_ref <= 1'b0;
            cnt <= 16'd0; fine_free <= 4'd0;
            coarse_count <= 8'd0; fine_count <= 4'd0;
            fine_en <= 1'b0; phase_dir <= 1'b0; meas_valid <= 1'b0;
        end else begin
            ref_d <= ref_clk;
            fbk_d <= fbk_clk;
            fine_free <= fine_free + 1'b1;
            meas_valid <= 1'b0;

            if (pfd_reset) begin
                coarse_count <= (cnt > 16'd255) ? 8'd255 : cnt[7:0];
                phase_dir <= ~first_was_ref;
                if (cnt <= COARSE_THRESH) begin
                    fine_en <= 1'b1;
                    fine_count <= fine_free;
                end else begin
                    fine_en <= 1'b0;
                    fine_count <= 4'd0;
                end
                meas_valid <= 1'b1;
                ref_ff <= ref_pe;
                fbk_ff <= fbk_pe;
                if (ref_pe && !fbk_pe) first_was_ref <= 1'b1;
                else if (fbk_pe && !ref_pe) first_was_ref <= 1'b0;
                cnt <= (ref_pe || fbk_pe) ? 16'd1 : 16'd0;
            end else begin
                if (ref_pe && !ref_ff && !fbk_ff) first_was_ref <= 1'b1;
                if (fbk_pe && !ref_ff && !fbk_ff) first_was_ref <= 1'b0;
                if (ref_pe) ref_ff <= 1'b1;
                if (fbk_pe) fbk_ff <= 1'b1;
                if ((ref_ff | fbk_ff | ref_pe | fbk_pe) && cnt != 16'hFFFF)
                    cnt <= cnt + 1'b1;
            end
        end
    end
endmodule