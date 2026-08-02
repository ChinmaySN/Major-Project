`timescale 1ns / 1ps
module tdc (
    sys_clk,
    rst,
    ref_clk,
    fbk_clk,
    coarse_count,
    fine_count,
    fine_en,
    phase_dir,
    meas_valid
);
    parameter COARSE_THRESH = 4;
    parameter HALF_PERIOD   = 16'd200;  // must be REF_DIV/2 from ref_clk_gen
    parameter FULL_PERIOD   = 16'd400;  // must match REF_DIV from ref_clk_gen

    input sys_clk;
    input rst;
    input ref_clk;
    input fbk_clk;
    output [7:0] coarse_count;
    output [3:0] fine_count;
    output fine_en;
    output phase_dir;
    output meas_valid;

    reg [7:0] coarse_count;
    reg [3:0] fine_count;
    reg fine_en, phase_dir, meas_valid;

    reg ref_d, fbk_d;
    wire ref_pe = ref_clk & ~ref_d;
    wire fbk_pe = fbk_clk & ~fbk_d;

    reg [15:0] cnt_ref;    // free-running: time since the last ref_clk edge
    reg [3:0]  fine_free;
    reg [15:0] err_mag;

    // Free-running reference-relative counter -- resets every ref_clk period,
    // continuously tracks elapsed time regardless of when fbk_clk ticks.
    always @(posedge sys_clk) begin
        if (rst) begin
            cnt_ref <= 16'd0;
        end else if (ref_pe) begin
            cnt_ref <= 16'd0;
        end else if (cnt_ref != 16'hFFFF) begin
            cnt_ref <= cnt_ref + 1'b1;
        end
    end

    // Snapshot cnt_ref the instant fbk_clk ticks -- no state machine, no ties.
    always @(posedge sys_clk) begin
        if (rst) begin
            ref_d        <= 1'b0;
            fbk_d        <= 1'b0;
            fine_free    <= 4'd0;
            coarse_count <= 8'd0;
            fine_count   <= 4'd0;
            fine_en      <= 1'b0;
            phase_dir    <= 1'b0;
            meas_valid   <= 1'b0;
            err_mag      <= 16'd0;
        end else begin
            ref_d      <= ref_clk;
            fbk_d      <= fbk_clk;
            fine_free  <= fine_free + 1'b1;
            meas_valid <= 1'b0;

            if (fbk_pe) begin
                if (cnt_ref <= HALF_PERIOD) begin
                    err_mag   = cnt_ref;                 // fbk lagged ref -> speed up
                    phase_dir <= 1'b0;
                end else begin
                    err_mag   = FULL_PERIOD - cnt_ref;    // fbk led ref -> slow down
                    phase_dir <= 1'b1;
                end

                coarse_count <= (err_mag > 16'd255) ? 8'd255 : err_mag[7:0];

                if (err_mag <= COARSE_THRESH) begin
                    fine_en    <= 1'b1;
                    fine_count <= fine_free;
                end else begin
                    fine_en    <= 1'b0;
                    fine_count <= 4'd0;
                end
                meas_valid <= 1'b1;
            end
        end
    end
endmodule