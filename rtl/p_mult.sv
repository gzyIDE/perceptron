/*
* <p_mult.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_mult #(
	// port configuration
	parameter dconf_t I1_CONF = `DEF_DCONF,
	parameter dconf_t I2_CONF = `DEF_DCONF,
	parameter dconf_t O_CONF = `DEF_DCONF
)(
	input wire [I1_CONF.prec-1:0]	in1,
	input wire [I2_CONF.prec-1:0]	in2,
	output wire						udf,
	output wire						ovf,
	output wire						rounded,
	output wire [O_CONF.prec-1:0]	out
);

	//*** Requirements for Input and Output data format
	//		- Both port must be signed or unsigned
	//		- Both port must be same data type (bool, int, ...)
	generate
		case ( I1_CONF.dtype )
			FXP : begin : t_fxp
				p_fxp_mult #(
					.I1_CONF	( I1_CONF ),
					.I2_CONF	( I2_CONF ),
					.O_CONF		( O_CONF )
				) mult (
					.in1		( in1 ),
					.in2		( in2 ),
					.udf		( udf ),
					.ovf		( ovf ),
					.rounded	( rounded ),
					.out		( out )
				);
			end

			INT : begin : t_int
				p_int_mult #(
					.I1_CONF	( I1_CONF ),
					.I2_CONF	( I2_CONF ),
					.O_CONF		( O_CONF )
				) mult (
					.in1		( in1 ),
					.in2		( in2 ),
					.ovf		( ovf ),
					.out		( out )
				);

				assign rounded = `Disable;
				assign udf = `Disable;
			end

			BOOL : begin : t_bool
				p_bool_mult #(
					.I2_CONF	( I2_CONF ),
					.O_CONF		( O_CONF )
				) mult (
					.in1		( in1[0] ),
					.in2		( in2 ),
					.out		( out )
				);

				assign ovf = `Disable;
				assign rounded = `Disable;
				assign udf = `Disable;
			end

			FP : begin : t_fp
			end
		endcase
	endgenerate

endmodule
