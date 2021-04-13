/*
* <slp_train_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"
`include "sim.vh"

//`define SIM_FXP
`define SIM_INT

module p_train_test;
	parameter STEP = 10;
	parameter IN = 8;
	parameter WEIGHT = IN + 1;
`ifdef SIM_FXP
	parameter dtype_t TYPE = FXP;
	// input configuration
	parameter I_SIGN = `Enable;
	parameter I_PREC = 8;
	parameter I_FRAC = 0;
	// Learning Rate configuration
	parameter R_SIGN = `Disable;
	parameter R_PREC = 5;
	parameter R_FRAC = 0;
	// weight configuration
	parameter W_SIGN = `Enable;
	parameter W_PREC = 16;
	parameter W_FRAC = 0;
	// Inference Result configuration
	parameter P_SIGN = `Enable;
	parameter P_PREC = 8;
	parameter P_FRAC = 0;
`elsif SIM_INT
	parameter dtype_t TYPE = INT;
	// input configuration
	parameter I_SIGN = `Enable;
	parameter I_PREC = 8;
	parameter I_FRAC = 3;
	// Learning Rate configuration
	parameter R_SIGN = `Disable;
	parameter R_PREC = 4;
	parameter R_FRAC = 4;
	// weight configuration
	parameter W_SIGN = `Enable;
	parameter W_PREC = 16;
	parameter W_FRAC = 4;
	// Inference Result configuration
	parameter P_SIGN = `Enable;
	parameter P_PREC = 8;
	parameter P_FRAC = 3;
`endif

	// Simulation Loops
	parameter LOOP = 1000;

	//***** struct instantiation
	parameter dconf_t I_CONF 
		= dconf_t'{dtype: TYPE, sign: I_SIGN, prec: I_PREC, frac: I_FRAC};
	parameter dconf_t R_CONF 
		= dconf_t'{dtype: TYPE, sign: R_SIGN, prec: R_PREC, frac: R_FRAC};
	parameter dconf_t W_CONF 
		= dconf_t'{dtype: TYPE, sign: W_SIGN, prec: W_PREC, frac: W_FRAC};
	parameter dconf_t P_CONF 
		= dconf_t'{dtype: TYPE, sign: P_SIGN, prec: P_PREC, frac: P_FRAC};

	//***** input and outputs
	reg [IN-1:0][I_PREC-1:0]		in;
	reg [R_PREC-1:0]				rate;
	reg [WEIGHT-1:0][W_PREC-1:0]	weight;
	reg [P_PREC-1:0]				infer;
	wire [P_PREC-1:0]				train;
	wire [WEIGHT-1:0][W_PREC-1:0]	new_weight;

	//***** class declaration
`ifdef SIM_FXP
	`include "fxp_util.svh"
	FxpUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_fxp;

	FxpUtils #(
		.CONF		( R_CONF ),
		.ATTR		( "rate" )
	) rate_fxp;

	FxpUtils #(
		.CONF		( W_CONF ),
		.ATTR		( "w" )
	) w_fxp;

	FxpUtils #(
		.CONF		( P_CONF ),
		.ATTR		( "p" )
	) p_fxp;

`elsif SIM_INT
	`include "int_util.svh"
	IntUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_int;

	IntUtils #(
		.CONF		( R_CONF ),
		.ATTR		( "rate" )
	) rate_int;

	IntUtils #(
		.CONF		( W_CONF ),
		.ATTR		( "w" )
	) w_int;

	IntUtils #(
		.CONF		( P_CONF ),
		.ATTR		( "p" )
	) p_int;
`endif


	initial begin
		// check ommited
		$finish;
	end

	`include "waves.vh"

endmodule
