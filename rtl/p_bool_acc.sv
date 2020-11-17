/*
* <p_bool_acc.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_bool_acc #(
	parameter IN = 8,
	// port configuration
	parameter dconf_t CONF = `DEF_DCONF,
	// constant
	parameter PREC = CONF.prec
)(
	input wire [IN-1:0][PREC-1:0]	in,
	output wire [PREC-1:0]			out
);

	//***** internal parameters
	localparam CNT = $clog2(PREC) + 1;

	//***** internal wires
	wire [IN-1:0]					in_tmp;
	wire [CNT-1:0]					zero_cnt;
	wire [CNT-1:0]					one_cnt;
	wire signed [PREC-1:0]			acc_result;



	//***** assign output
	assign acc_result = one_cnt - zero_cnt;
	assign out = acc_result;



	//***** bit reshape
	generate
		genvar gi;
		for ( gi = 0; gi < IN; gi = gi + 1 ) begin : LP_bit
			assign in_tmp[gi] = in[gi][0];
		end
	endgenerate



	//***** count bits
	cnt_bits #(
		.IN		( IN ),
		.ACT	( 1'b0 )
	) count0 (
		.in		( in_tmp ),
		.out	( zero_cnt )
	);

	cnt_bits #(
		.IN		( IN ),
		.ACT	( 1'b1 )
	) count1 (
		.in		( in_tmp ),
		.out	( one_cnt )
	);

endmodule
