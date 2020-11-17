/*
* <p_bool_mult.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module p_bool_mult #(
	// port configuration
	parameter dconf_t I2_CONF = `DEF_DCONF_FXP,
	parameter dconf_t O_CONF = `DEF_DCONF_FXP,
	// constant
	parameter I2_PREC = I2_CONF.prec,
	parameter O_PREC = O_CONF.prec 
)(
	input wire					in1,
	input wire [I2_PREC-1:0]	in2,
	output wire [O_PREC-1:0]	out
);

	//***** internal parameter
	localparam I2_SIGN = I2_CONF.sign;



	//***** internal wires
	wire [I2_PREC-1:0]	out_tmp;



	//***** multiply
	generate
		//*** Input 2 can be (signed) integer
		if ( I2_SIGN ) begin : in2_int
			assign out_tmp
				= ( in1 )
					? in2
					: ~in2 + 1'b1;
			assign out = {{O_PREC-I2_PREC{out_tmp[I2_PREC-1]}}, out_tmp};

		end else begin : in2_bool
			// treat 0 as -1
			// 0 * 0 = 1
			// 0 * 1 = 0
			// 1 * 0 = 0
			// 1 * 1 = 1
			assign out = {{O_PREC-1{1'b0}}, !(in1^in2[0])};
		end
	endgenerate

endmodule
