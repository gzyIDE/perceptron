/*
* <slp_train.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module slp_train #(
	// port configuration
	parameter IN = 8,							// # of inputs
	parameter dconf_t I_CONF = `DEF_DCONF,		// Input
	parameter dconf_t R_CONF = `DEF_DCONF,		// Learning Rate
	parameter dconf_t W_CONF = `DEF_DCONF,		// Weight
	parameter dconf_t P_CONF = `DEF_DCONF,		// Prediction results
	// constant
	parameter I_PREC = I_CONF.prec,
	parameter R_PREC = R_CONF.prec,
	parameter W_PREC = W_CONF.prec,
	parameter P_PREC = P_CONF.prec,
	parameter WEIGHT = IN + 1
)(
	input  wire [IN-1:0][I_PREC-1:0]		in,
	input  wire [R_PREC-1:0]				rate,		// learning rate
	input  wire [WEIGHT-1:0][W_PREC-1:0]	weight,
	input  wire [P_PREC-1:0]				infer,		// Inference result
	input  wire [P_PREC-1:0]				train,		// Taring signal
	output wire [WEIGHT-1:0][W_PREC-1:0]	new_weight
);

	//***** internal parameters
	localparam dtype_t TYPE = I_CONF.dtype;

	//***** internal wires
	wire [I_PREC-1:0]				const1;
	wire [P_PREC-1:0]				error;


	//***** error calculation ( gradient descent )
	// Wi = weight, t = train, X = input
	// Wi_new = Wi + alpha*(t-WiX)X
	wire			dummy_udf;
	wire			dummy_ovf;
	wire			dummy_rounded;
	p_sub #(
		.I1_CONF	( P_CONF ),
		.I2_CONF	( P_CONF ),
		.O_CONF		( P_CONF )
	) calc_error (
		.in1		( train ),
		.in2		( infer ),
		.udf		( dummy_udf ),
		.ovf		( dummy_ovf ),
		.rounded	( dummy_rounded ),
		.out		( error )
	);


	
	//***** update calculation ( gradient descent )
	generate
		genvar gi;
		for ( gi = 0; gi < WEIGHT; gi = gi + 1 ) begin : LP_delta
			/* separate */
			wire [I_PREC-1:0]		in_each;
			wire [W_PREC-1:0]		w_each;
			wire [W_PREC-1:0]		new_w_each;

			if ( gi == WEIGHT - 1 ) begin : bias
				assign in_each = const1;
			end else begin : ins
				assign in_each = in[gi];
			end
			assign w_each = weight[gi];
			assign new_weight[gi] = new_w_each;

			//*** weight update
			wire			dummy_udf;
			wire			dummy_ovf;
			wire			dummy_rounded;
			slp_calc_weight #(
				.I_CONF		( I_CONF ),
				.R_CONF		( R_CONF ),
				.W_CONF		( W_CONF ),
				.P_CONF		( P_CONF )
			) calc_weight (
				.in			( in_each ),
				.rate		( rate ),
				.error		( error ),
				.weight		( w_each ),
				.udf		( dummy_udf ),
				.ovf		( dummy_ovf ),
				.rounded	( dummy_rounded ),
				.new_weight	( new_w_each )
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
				assign const1 = 1'b1 << I_CONF.frac;
			end
			FP : begin
				// not implemented yet...
				//int fp_exp = I_PREC - I_CONF.frac - 1;
				// assign const1 = {fp_exp-1{1'b1}} << I_CONF.frac;
			end
		endcase
	endgenerate

endmodule
