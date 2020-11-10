/*
* <exp_prec.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module exp_prec #(
	// Port configurations
	parameter dconf_t I_CONF = `DEF_DCONF,
	parameter dconf_t O_CONF = `DEF_DCONFL
)(
	input wire [I_CONF.prec-1:0]		in,
	output wire [O_CONF.prec-1:0]		out
);

	//***** Internal parameter
	localparam TYPE = I_CONF.dtype;
	localparam DIFF = O_CONF.prec - I_CONF.prec;



	//***** Module select by data type
	//*** Requirements for Input and Output data format
	//		- Both port must be signed or unsigned
	//		- Both port must be same data type (bool, int, ...)
	generate
		case ( TYPE )
			BOOL : begin : cnv_bool
				//*** through
				assign out = {{DIFF{1'b0}}, in};
			end

			INT : begin : cnv_int
				exp_int #(
					.I_CONF	( I_CONF ),
					.O_CONF	( O_CONF )
				) exp_int (
					.in		( in ),
					.out	( out )
				);
			end

			FXP : begin : cnv_fxp
				exp_fxp #(
					.I_CONF	( I_CONF ),
					.O_CONF	( O_CONF )
				) exp_fp (
					.in		( in ),
					.out	( out )
				);
			end
			
			FP : begin : cnv_fp
				// Not Implemented Yet
			end
		endcase
	endgenerate

endmodule
