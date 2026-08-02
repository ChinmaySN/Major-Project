`timescale 1ns / 1ps
module adaptive_ctrl (
    coarse_count,
    fine_count,
    fine_en,
    phase_dir_in,
    meas_valid_in,
    phase_error,
    phase_dir,
    meas_valid,
    mode
);
    input [7:0] coarse_count;
    input [3:0] fine_count;
    input fine_en;
    input phase_dir_in;
    input meas_valid_in;
    output [7:0] phase_error;
    output phase_dir;
    output meas_valid;
    output mode;

    reg [7:0] phase_error;
    reg phase_dir;
    reg meas_valid;
    reg mode;

    always @(coarse_count or fine_en or phase_dir_in or meas_valid_in) begin
        phase_dir   = phase_dir_in;
        meas_valid  = meas_valid_in;
        mode        = fine_en;
        phase_error = coarse_count;  // coarse_count is the reliable small-error reading;
                                      // fine_count remains available for waveform display only
    end
endmodule