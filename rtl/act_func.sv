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

module act_func #(
	// Port configurations
	parameter dconf_t CONF = `DEF_DCONF,
	parameter actf_t ACT = `DEF_ACT 
)(
	input wire [CONF.prec-1:0]		in,
	output wire [CONF.prec-1:0]		out
);

	//***** activation function
	generate
		case ( ACT )	// actf_t
			STEP: begin : step
				act_step #(
					.CONF	( CONF )
				) func (
					.in		( in ),
					.out	( out )
				);
			end

			LINEAR : begin : line
				assign out = in;
			end
			ReLU : begin : relu
				act_relu #(
					.CONF	( CONF )
				) func (
					.in		( in ),
					.out	( out )
				);
			end
			SIGMOID : begin : sig
				// Not Implemented yet
				assign out = in;
			end
		endcase
	endgenerate

endmodule
