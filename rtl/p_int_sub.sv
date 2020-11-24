/*
* <p_int_sub.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_int_sub #(
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

	//***** internal data representation
	localparam I1_SIGN = I1_CONF.sign;
	localparam I2_SIGN = I2_CONF.sign;
	localparam E_SIGN = I1_SIGN || I2_SIGN;
	localparam E_PREC = O_PREC+1;

	//***** internal wires
	wire						in1_sign;
	wire 						in2_sign;
	wire signed [E_PREC-1:0]	res_sub;
	wire						res_sign;
	wire						u_res_sign;
	wire						s_res_sign;
	wire [O_PREC-1:0]			out_sub;



	//***** assign output
	assign out = out_sub;



	//***** internal assigns
	assign in1_sign = in1[I1_PREC-1];
	assign in2_sign = in2[I2_PREC-1];
	assign res_sign = res_sub[E_PREC-1];
	assign u_res_sign = res_sub[E_PREC-1];
	assign s_res_sign = res_sub[O_PREC-1];



	//***** calculation
	generate
		case ( {I2_SIGN, I1_SIGN} )
			//*** rs2: Unsigned, rs1: Unsigned
			{`Disable, `Disable} : begin : type_uu
				assign res_sub = in1 - in2;
				assign ovf = u_res_sign;
				assign out_sub 
					= ovf 
						? {O_PREC{1'b0}}
						: res_sub[O_PREC-1:0];
			end

			//*** rs2: Unsigned, rs1: Signed
			{`Disable, `Enable} : begin : type_us
				wire signed [I1_PREC:0]	in1_ext;
				wire signed [I2_PREC:0]	in2_ext;
				assign in1_ext = {in1[I1_PREC-1], in1};
				assign in2_ext = {1'b0, in2};
				assign res_sub = in1_ext - in2_ext;
				//assign ovf = in1_sign && !res_sign;
				assign ovf = s_res_sign ^ u_res_sign;
					//= (in1_sign && (u_res_sign ^ s_res_sign))
					//	|| (!in1_sign && (u_res_sign ^ s_res_sign));
				assign out_sub
					= ovf
						? {1'b1, {O_PREC-1{1'b0}}}
						: res_sub[O_PREC-1:0];
			end

			//*** rs2: Signed, rs1: Unsigned
			{`Enable, `Disable} : begin : type_su
				wire signed [I1_PREC-1:0]	in1_ext;
				wire signed [I2_PREC-1:0]	in2_ext;
				assign in1_ext = {1'b0, in1};
				assign in2_ext = {in2[I2_PREC-1], in2};
				assign res_sub = in1_ext - in2_ext;
				assign ovf
					= (in1[I1_PREC-1] && !s_res_sign)
						|| (!in1[I1_PREC-1] && s_res_sign)
						|| (in1[I1_PREC-1] && in2_sign && u_res_sign);
				assign out_sub
					= ovf
						? {1'b0, {O_PREC-1{1'b1}}}
						: res_sub[O_PREC-1:0];
			end

			//*** rs2: Signed, rs1: Signed
			{`Enable, `Enable} : begin : type_ss
				wire signed [I1_PREC-1:0]	in1_tmp;
				wire signed [I2_PREC-1:0]	in2_tmp;
				assign in1_tmp = in1;
				assign in2_tmp = in2;
				assign res_sub = in1_tmp - in2_tmp;
				assign ovf 
					= ( in1_sign && !in2_sign && !s_res_sign )
						|| ( !in1_sign && in2_sign && s_res_sign );
				assign out_sub
					= ovf
						? res_sign
							? {1'b1, {O_PREC-1{1'b0}}}
							: {1'b0, {O_PREC-1{1'b1}}}
						: res_sub[O_PREC-1:0];
			end
		endcase
	endgenerate

endmodule
