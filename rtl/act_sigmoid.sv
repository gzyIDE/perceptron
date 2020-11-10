/*
* <act_sigmoid.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module act_sigmoid #(
	parameter dconf_t CONF = `DEF_DCONF,
	// constant
	parameter PREC = CONF.prec
)(
	input wire [PREC-1:0]	in,
	output wire [PREC-1:0]	out
);

	/***** assign output *****/
	generate
		case ( CONF.dtype )
			BOOL : begin : t_bool
			end
			INT : begin : t_int
			end
			FXP : begin : t_fxp
			end
			FP : begin : t_fp
			end
		endcase
	endgenerate

endmodule
