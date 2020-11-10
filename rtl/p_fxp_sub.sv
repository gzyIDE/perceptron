/*
* <p_fxp_sub.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_fxp_sub #(
	// port configuration
	parameter dconf_t I1_CONF = `DEF_DCONF_INT,
	parameter dconf_t I2_CONF = `DEF_DCONF_INT,
	parameter dconf_t O_CONF = `DEF_DCONF_INT,
	// constant
	parameter I1_PREC = I1_CONF.prec,
	parameter I2_PREC = I2_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I1_PREC-1:0]		in1,
	input wire [I2_PREC-1:0]		in2,
	output wire						udf,
	output wire						ovf,
	output wire						rounded,
	output wire [O_PREC-1:0]		out
);

	//***** internal data representation
	localparam I1_SIGN = I1_CONF.sign;
	localparam I2_SIGN = I2_CONF.sign;
	localparam E_SIGN = I1_SIGN || I2_SIGN;
	localparam E_PREC = O_PREC + 1;
	localparam E_FRAC = O_CONF.frac;
	localparam dconf_t E_CONF 
		= dconf_t'{dtype: FXP, sign: E_SIGN, prec: E_PREC, frac: E_FRAC};

	//***** internal wires
	wire [O_PREC-1:0]				in1_ext;
	wire							in1_sign;
	wire [O_PREC-1:0]				in2_ext;
	wire							in2_sign;
	wire [O_PREC-1:0]				out_sub;



	//***** assign output
	assign udf = `Disable;
	assign rounded = `Disable;
	assign out = out_sub;



	//***** assign internal
	assign in1_sign = in1[I1_PREC-1];
	assign in2_sign = in2[I2_PREC-1];



	//***** extension
	generate
		//*** input 1
		if ( O_PREC > I1_PREC ) begin : ext1
			exp_fxp #(
				.I_CONF	( I1_CONF ),
				.O_CONF	( E_CONF )
			) exp_fxp (
				.in		( in1 ),
				.out	( in1_ext )
			);
		end else begin : no_ext1
			assign in1_ext = in1;
		end

		//*** input 2
		if ( O_PREC > I2_PREC ) begin : ext2
			exp_fxp #(
				.I_CONF	( I2_CONF ),
				.O_CONF	( E_CONF )
			) exp_fxp (
				.in		( in2 ),
				.out	( in2_ext )
			);
		end else begin : no_ext2
			assign in2_ext = in2;
		end
	endgenerate



	//***** calculation
	generate
		wire [E_PREC-1:0]		in1_tmp;
		wire [E_PREC-1:0]		in2_tmp;
		wire [E_PREC-1:0]		res_sub;
		case ( {I2_SIGN, I1_SIGN} )
			{`Disable, `Disable} : begin : type_uu
				assign in1_tmp = {1'b0, in1_ext};
				assign in2_tmp = {1'b0, in2_ext};
				assign res_sub = in1_tmp - in2_tmp;
				assign ovf = `Disable;
				assign out_sub 
					= ovf 
						? {O_PREC{1'b1}}
						: res_sub[O_PREC-1:0];
			end
			{`Disable, `Enable} : begin : type_us
				assign in1_tmp = {in1_sign, in1_ext};
				assign in2_tmp = {1'b0, in2_ext};
				assign res_sub = $signed(in1_tmp) - $signed(in2_tmp);
				assign ovf = in1_sign && !res_sub[O_PREC-1];
				assign out_sub
					= ovf
						? res_sub[E_PREC-1]
							? {1'b0, {O_PREC-1{1'b1}}}
							: {1'b1, {O_PREC-1{1'b0}}}
						: res_sub[O_PREC-1:0];
			end
			{`Enable, `Disable} : begin : type_su
				assign in1_tmp = {1'b0, in1_ext};
				assign in2_tmp = {in2_sign, in2_ext};
				assign res_sub = $signed(in1_tmp) - $signed(in2_tmp);
				assign ovf = in2_sign && res_sub[O_PREC-1];
				assign out_sub
					= ovf
						? res_sub[E_PREC-1]
							? {1'b0, {O_PREC-1{1'b1}}}
							: {1'b1, {O_PREC-1{1'b0}}}
						: res_sub[O_PREC-1:0];
			end
			{`Enable, `Enable} : begin : type_ss
				assign in1_tmp = {in1_sign, in1_ext};
				assign in2_tmp = {in2_sign, in2_ext};
				assign res_sub = $signed(in1_tmp) - $signed(in2_tmp);
				assign ovf 
					= ( in1_sign && !in2_sign && !res_sub[O_PREC-1] )
						|| ( !in1_sign && in2_sign && res_sub[O_PREC-1] );
				assign out_sub
					= ovf
						? res_sub[E_PREC-1]
							? {1'b0, {O_PREC-1{1'b1}}}
							: {1'b1, {O_PREC-1{1'b0}}}
						: res_sub[O_PREC-1:0];
			end
		endcase
	endgenerate
	
endmodule
