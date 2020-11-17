/*
* <slp_calc_bool_weight.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module slp_calc_bool_weight #(
	parameter dconf_t W_CONF = `DEF_DCONF_B,
	// constant
	parameter W_PREC = W_CONF.prec 
)(
	input wire					in,
	input wire 					error,
	input wire [W_PREC-1:0]		weight,
	output wire [W_PREC-1:0]	new_weight
);

	/***** assign output *****/
	assign new_weight = update_weight(in, error, weight);



	/***** update calculation *****/
	function [W_PREC-1:0] update_weight;
		input						in;
		input						error;	// == train signal
		input signed [W_PREC-1:0]	weight;	// must be signed
		reg							max;
		reg							w_sign;
		reg							min;
		reg							product_ie;	// in and error
		begin
			max = !weight[W_PREC-1] && (&weight[W_PREC-2:0]);
			min = weight[W_PREC-1] || !(|weight[W_PREC-2:0]);

			/*** input * error ***/
			// treat 0 as -1
			// 0 * 0 = 1
			// 0 * 1 = 0
			// 1 * 0 = 0
			// 1 * 1 = 1
			product_ie = !(in^error);

			case ( product_ie )
				1'b0 : begin
					update_weight 
						= min 
							? weight
							: weight - 1'b1;
				end
				1'b1 : begin
					update_weight 
						= max
							? weight
							: weight + 1'b1;
				end
			endcase
		end
	endfunction

endmodule
