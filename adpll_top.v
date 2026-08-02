`timescale 1ns / 1ps
								  
module adpll_top (
    sys_clk,
    rst,
    p_step,
    i_step,
    dco_out,
    lock_detect,
    coarse_count,
    fine_count,
    mode,
    ctrl_word
);

    input sys_clk;
    input rst;
    input [7:0] p_step;
    input [7:0] i_step;

    output dco_out;
    output lock_detect;
    output [7:0] coarse_count;
    output [3:0] fine_count;
    output mode;
    output [7:0] ctrl_word;

    wire dco_out;
    wire lock_detect;
    wire [7:0] coarse_count;
    wire [3:0] fine_count;
    wire mode;
    wire [7:0] ctrl_word;

    wire ref_clk;
    wire fbk_clk;
    wire fine_en;
    wire [7:0] phase_error;
	 wire phase_dir_tdc;
    wire phase_dir;
	 wire meas_valid_tdc;
    wire meas_valid;

    //-------------------------------------------------
    // Reference Clock Generator
    //-------------------------------------------------
    ref_clk_gen u_refgen (
        .sys_clk(sys_clk),
        .rst(rst),
        .ref_clk(ref_clk)
    );
    defparam u_refgen.REF_DIV = 400;

    //-------------------------------------------------
    // Time-to-Digital Converter
    //-------------------------------------------------
    tdc u_tdc (
        .sys_clk(sys_clk),
        .rst(rst),
        .ref_clk(ref_clk),
        .fbk_clk(fbk_clk),
        .coarse_count(coarse_count),
        .fine_count(fine_count),
        .fine_en(fine_en),
        .phase_dir(phase_dir_tdc),
        .meas_valid(meas_valid_tdc)
    );
    defparam u_tdc.COARSE_THRESH = 4;
    defparam u_tdc.HALF_PERIOD   = 200;
    defparam u_tdc.FULL_PERIOD   = 400;

    //-------------------------------------------------
    // Adaptive Controller
    //-------------------------------------------------
    adaptive_ctrl u_actrl (
        .coarse_count(coarse_count),
        .fine_count(fine_count),
        .fine_en(fine_en),
        .phase_dir_in(phase_dir_tdc),
        .meas_valid_in(meas_valid_tdc),
        .phase_error(phase_error),
        .phase_dir(phase_dir),
        .meas_valid(meas_valid),
        .mode(mode)
    );

    //-------------------------------------------------
    // Digital Loop Filter
    //-------------------------------------------------
    loop_filter u_lf (
        .sys_clk(sys_clk),
        .rst(rst),
        .phase_error(phase_error),
        .phase_dir(phase_dir),
        .meas_valid(meas_valid),
        .mode(mode),
        .p_step(p_step),
        .i_step(i_step),
        .ctrl_word(ctrl_word)
    );

    //-------------------------------------------------
    // Digitally Controlled Oscillator
    //-------------------------------------------------
    dco u_dco (
        .sys_clk(sys_clk),
        .rst(rst),
        .ctrl_word(ctrl_word),
        .dco_out(dco_out)
    );

    //-------------------------------------------------
    // Feedback Divider
    //-------------------------------------------------
    divider u_div (
        .sys_clk(sys_clk),
        .dco_out(dco_out),
        .rst(rst),
        .fbk_clk(fbk_clk)
    );
    defparam u_div.DIV_N = 8;

    //-------------------------------------------------
    // Lock Detector
    //-------------------------------------------------
    lock_detect u_lock (
        .sys_clk(sys_clk),
        .rst(rst),
        .ref_clk(ref_clk),
        .phase_error(phase_error),
        .lock_detect(lock_detect)
    );
    defparam u_lock.LOCK_COUNT = 8;

endmodule