/*
* <act_relu.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module act_relu #(
	// port configuration
	parameter dconf_t CONF = `DEF_DCONF,
	// constant
	parameter PREC = CONF.prec
)(
	input wire [PREC-1:0]	in,
	output logic [PREC-1:0]	out
);

	//***** internal parameters
	localparam SIGN = CONF.sign;

	//***** assign output
	generate
		case ( CONF.dtype )
			FXP, INT : begin : fxp_int
				always_comb begin
					if ( SIGN ) begin
						out = in[PREC-1] ? {PREC{1'b0}} : in;
					end else begin
						// threshold on 0b100..00
						//	0b0111..1 -> rounded to 0b100..00
						out = in[PREC-1] ? in : {1'b1, {PREC-1{1'b0}}};
					end
				end
			end
			BOOL : begin : bool
				// Not support Bool
				assign out = in;
			end
			FP : begin : fp
				always_comb begin
					out = in[PREC-1] ? {PREC{1'b0}} : in;
				end
			end
		endcase
	endgenerate

endmodule
