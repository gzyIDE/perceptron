/*
* <p_neg.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

// Output negative value of input (input must be sign)
module p_neg #(
	// port configuration
	parameter dconf_t CONF = `DEF_DCONF
)(
	input wire [CONF.prec-1:0]	in,
	output wire					ovf,
	output wire [CONF.prec-1:0]	out
);

	//***** Internal parameters
	localparam PREC = CONF.prec;

	generate
		case ( CONF.dtype )
			BOOL: begin : t_bool
				assign ovf = `Disable;
				assign out = {{PREC-1{1'b0}}, ~in[0]};
			end

			INT, FXP : begin : t_int
				assign ovf = ( in[PREC-1] && !( | in[PREC-2:0] ) );
				assign out =
					( ovf )
						? {1'b0, {PREC-1{1'b1}}}
						: ~in + 1;
			end

			FP : begin : t_fp
				assign ovf = `Disable;
				assign out = {~in[PREC-1], in[PREC-2:0]};
			end
		endcase
	endgenerate

endmodule
