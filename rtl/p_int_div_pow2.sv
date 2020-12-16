/*
* <p_int_div_pow2.sv>
* 
* Copyright (c) 2020 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_int_div_pow2 #(
	// shift width
	parameter SHIFT = 2,
	// carry up mode
	//		0: discard lower bits
	//		1: carry up if lower bits are greater than or equal (1<<n)/2
	//		2: carry up if lower bits are not zero
	parameter CARRYUP = 0,
	// port configuration
	parameter dconf_t I_CONF = `DEF_DCONF,
	parameter dconf_t O_CONF = `DEF_DCONF,
	// constant
	parameter I_PREC = I_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I_PREC-1:0]		in,
	output wire [SHIFT-1:0]		rem,
	output wire [O_PREC-1:0]	out
);

	//***** internal parameters
	localparam SIGN = I_CONF.sign;

	//***** internal wires 
	wire						in_sign;
	wire [SHIFT-1:0]			lower_bits;
	wire						lower_non_zero;
	wire						gt_half;		//greater than (1<<n)/2
	wire [I_PREC-1:0]			shift;
	wire [I_PREC-1:0]			div_res;



	//***** assign output 
	assign rem = lower_bits;



	//***** internal assign
	assign in_sign = in[I_PREC-1];
	assign lower_bits = in[SHIFT-1:0];
	assign lower_non_zero = |lower_bits;
	assign gt_half = lower_bits[SHIFT-1];



	//***** shifts
	generate
		if ( SIGN ) begin : s
			assign shift = {{SHIFT{in_sign}}, in[I_PREC-1:SHIFT]};
		end else begin : us
			assign shift = {{SHIFT{1'b0}}, in[I_PREC-1:SHIFT]};
		end

		case ( CARRYUP )
			0: begin: nocarry
				assign div_res = shift;
			end
			1: begin: gth
				assign div_res = shift + gt_half;
			end
			2: begin: nonzero
				assign div_rs = shift + lower_non_zero;
			end
		endcase
	endgenerate



	//***** shrink data precision
	generate
		if ( O_PREC < I_PREC ) begin : rdc
			wire			dummy_ovf;
			rdc_int #(
				.I_CONF		( I_CONF ),
				.O_CONF		( O_CONF )
			) inst (
				.in			( div_res ),
				.ovf		( dummy_ovf ),
				.out		( out )
			);
		end else begin
			assign out = div_res;
		end
	endgenerate

endmodule
