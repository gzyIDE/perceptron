/*
* <slp_calc_int_weight.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

// Learning rate is used to perform right shift
`define RATE_SHIFT

module slp_calc_int_weight #(
	// port configuration
	parameter dconf_t I_CONF = `DEF_DCONF_FXP,
	parameter dconf_t R_CONF = `DEF_DCONF_FXP,
	parameter dconf_t W_CONF = `DEF_DCONF_FXP,
	parameter dconf_t P_CONF = `DEF_DCONF_FXP,
	// constant
	parameter I_PREC = I_CONF.prec,
	parameter R_PREC = R_CONF.prec,
	parameter W_PREC = W_CONF.prec,
	parameter P_PREC = P_CONF.prec
)(
	input wire [I_PREC-1:0]		in,
	input wire [R_PREC-1:0]		rate,
	input wire [P_PREC-1:0]		error,
	input wire [W_PREC-1:0]		weight,
	output wire					ovf,
	output wire [W_PREC-1:0]	new_weight
);

	//***** internal parameter
	localparam I_SIGN = I_CONF.sign;
	localparam R_SIGN = R_CONF.sign;
	localparam W_SIGN = W_CONF.sign;
	localparam P_SIGN = P_CONF.sign;
`ifdef RATE_SHIFT
	localparam E1_SIGN = I_SIGN || P_SIGN;
	localparam E1_PREC = I_PREC + P_PREC;
	localparam E2_SIGN = E1_SIGN;
	localparam E2_PREC = E1_PREC - R_PREC;
`else
	localparam E1_SIGN = I_SIGN || R_SIGN;
	localparam E1_PREC = I_PREC + R_PREC;
	localparam E2_SIGN = E1_SIGN || P_SIGN;
	localparam E2_PREC = E1_PREC + P_PREC;
`endif
	localparam D_SIGN = W_SIGN || E2_SIGN;
	localparam D_PREC = `Max(W_PREC,E2_PREC);
	//*** structs
	localparam dconf_t E1_CONF = dconf_t'{
		dtype: FXP, sign: E1_SIGN, prec: E1_PREC, frac: 0
	};
	localparam dconf_t E2_CONF = dconf_t'{
		dtype: FXP, sign: E2_SIGN, prec: E2_PREC, frac: 0
	};
	localparam dconf_t D_CONF = dconf_t'{
		dtype: FXP, sign: D_SIGN, prec: D_PREC, frac: 0
	};

	//***** Internal wires
	wire [E1_PREC-1:0]		ir;					// Product of in and rate
	wire [E2_PREC-1:0]		delta;				// weight update
	wire [D_PREC-1:0]		new_weight_tmp;		// new weight before precision adjustment
	wire					ovf1;
	wire					ovf2;
	wire					ovf3;
	wire					ovf4;



	//***** Assign output
	assign ovf = ovf1 || ovf2 || ovf3 || ovf4;



	//***** Input x Rate
`ifdef RATE_SHIFT
	// 'rate' is ignored...
	//***** Input x Error
	p_int_mult #(
		.I1_CONF	( I_CONF ),
		.I2_CONF	( P_CONF ),
		.O_CONF		( E1_CONF )
	) mult1 (
		.in1		( in ),
		.in2		( error ),
		.ovf		( ovf1 ),
		.out		( ir )
	);

	assign ovf2 = `Disable;
	assign delta = 
		E1_SIGN
			? {{R_PREC{ir[E1_PREC-1]}}, ir[E1_PREC-1:R_PREC]}
			: {{R_PREC{1'b0}}, ir[E1_PREC-1:R_PREC]};
`else
	//*** simply right sihit
	p_int_mult #(
		.I1_CONF	( I_CONF ),
		.I2_CONF	( R_CONF ),
		.O_CONF		( E1_CONF )
	) mult1 (
		.in1		( in ),
		.in2		( rate ),
		.ovf		( ovf1 ),
		.out		( ir )
	);



	//***** Error x (Input x Rate)
	p_int_mult #(
		.I1_CONF	( E1_CONF ),
		.I2_CONF	( P_CONF ),
		.O_CONF		( E2_CONF )
	) mult2 (
		.in1		( ir ),
		.in2		( error ),
		.ovf		( ovf2 ),
		.out		( delta )
	);
`endif



	//***** calculate update weight
	p_int_add #(
		.I1_CONF	( E2_CONF ),
		.I2_CONF	( W_CONF ),
		.O_CONF		( D_CONF )
	) add (
		.in1		( delta ),
		.in2		( weight ),
		.ovf		( ovf3 ),
		.out		( new_weight_tmp )
	);



	//***** precision adjust and output
	generate
		if ( D_PREC > W_PREC ) begin : rdc_out
			rdc_int #(
				.I_CONF		( D_CONF ),
				.O_CONF		( W_CONF )
			) rdc (
				.in			( new_weight_tmp ),
				.ovf		( ovf4 ),
				.out		( new_weight )
			);
		end else begin : thr_out
			assign ovf4 = `Disable;
			assign new_weight = new_weight_tmp;
		end
	endgenerate

endmodule
