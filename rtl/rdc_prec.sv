/*
* <rdc_prec.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module rdc_prec #(
	// port configuration
	parameter dconf_t I_CONF = `DEF_DCONF,
	parameter dconf_t O_CONF = `DEF_DCONFS
)(
	input wire [I_CONF.prec-1:0]	in,
	output wire						udf,		// underflow
	output wire						ovf,		// overflow 
	output wire						rounded,	// rounded
	output wire [O_CONF.prec-1:0]	out
);

	/***** assign output *****/
	//*** Requirements for Input and Output data format
	//		- Both port must be signed or unsigned
	//		- Both port must be same data type (bool, int, ...)
	generate
		case ( I_CONF.dtype )
			BOOL: begin : cnv_none
				assign out = in[O_CONF.prec-1:0];
				assign udf = `Disable;
				assign ovf = `Disable;
				assign rounded = `Disable;
			end

			INT : begin
				rdc_int #(
					.I_CONF		( I_CONF ),
					.O_CONF		( O_CONF )
				) rdc_int (
					.in			( in ),
					.ovf		( ovf ),
					.out		( out )
				);

				assign udf = `Disable;
				assign rounded = `Disable;
			end

			FXP : begin : cnv_fxp
				rdc_fxp #(
					.I_CONF		( I_CONF ),
					.O_CONF		( O_CONF )
				) rdc_fxp (
					.in			( in ),
					.udf		( udf ),
					.ovf		( ovf ),
					.rounded	( rounded ),
					.out		( out )
				);
			end

			FP : begin : cnv_fp
				// Not Implemented Yet
			end
		endcase
	endgenerate

endmodule
