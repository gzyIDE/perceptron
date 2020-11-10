/*
* <exp_int.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module exp_int #(
	// Port configuration
	parameter dconf_t I_CONF = `DEF_DCONF_INT,
	parameter dconf_t O_CONF = `DEF_DCONFL_INT,
	// Do not touch
	parameter I_PREC = I_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I_PREC-1:0]		in,
	output logic [O_PREC-1:0]	out
);

	//***** internal parameters
	localparam SIGN = I_CONF.sign;
	localparam DIFF = O_PREC - I_PREC;



	//***** for combinational logics
	logic		sign;



	//***** assign output
	always_comb begin
		sign = SIGN ? in[I_PREC-1] : 1'b0;
		out = {{DIFF{sign}}, in};
	end

endmodule
