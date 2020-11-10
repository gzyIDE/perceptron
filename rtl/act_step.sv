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

module act_step #(
	// input configuration
	parameter dconf_t CONF = `DEF_DCONF_FXP,
	// constant
	parameter PREC = CONF.prec
)(
	input wire [PREC-1:0]		in,
	output logic [PREC-1:0]		out
);

	//***** Intermal parameters
	localparam SIGN = CONF.sign;
	localparam FRAC = CONF.frac;

	//***** comibational logics
	logic [PREC-1:0]			const1;



	//***** assign output
	generate
		case ( CONF.dtype )
			BOOL : begin : t_bool
				always_comb begin
					out = in[PREC-1] ? {PREC{1'b0}} : {{PREC-1{1'b0}}, 1'b1};
				end
			end

			INT : begin : t_int
				always_comb begin
					if ( SIGN ) begin
						const1 = {{PREC-1{1'b0}}, 1'b1};
						out = in[PREC-1] ? {PREC{1'b0}} : const1;
					end else begin
						// 0b10000 or more -> round to 0b111..11;
						// 0b0xxxx -> round to 0b011..11;
						const1 = {PREC{1'b1}};
						out = in[PREC-1] ? const1 : {1'b0, {PREC-1{1'b1}}};
					end
				end
			end

			FXP : begin : t_fxp
				always_comb begin
					if ( SIGN ) begin
						const1 = 1'b1 << FRAC;
						out = in[PREC-1] ? {PREC{1'b0}} : const1;
					end else begin
						const1 = {PREC{1'b1}};
						out = in[PREC-1] ? const1 : {1'b0, {PREC-1{1'b1}}};
					end
				end
			end

			FP : begin : t_fp
				// Not implemented yet!
			end
		endcase
	endgenerate

endmodule
