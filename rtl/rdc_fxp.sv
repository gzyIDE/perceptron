/*
* <rdc_fxp.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module rdc_fxp #(
	// port configuration
	parameter dconf_t I_CONF = `DEF_DCONF_FXP, 
	parameter dconf_t O_CONF = `DEF_DCONFS_FXP,
	// const
	parameter I_PREC = I_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I_PREC-1:0]		in,
	output wire					udf,		// underflow
	output wire					ovf,		// overflow 
	output wire					rounded,	// rounded
	output wire [O_PREC-1:0]	out
);

	/***** internal parameter *****/
	//*** fixed
	localparam SIGN = I_CONF.sign;
	localparam I_FRAC = I_CONF.frac;
	localparam O_FRAC = O_CONF.frac;
	localparam I_INT = I_PREC - I_FRAC;		// intger part
	localparam O_INT = O_PREC - O_FRAC;		// 
	localparam DIFF_FRAC = I_FRAC - O_FRAC;	// diff of binary point
	localparam DIFF_INT = I_INT - O_INT;	// diff of integer part



	/***** assign internal *****/
	assign {udf, ovf, rounded, out} = rdc_fxp_func(in);



	/***** convert function *****/
	localparam RDC_FXP_FUNC = O_PREC + 3;
	function [RDC_FXP_FUNC-1:0] rdc_fxp_func;
		input [I_PREC-1:0]	in;
		reg					sign;		// sign bit
		reg [DIFF_INT-1:0]	int_high;	// higher bit of integer
		reg [O_PREC-1:0]	out;
		reg					udf;
		reg					ovf;		// over flow
		reg					rounded;
		reg					imprecise;
		begin
			sign = in[I_PREC-1];
			udf = `Disable;				// never activated

			if ( SIGN ) begin
				//*** signed operation
				int_high = in[(I_PREC-1)-1:(I_PREC-1)-DIFF_INT];
				ovf = sign ? !(&int_high) : |int_high;
				out
					= ovf
						? sign 
							? {1'b1, {O_PREC-1{1'b0}}}
							: {1'b0, {O_PREC-1{1'b1}}}
						: {sign, in[O_PREC+(DIFF_FRAC-1)-1:DIFF_FRAC]};
				rounded = | (in[I_FRAC-1:0] << O_FRAC);
			end else begin
				//*** unsigned operation
				int_high = in[I_PREC-1:I_PREC-DIFF_INT];
				ovf = |int_high;
				out
					= ovf
						? {O_PREC{1'b1}}
						: in[O_PREC+DIFF_FRAC-1:DIFF_FRAC];
				rounded = | (in[I_FRAC-1:0]	<< O_FRAC);
			end

			imprecise = ovf || rounded;
			rdc_fxp_func = {udf, ovf, rounded, out};
		end
	endfunction

endmodule
