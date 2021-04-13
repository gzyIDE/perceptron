/*
* <slp_infer.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module slp_infer #(
	// input configuration
	parameter IN = 8,					// # of inputs
	parameter dconf_t I_CONF = `DEF_DCONF,
	parameter dconf_t W_CONF = `DEF_DCONF,
	parameter dconf_t O_CONF = `DEF_DCONF, 
	// Activation Function
	parameter actf_t ACT = `DEF_ACT,
	// Accumulation option
	parameter NO_ACC_EXT = `Disable,	// Extend Bit width on Accumulation
	// constant
	parameter I_PREC = I_CONF.prec,
	parameter W_PREC = W_CONF.prec,
	parameter O_PREC = O_CONF.prec,
	parameter WEIGHT = IN + 1
)(
	input wire [IN-1:0][I_PREC-1:0]		in,
	input wire [WEIGHT-1:0][W_PREC-1:0]	weight,
	output wire							udf,
	output wire							ovf,
	output wire							rounded,
	output wire [O_PREC-1:0]			out
);

	//***** internal parameter
	localparam dtype_t TYPE = I_CONF.dtype;
	localparam I_SIGN = I_CONF.sign;
	localparam I_FRAC = I_CONF.frac;
	localparam W_SIGN = W_CONF.sign;
	localparam W_FRAC = W_CONF.frac;
	localparam E_SIGN = I_SIGN || W_SIGN;
	localparam E_PREC 
		= ( TYPE == BOOL )
			? W_SIGN
				? W_PREC
				: $clog2(IN) + 1
			: ( TYPE == FXP  || TYPE == INT )
				? NO_ACC_EXT
					? W_PREC
					: I_PREC + W_PREC
				: `Max(I_PREC, W_PREC);
	localparam E_FRAC 
		= ( TYPE == FXP || TYPE == INT ) 
			? NO_ACC_EXT 
				? W_FRAC
				: I_FRAC + W_FRAC 
			: `Max(I_FRAC, W_FRAC);
	localparam dconf_t E_CONF = dconf_t'{
		dtype: TYPE, sign: E_SIGN, prec: E_PREC, frac: E_FRAC
	};

	//***** internal wires
	wire [I_PREC-1:0]				const1;
	wire [WEIGHT-1:0][E_PREC-1:0]	res_mult;
	wire [E_PREC-1:0]				res_acc;
	wire [E_PREC-1:0]				res_act;
	wire [WEIGHT-1:0]				mult_udf;
	wire [WEIGHT-1:0]				mult_ovf;
	wire [WEIGHT-1:0]				mult_rounded;
	wire							acc_udf;
	wire							acc_ovf;
	wire							acc_rounded;



	//***** assign output
	assign udf = (| mult_udf) || acc_udf;
	assign ovf = (| mult_ovf) || acc_ovf;
	assign rounded = (| mult_rounded) || acc_rounded;



	//***** multiplier
	generate
		genvar gi;
		for ( gi = 0; gi < WEIGHT; gi = gi + 1 ) begin : LP_mul
			wire [I_PREC-1:0]	i_each;
			wire [W_PREC-1:0]	w_each;
			wire [E_PREC-1:0]	res_each;
			if ( gi == WEIGHT - 1 ) begin : bias
				assign i_each = const1;
			end else begin : act
				assign i_each = in[gi];
			end
			assign w_each = weight[gi];
			assign res_mult[gi] = res_each;


			/* multiplier */
			p_mult #(
				.I1_CONF	( I_CONF ),
				.I2_CONF	( W_CONF ),
				.O_CONF		( E_CONF )
			) mult (
				.in1		( i_each ),
				.in2		( weight[gi] ),
				.ovf		( mult_ovf[gi] ),
				.udf		( mult_udf[gi] ),
				.rounded	( mult_rounded[gi] ),
				.out		( res_mult[gi] )
			);
		end
	endgenerate



	//***** accumulate
	p_acc #(
		.IN			( WEIGHT ),
		.CONF		( E_CONF )
	) acc (
		.in			( res_mult ),
		.udf		( acc_udf ),
		.ovf		( acc_ovf ),
		.rounded	( acc_rounded ),
		.out		( res_acc )
	);



	//***** activation function
	act_func #(
		.CONF	( E_CONF ),
		.ACT	( ACT )
	) act_func (
		.in		( res_acc ),
		.out	( res_act )
	);



	//***** convet for output
	generate
		if ( O_PREC == 1 ) begin : b	// bool
			assign out = ( res_act == {E_PREC{1'b0}} ) ? 1'b0 : 1'b1;
		end else begin : nb				// not bool
			wire			dummy_udf2;
			wire			dummy_ovf2;
			wire			dummy_rounded2;

			cnv_prec #(
				.I_CONF		( E_CONF ),
				.O_CONF		( O_CONF )
			) cnv_prec (
				.in			( res_act ),
				.udf		( dummy_udf2 ),
				.ovf		( dummy_ovf2 ),
				.rounded	( dummy_rounded2 ),
				.out		( out )
			);
		end
	endgenerate



	//***** generate constant 1
	generate
		case ( TYPE )
			BOOL : begin
				assign const1 = 1'b1;
			end
			INT : begin
				assign const1 = 1'b1;
			end
			FXP : begin
				assign const1 = 1'b1 << I_FRAC;
			end
			FP : begin
				// not implemented yet...
				// assign const1 = {I_FRAC-1{1'b1}} << (I_PREC - I_FRAC - 1);
			end
		endcase
	endgenerate

endmodule
