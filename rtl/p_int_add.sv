/*
* <p_int_add.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_int_add #(
	// port configuration
	parameter dconf_t I1_CONF = `DEF_DCONF_INT,
	parameter dconf_t I2_CONF = `DEF_DCONF_INT,
	parameter dconf_t O_CONF = `DEF_DCONF_INT,
	// constant
	parameter I1_PREC = I1_CONF.prec,
	parameter I2_PREC = I2_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I1_PREC-1:0]	in1,
	input wire [I2_PREC-1:0]	in2,
	output wire					ovf,
	output wire [O_PREC-1:0]	out
);

	/***** internal data representation *****/
	localparam I1_SIGN = I1_CONF.sign;
	localparam I2_SIGN = I2_CONF.sign;
	localparam E_SIGN = I1_SIGN || I2_SIGN;
	localparam E_PREC = O_PREC + 1;

	/***** internal wires *****/
	wire						in1_sign;
	wire 						in2_sign;
	wire signed [E_PREC-1:0]	res_add;
	wire						u_res_sign;
	wire						s_res_sign;
	wire [O_PREC-1:0]			out_add;



	/***** assign output *****/
	assign out = out_add;



	/***** internal assigns *****/
	assign in1_sign = in1[I1_PREC-1];
	assign in2_sign = in2[I2_PREC-1];
	assign u_res_sign = res_add[E_PREC-1];
	assign s_res_sign = res_add[O_PREC-1];



	/***** calculation *****/
	generate
		case ( {I2_SIGN, I1_SIGN} )
			{`Disable, `Disable} : begin : type_uu
				assign res_add = in1 + in2;
				//assign out_add = res_add[O_PREC-1:0];
				assign ovf = u_res_sign;
				assign out_add 
					= ovf 
						? {O_PREC{1'b1}}
						: res_add[O_PREC-1:0];
			end

			{`Disable, `Enable} : begin : type_us
				wire signed [I1_PREC:0]	in1_tmp;
				wire signed [I2_PREC:0] in2_tmp;
				assign in1_tmp = {in1[I1_PREC-1], in1};
				assign in2_tmp = {1'b0, in2};
				assign res_add = in1_tmp + in2_tmp;
				//assign ovf 
				//	= (in1_sign && !u_res_sign && s_res_sign)
				//		|| (!in1_sign && ( s_res_sign || u_res_sign ));
				assign ovf = u_res_sign ^ s_res_sign;
					//= (in1_sign && ( u_res_sign ^ s_res_sign ))
					//	|| (!in1_sign && (s_res_sign ^ u_res_sign));
				assign out_add
					= ovf
						? res_add[E_PREC-1]
							? {1'b0, {O_PREC-1{1'b1}}}
							: {1'b1, {O_PREC-1{1'b0}}}
						: res_add[O_PREC-1:0];
			end

			{`Enable, `Disable} : begin : type_su
				wire signed [I1_PREC:0]	in1_tmp;
				wire signed [I2_PREC:0]	in2_tmp;
				assign in1_tmp = {1'b0, in1};
				assign in2_tmp = {in2[I2_PREC-1], in2};
				assign res_add = in1_tmp + in2_tmp;
				//assign ovf = !in2_sign && s_res_sign;
				//assign ovf
				//	= in2_sign && !u_res_sign && s_res_sign
				//		|| !in2_sign && ( s_res_sign || u_res_sign );
				assign ovf = u_res_sign ^ s_res_sign;
				assign out_add
					= ovf
						? u_res_sign
							? {1'b0, {O_PREC-1{1'b1}}}
							: {1'b1, {O_PREC-1{1'b0}}}
						: res_add[O_PREC-1:0];
			end

			{`Enable, `Enable} : begin : type_ss
				wire signed [I1_PREC-1:0]	in1_tmp;
				wire signed [I2_PREC-1:0]	in2_tmp;
				assign in1_tmp = in1;
				assign in2_tmp = in2;
				assign res_add = in1_tmp + in2_tmp;
				assign ovf 
					= ( !in1_sign && !in2_sign && s_res_sign )
						|| ( in1_sign && in2_sign && !s_res_sign );
				assign out_add
					= ovf
						? s_res_sign
							? {1'b0, {O_PREC-1{1'b1}}}
							: {1'b1, {O_PREC-1{1'b0}}}
						: res_add[O_PREC-1:0];
			end
		endcase
	endgenerate

endmodule
