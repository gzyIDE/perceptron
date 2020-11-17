/*
* <slp.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

// Single layer perceptrons
module slp #(
	// port configuration
	parameter IN = 8,							// # of inputs
	parameter dconf_t I_CONF = `DEF_DCONF,		// Input
	parameter dconf_t R_CONF = `DEF_DCONF,		// Learning Rate
	parameter dconf_t W_CONF = `DEF_DCONF,		// Weight
	parameter dconf_t O_CONF = `DEF_DCONF,		// Output
	// Activation Function
	parameter actf_t ACT = `DEF_ACT,			// Activation Function
	// constant
	parameter I_PREC = I_CONF.prec,				// data width
	parameter O_PREC = O_CONF.prec,				// prediction result width
	parameter R_PREC = R_CONF.prec,				// learning rate width
	parameter W_PREC = W_CONF.prec				// weight width
)(
	input  wire							clk,
	input  wire							reset_,

	/* inference */
	input  wire [IN-1:0][I_PREC-1:0]	in,
	output wire [O_PREC-1:0]			out,

	/* train */
	input wire [O_PREC-1:0]				train,		// training data
	input wire [R_PREC-1:0]				rate,		// learning rate
	input wire							t_en		// train enable
);

	//***** internal parameters
	localparam TYPE = I_CONF.dtype;					// Data type used inside this perceptron
	localparam WEIGHT = 1 + IN;						// input + bias

	//***** internal registers
	reg [WEIGHT-1:0][W_PREC-1:0]	weight;

	//***** internal wires
	wire [WEIGHT-1:0][W_PREC-1:0]	new_weight;		// trained weight



	//***** inference
	wire		dummy_udf;
	wire		dummy_ovf;
	wire		dummy_rounded;
	slp_infer #(
		.IN			( IN ),
		.I_CONF		( I_CONF ),
		.W_CONF		( W_CONF ),
		.O_CONF		( O_CONF ),
		.ACT		( ACT )
	) p_infer (
		.in			( in ),
		.weight		( weight ),
		.udf		( dummy_udf ),
		.ovf		( dummy_ovf ),
		.rounded	( dummy_rounded ),
		.out		( out )
	);



	//***** training
	slp_train #(
		.IN			( IN ),
		.I_CONF		( I_CONF ),
		.R_CONF		( R_CONF ),
		.W_CONF		( W_CONF ),
		.P_CONF		( O_CONF )
	) p_train (
		.in			( in ),
		.rate		( rate ),
		.weight		( weight ),
		.infer		( out ),
		.train		( train ),
		.new_weight	( new_weight )
	);



	/***** sequential logics *****/
	integer i;
	always @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			for ( i = 0; i < WEIGHT; i = i + 1) begin
`ifdef INIT_ALL_ZERO
				weight[i] <= {W_PREC{1'b0}};
`else
				weight[i] <= init_rand(i);
`endif
			end
		end else begin
			weight <= t_en ? new_weight : weight;
		end
	end

	function [W_PREC-1:0] init_rand;
		input longint	idx;
		longint			i;
		longint			r;
		begin
			r = 2463534242;
			for ( i = 0; i < idx+1; i = i + 1 ) begin
				r = r ^ (r << 13);
				r = r ^ (r >> 17);
				r = r ^ (r << 5);
			end

			init_rand = r;
		end
	endfunction

endmodule
