/*
* <p_sub.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_sub #(
	parameter dconf_t I1_CONF = `DEF_DCONF,
	parameter dconf_t I2_CONF = `DEF_DCONF,
	parameter dconf_t O_CONF = `DEF_DCONF,
	// constant
	parameter I1_PREC = I1_CONF.prec,
	parameter I2_PREC = I2_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I1_PREC-1:0]	in1,
	input wire [I2_PREC-1:0]	in2,
	output wire					udf,
	output wire					ovf,
	output wire					rounded,
	output wire [O_PREC-1:0]	out
);

	//*** Requirements for Input and Output data format
	//		- Both port must be signed or unsigned
	//		- Both port must be same data type (bool, int, ...)
	generate
		case ( I1_CONF.dtype )
			BOOL : begin : t_bool
				if ( O_CONF.prec == 1 ) begin
					assign out = in1 ^ in2;
				end else begin
					assign out = in1 - in2;
				end
			end

			INT : begin : t_int
				p_int_sub #(
					.I1_CONF	( I1_CONF ),
					.I2_CONF	( I2_CONF ),
					.O_CONF		( O_CONF )
				) sub (
					.in1		( in1 ),
					.in2		( in2 ),
					.ovf		( ovf ),
					.out		( out )
				);

				assign udf = `Disable;
				assign rounded = `Disable;
			end

			FXP : begin : t_fxp
				p_fxp_sub #(
					.I1_CONF	( I1_CONF ),
					.I2_CONF	( I2_CONF ),
					.O_CONF		( O_CONF )
				) sub (
					.in1		( in1 ),
					.in2		( in2 ),
					.udf		( udf ),
					.ovf		( ovf ),
					.rounded	( rounded ),
					.out		( out )
				);
			end

			FP : begin : t_fp
				// Not Implemented Yet
			end

		endcase
	endgenerate

endmodule
