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
	// round up mode
	//		0: discard lower bits
	//		1: round up if lower bits are greater than or equal (1<<n)/2
	//		2: round up if lower bits are not zero
	parameter ROUND = 0,
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
	assign rem = in[SHIFT-1:0];



	//***** shifts
	// -1: 1111 : 0
	// -2: 1110 : -1
	// -3: 1101 : -1
	// -4: 1100 : 0

	// 0:  0000 : 0
	// -1: 1111 : 0
	// -2: 1110 : -1
	// -3: 1101 : -1

	// 0:  0000 : 0		-> 11
	// -1: 1111 : 0		-> 10
	// -2: 1110 : 0		-> 01
	// -3: 1101 : 0		-> 00
	// -4: 1100 : -1
	// -5: 1011 : -1
	// -6: 1010 : -1
	// -7: 1001 : -1
	// -8: 1000 : -1
	generate
		if ( SIGN ) begin : s
			assign in_sign = in[I_PREC-1];
			assign lower_bits = 
				( in_sign )
					? in[SHIFT-1:0] - 1'b1
					: in[SHIFT-1:0];
			assign gt_half = 
				( in_sign )
					? !lower_bits[SHIFT-1]
					: lower_bits[SHIFT-1];
			assign lower_non_zero =
				( in_sign )
					? ! (&lower_bits)
					: |lower_bits;
			assign shift = 
				( in_sign )
					? {{SHIFT{1'b1}}, in[I_PREC-1:SHIFT]} + 1'b1
					: {{SHIFT{1'b0}}, in[I_PREC-1:SHIFT]};
		end else begin : us
			assign in_sign = `Low;
			assign lower_bits = in[SHIFT-1:0];
			assign gt_half = lower_bits[SHIFT-1];
			assign lower_non_zero = |lower_bits;
			assign shift = {{SHIFT{1'b0}}, in[I_PREC-1:SHIFT]};
		end

		case ( ROUND )
			0: begin: noround
				assign div_res = shift;
			end
			1: begin: gth
				//assign div_res = shift + gt_half;
				assign div_res = 
					( in_sign )
						? shift - gt_half
						: shift + gt_half;
			end
			2: begin: nonzero
				//assign div_res = shift + lower_non_zero;
				assign div_res =
					( in_sign )
						? shift - lower_non_zero
						: shift + lower_non_zero;
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
