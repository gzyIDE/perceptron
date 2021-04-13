/*
* <slp.sv>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"
`include "slp.svh"
`include "fxp_util.svh"
`include "int_util.svh"
`include "fp_util.svh"

// An example of single layer perceptrons
module slp #(
	// port configuration
	parameter IN = 8,								// # of inputs
	parameter dconf_t I_CONF = `DEF_DCONF,			// Input
	parameter dconf_t R_CONF = `DEF_DCONF,			// Learning Rate
	parameter dconf_t W_CONF = `DEF_DCONF,			// Weight
	parameter dconf_t O_CONF = `DEF_DCONF,			// Output
	// Activation Function
	parameter actf_t ACT = `DEF_ACT,				// Activation Function
	// Reset
	parameter SlpReset_t RESET = `DEFAULT_SLP_RESET,// reset method
	// constant
	parameter I_PREC = I_CONF.prec,					// data width
	parameter O_PREC = O_CONF.prec,					// prediction result width
	parameter R_PREC = R_CONF.prec,					// learning rate width
	parameter W_PREC = W_CONF.prec					// weight width
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



	//***** sequential logics
	integer i;
	generate
		case ( RESET )
			//*** initialize with zero
			RESET_ZERO : begin : CASE_zero
				always_ff @( posedge clk or negedge reset_ ) begin
					if ( reset_ == `Enable_ ) begin
						weight <= 0;
					end else begin
						weight <= t_en ? new_weight : weight;
					end
				end
			end

			//*** initialize all wights with maximum value
			RESET_MAX : begin : CASE_max
				always_ff @( posedge clk or negedge reset_ ) begin
					if ( reset_ == `Enable_ ) begin
						for ( i = 0; i < WEIGHT ; i = i + 1 ) begin
							case ( W_CONF.dtype )
								BOOL : begin
									weight[i] <= 1'b0;
								end
								INT : begin
									weight[i] <=
										IntUtils #(
											.CONF	( W_CONF )
										)::get_max(`Low);
								end
								FXP : begin
									weight[i] <=
										FxpUtils #(
											.CONF	( W_CONF )
										)::get_max(`Low);
								end
								FP : begin
									weight[i] <=
										FpUtils #(
											.CONF	( W_CONF )
										)::get_max(`Low);
								end
							endcase
						end
					end else begin
						weight <= t_en ? new_weight : weight;
					end
				end
			end

			//*** initialize all weights with minimum value
			RESET_MIN : begin : CASE_min
				always_ff @( posedge clk or negedge reset_ ) begin
					if ( reset_ == `Enable_ ) begin
						for ( i = 0; i < WEIGHT ; i = i + 1 ) begin
							case ( W_CONF.dtype )
								BOOL : begin
									weight[i] <= 1'b1;
								end
								INT : begin
									weight[i] <=
										IntUtils #(
											.CONF	( W_CONF )
										)::get_max(`High);
								end
								FXP : begin
									weight[i] <=
										FxpUtils #(
											.CONF	( W_CONF )
										)::get_max(`High);
								end
								FP : begin
									weight[i] <=
										FpUtils #(
											.CONF	( W_CONF )
										)::get_max(`High);
								end
							endcase
						end
					end else begin
						weight <= t_en ? new_weight : weight;
					end
				end
			end

			//*** randomize initial weight
			RESET_RANDOM : begin : CASE_rand
				always_ff @( posedge clk or negedge reset_ ) begin
					if ( reset_ == `Enable_ ) begin
						for ( i = 0; i < WEIGHT; i = i + 1 ) begin
							weight[i] <= init_rand(i);
						end
					end else begin
						weight <= t_en ? new_weight : weight; 
					end
				end

				//* xor-shift based pseudo random generator
				function [W_PREC-1:0] init_rand (
					input bit [31:0]	idx
				);
					bit [31:0]		i;
					bit [31:0]		r;

					r = 32'd2463534242;
					for ( i = 0; i < idx + 1; i = i + 1 ) begin
						r = r ^ (r << 13);
						r = r ^ (r >> 17);
						r = r ^ (r << 5);
					end

					init_rand = r;
				endfunction
			end
		endcase
	endgenerate

endmodule
