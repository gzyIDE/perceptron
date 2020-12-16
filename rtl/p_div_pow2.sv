/*
* <p_div_pow2.sv>
* 
* Copyright (c) 2020 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

// shift based divider
module p_div_pow2 #(
	// shift width
	parameter SHIFT = 2,
	// carry up mode
	//		0: discard lower bits
	//		1: carry up if lower bits are greater than or equal (1<<n)/2
	//		2: carry up if lower bits are not zero
	parameter CARRYUP = 0,
	// port configuration
	parameter dconf_t I_CONF = `DEF_DCONF,
	parameter dconf_t O_CONF = `DEF_DCONF
)(
	input wire [I_CONF.prec-1:0]	in,
	output wire [SHIFT-1:0]			rem,
	output wire [O_CONF.prec-1:0]	out
);

	generate
		case ( I_CONF.dtype )
			BOOL : begin : t_bool
				assign out = {CONF.prec{1'b0}};
			end
			INT : begin : t_int
				p_int_div_pow2 #(
					.SHIFT		( SHIFT ),
					.CARRYUP	( CARRYUP ),
					.I_CONF		( I_CONF ),
					.O_CONF		( O_CONF )
				) simple_div (
					.in			( in ),
					.rem		( rem ),
					.out		( out )
				);
			end

			FXP : begin : t_fxp
				// (same module as int is sufficient)
				p_int_div_pow2 #(
					.SHIFT		( SHIFT ),
					.CARRYUP	( CARRYUP ),
					.I_CONF		( I_CONF ),
					.O_CONF		( O_CONF )
				) simple_div (
					.in			( in ),
					.rem		( rem ),
					.out		( out )
				);
			end

			FP : begin : t_fp
				// Not Implemented Yet
			end
		endcase
	endgenerate

endmodule
