/*
* <slp_calc_weight.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module slp_calc_weight #(
	// port configuration
	parameter dconf_t I_CONF = `DEF_DCONF,
	parameter dconf_t R_CONF = `DEF_DCONF,
	parameter dconf_t W_CONF = `DEF_DCONF,
	parameter dconf_t P_CONF = `DEF_DCONF,
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

	localparam TYPE = I_CONF.dtype;


	generate
		case ( TYPE )
			BOOL : begin : t_bool
				assign udf = `Disable;
				assign ovf = `Disable;
				assign rounded = `Disable;

				slp_calc_bool_weight #(
					.W_PREC		( W_PREC )
				) delta (
					.in			( in ),
					.error		( error ),
					.weight		( weight ),
					.new_weight	( new_weight )
				);
			end

			INT : begin : t_int
				assign udf = `Disable;
				assign rounded = `Disable;

				slp_calc_int_weight #(
					.I_CONF		( I_CONF ),
					.R_CONF		( R_CONF ),
					.W_CONF		( W_CONF ),
					.P_CONF		( P_CONF )
				) delta (
					.in			( in ),
					.rate		( rate ),
					.error		( error ),
					.weight		( weight ),
					.ovf		( ovf ),
					.new_weight	( new_weight )
				);
			end

			FXP : begin : t_fxp
				slp_calc_fxp_weight #(
					.I_CONF		( I_CONF ),
					.R_CONF		( R_CONF ),
					.W_CONF		( W_CONF ),
					.P_CONF		( P_CONF )
				) delta (
					.in			( in ),
					.rate		( rate ),
					.error		( error ),
					.weight		( weight ),
					.udf		( udf ),
					.ovf		( ovf ),
					.rounded	( rounded ),
					.new_weight	( new_weight )
				);
			end
		endcase
	endgenerate

endmodule
