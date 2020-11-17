/*
* <p_acc.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_acc #(
	parameter IN = 5,				// # of inputs
	parameter dconf_t CONF = `DEF_DCONF
)(
	input wire [IN-1:0][CONF.prec-1:0]	in,
	output wire							udf,
	output wire							ovf,
	output wire							rounded,
	output wire [CONF.prec-1:0]			out
);

	generate
		case ( CONF.dtype )
			BOOL : begin : t_bool
				p_bool_acc #(
					.IN			( IN ),
					.CONF		( CONF )
				) acc (
					.in			( in ),
					.out		( out )
				);
				
				assign udf = `Disable;
				assign ovf = `Disable;
				assign rounded = `Disable;
			end

			INT : begin : t_int
				p_int_acc #(
					.IN			( IN ),
					.CONF		( CONF )
				) acc (
					.in			( in ),
					.ovf		( ovf ),
					.out		( out )
				);

				assign udf = `Disable;
				assign rounded = `Disable;
			end

			FXP : begin : t_fxp
				p_fxp_acc #(
					.IN			( IN ),
					.CONF		( CONF )
				) acc (
					.in			( in ),
					.udf		( udf ),
					.ovf		( ovf ),
					.rounded	( rounded ),
					.out		( out )
				);
			end

			FP : begin : t_fp
			end

		endcase
	endgenerate
	
endmodule
