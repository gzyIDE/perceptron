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

module exp_fxp #(
	// Port configuration
	parameter dconf_t I_CONF = `DEF_DCONF_FXP,
	parameter dconf_t O_CONF = `DEF_DCONFL_FXP,
	// constant
	parameter I_PREC = I_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I_PREC-1:0]		in,
	output logic [O_PREC-1:0]	out
);

	//***** internal parameter
	localparam SIGN = I_CONF.sign;
	localparam I_FRAC = I_CONF.frac;
	localparam O_FRAC = O_CONF.frac;
	localparam I_INT = I_PREC - I_FRAC;		// intger part
	localparam O_INT = O_PREC - O_FRAC;		// 
	localparam DIFF_FRAC = O_FRAC - I_FRAC;	// diff of binary point
	localparam DIFF_INT = O_INT - I_INT;	// diff of integer part


	
	//***** Combinational logics
	logic		sign;



	//***** convert function
	always_comb begin
		sign = SIGN ? in[I_PREC-1] : 1'b0;
		out = {{DIFF_INT{sign}}, in, {DIFF_FRAC{1'b0}}};
	end

endmodule
