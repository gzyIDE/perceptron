/*
* <slp_calc_fxp_weight.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module slp_calc_fxp_weight #(
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
	output wire					udf,
	output wire					ovf,
	output wire					rounded,
	output wire [W_PREC-1:0]	new_weight
);

	//***** internal parameter
	localparam I_SIGN = I_CONF.sign;
	localparam I_FRAC = I_CONF.frac;
	localparam R_SIGN = R_CONF.sign;
	localparam R_FRAC = R_CONF.frac;
	localparam W_SIGN = W_CONF.sign;
	localparam W_FRAC = W_CONF.frac;
	localparam P_FRAC = P_CONF.frac;
	localparam P_SIGN = P_CONF.sign;
	localparam E1_SIGN = I_SIGN || R_SIGN;
	localparam E1_PREC = I_PREC + R_PREC;
	localparam E1_FRAC = I_FRAC + R_FRAC;
	localparam E2_SIGN = E1_SIGN || P_SIGN;
	localparam E2_PREC = E1_PREC + P_PREC;
	localparam E2_FRAC = E1_FRAC + P_FRAC;
	localparam D_SIGN = W_SIGN || E2_SIGN;
	localparam D_PREC = `Max(W_PREC,E2_PREC);
	localparam D_FRAC = `Max(W_FRAC,E2_FRAC);
	//*** structs
	localparam dconf_t E1_CONF = dconf_t'{
		dtype: FXP, sign: E1_SIGN, prec: E1_PREC, frac: E1_FRAC
	};
	localparam dconf_t E2_CONF = dconf_t'{
		dtype: FXP, sign: E2_SIGN, prec: E2_PREC, frac: E2_FRAC
	};
	localparam dconf_t D_CONF = dconf_t'{
		dtype: FXP, sign: D_SIGN, prec: D_PREC, frac: D_FRAC
	};


	//***** Internal wires
	wire [E1_PREC-1:0]		ir;					// Product of in and rate
	wire [E2_PREC-1:0]		delta;				// weight update
	wire [D_PREC-1:0]		new_weight_tmp;		// new weight before precision adjustment
	wire					ovf1, udf1, rounded1;
	wire					ovf2, udf2, rounded2;
	wire					ovf3, udf3, rounded3;
	wire					ovf4, udf4, rounded4;



	//***** Assign output
	assign ovf = ovf1 || ovf2 || ovf3 || ovf4;
	assign udf = udf1 || udf2 || udf3 || udf4;
	assign rounded = rounded1 || rounded2 || rounded3 || rounded4;



	//***** Input x Rate
	p_fxp_mult #(
		.I1_CONF	( I_CONF ),
		.I2_CONF	( R_CONF ),
		.O_CONF		( E1_CONF )
	) mult1 (
		.in1		( in ),
		.in2		( rate ),
		.udf		( udf1 ),
		.ovf		( ovf1 ),
		.rounded	( rounded1 ),
		.out		( ir )
	);



	//***** Error x (Input x Rate)
	p_fxp_mult #(
		.I1_CONF	( E1_CONF ),
		.I2_CONF	( P_CONF ),
		.O_CONF		( E2_CONF )
	) mult2 (
		.in1		( ir ),
		.in2		( error ),
		.udf		( udf2 ),
		.ovf		( ovf2 ),
		.rounded	( rounded2 ),
		.out		( delta )
	);



	//***** calculate update weight
	p_fxp_add #(
		.I1_CONF	( E2_CONF ),
		.I2_CONF	( W_CONF ),
		.O_CONF		( D_CONF )
	) add (
		.in1		( delta ),
		.in2		( weight ),
		.udf		( udf3 ),
		.ovf		( ovf3 ),
		.rounded	( rounded3 ),
		.out		( new_weight_tmp )
	);



	//***** format output
	generate
		if ( D_PREC > W_PREC ) begin : rdc_out
			rdc_fxp #(
				.I_CONF		( D_CONF ),
				.O_CONF		( W_CONF )
			) rdc (
				.in			( new_weight_tmp ),
				.udf		( udf4 ),
				.ovf		( ovf4 ),
				.rounded	( rounded4 ),
				.out		( new_weight )
			);
		end else begin : thr_out
			assign udf4 = `Disable;
			assign ovf4 = `Disable; 
			assign new_weight = new_weight_tmp;
		end
	endgenerate

endmodule
