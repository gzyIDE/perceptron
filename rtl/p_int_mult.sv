/*
* <p_int_mult.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"

module p_int_mult #(
	// port configuration
	parameter dconf_t I1_CONF = `DEF_DCONF,
	parameter dconf_t I2_CONF = `DEF_DCONF,
	parameter dconf_t O_CONF = `DEF_DCONF,
	// constant
	parameter I1_PREC = I1_CONF.prec,
	parameter I2_PREC = I2_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I1_PREC-1:0]		in1,
	input wire [I2_PREC-1:0]		in2,
	output wire						ovf,
	output wire [O_PREC-1:0]		out
);

	//***** internal data representation
	localparam I1_SIGN = I1_CONF.sign;
	localparam I2_SIGN = I2_CONF.sign;
	localparam E_SIGN = I1_SIGN || I2_SIGN;
	localparam E_PREC = I1_PREC + I2_PREC;
	localparam dconf_t E_CONF
		= dconf_t'{dtype: INT, sign: E_SIGN, prec: E_PREC, frac: 0};

	//***** internal wires
	wire [E_PREC-1:0]				res_mult;



	/***** calculation *****/
	generate
		case ( {I2_SIGN, I1_SIGN} )
			{`Disable, `Disable} : begin : type_uu
				assign res_mult = in2 * in1;
			end
			{`Disable, `Enable} : begin : type_us
				assign res_mult = $signed({1'b0, in2}) * $signed(in1);
			end
			{`Enable, `Disable} : begin : type_su
				assign res_mult = $signed(in2) * $signed({1'b0, in1});
			end
			{`Enable, `Enable} : begin : type_ss
				assign res_mult = $signed(in2) * $signed(in1);
			end
		endcase
	endgenerate



	//***** shrink/expand data for output
	generate
		if ( O_PREC > E_PREC ) begin : exp
			exp_int #(
				.I_CONF ( E_CONF ),
				.O_CONF ( O_CONF )
			) inst (
				.in		( res_mult ),
				.out	( out )
			);

			assign ovf = `Disable;
		end else if ( O_PREC < E_PREC ) begin : rdc
			rdc_int #(
				.I_CONF	( E_CONF ),
				.O_CONF	( O_CONF )
			) inst (
				.in		( res_mult ),
				.ovf	( ovf ),
				.out	( out )
			);

		end else begin : thr
			assign out = res_mult;
			assign ovf = `Disable;
		end
	endgenerate

endmodule
