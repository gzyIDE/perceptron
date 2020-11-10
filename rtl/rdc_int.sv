/*
* <rdc_int.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module rdc_int #(
	// port configuration
	parameter dconf_t I_CONF = `DEF_DCONF_INT,
	parameter dconf_t O_CONF = `DEF_DCONFS_INT,
	// constant
	parameter I_PREC = I_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I_PREC-1:0]		in,
	output wire					ovf,
	output wire [O_PREC-1:0]	out
);

	//***** internal parameters
	localparam SIGN = I_CONF.sign;
	localparam DIFF = I_PREC - O_PREC;



	//***** assign output
	assign {ovf, out} = rdc_int_func(in);



	//***** convert function
	localparam RDC_INT_FUNC = O_PREC + 1;
	function [RDC_INT_FUNC-1:0] rdc_int_func;
		input [I_PREC-1:0]		in;
		reg						sign;
		reg [DIFF-1:0]			int_high;
		reg [O_PREC-1:0]		out;
		reg						ovf;
		begin
			sign = in[I_PREC-1];

			if ( SIGN ) begin
				int_high = in[(I_PREC-1)-1:(I_PREC-1)-DIFF];
				ovf = sign ? !(&int_high) : |int_high;
				case ({ovf, sign})
					2'b00 : begin
						out = {1'b0, in[O_PREC-2:0]};
					end
					2'b01 : begin
						out = {1'b1, in[O_PREC-2:0]};
					end
					2'b10 : begin
						out = {1'b0, {O_PREC-1{1'b1}}};
					end
					2'b11 : begin
						out = {1'b1, {O_PREC-1{1'b0}}};
					end
				endcase
			end else begin
				int_high = in[I_PREC-1:I_PREC-DIFF];
				ovf = |int_high;
				out = 
					ovf
						? {O_PREC{1'b1}}
						: in[O_PREC-1:0];
			end

			rdc_int_func = {ovf, out};
		end
	endfunction

endmodule
