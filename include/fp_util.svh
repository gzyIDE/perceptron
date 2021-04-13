/*
* <fp_util.svh>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _FP_UTIL_SVH_INCLUDED_
`define _FP_UTIL_SVH_INCLUDED_

`include "perceptron.svh"

virtual class FpUtils #( 
	parameter dconf_t CONF = `DEF_DCONF_FP,
	parameter actf_t ACT = `DEF_ACT,	// Activation Function
`ifdef SIMULATION
	parameter string ATTR = "in",		// direction
`endif
	parameter DISP = `Disable			// print decoded result
);
	//***** internal parameters
	localparam PREC = CONF.prec;
	localparam FRAC = CONF.frac;
	localparam EXP = PREC - FRAC - 1;
	localparam BIAS = (1 << (EXP-1)) - 1;



	//***** return value with maximum absolute value
	static function [PREC-1:0] get_max (
		input			sign
	);
		reg	[EXP-1:0]	exp;
		reg [FRAC-1:0]	frac;

		exp = {EXP{1'b1}};
		frac = {FRAC{1'b0}};
		get_max = {sign, exp, frac};
	endfunction



	//***** return value with minimum absolute value
	static function [PREC-1:0] get_min (
		input			sign
	);

		get_min = {sign, {PREC-1{1'b0}}};
	endfunction



`ifdef SIMULATION
	//***** set floating point value
	task set (
		input				sign,
		input [EXP-1:0]		exp,
		input [FRAC-1:0]	frac,
		output [PREC-1:0]	dst
	);

		dst = {sign, exp, frac};
	endtask



	//***** set random value
	static task set_random (
		output [PREC-1:0]	dst
	);
		reg					sign;
		reg [EXP-1:0]		exp;
		reg [FRAC-1:0]		frac;

		sign = $random;
		exp = $random;
		frac = $random;
		dst = {sign, exp, frac};
	endtask



	//***** decode floating point
	static function real decode (
		input [PREC-1:0]	fp
	);

		reg					sign;
		reg [EXP-1:0]		exp;
		reg [FRAC-1:0]		frac;
		integer				frac_ext;
		integer				shift;
		integer				mult;
		integer				div;
		real				rn;

		{sign, exp, frac} = fp;
		frac_ext = {1'b1, frac};
		if ( exp > BIAS + FRAC ) begin
			shift = exp - BIAS - FRAC;
			mult = 1 << shift;
			// TODO: calc shift before converting real type!!
			rn = (-1 ** sign ) * $itor(frac_ext) * mult;
		end else begin
			shift = BIAS + FRAC - exp;
			div = 1 << shift;
			rn = (-1 ** sign) * $itor(frac_ext) / div;
		end

		if ( ! (|(fp[PREC-2:0]))  ) begin
			rn = 0;
		end

		if ( DISP ) begin
			$display("%s, float: %x, float: %f", ATTR, fp, rn);
		end

		decode = rn;
	endfunction



	//***** check if given value is maximum of the type
	static function check_max (
		input [PREC-1:0]	in
	);

		real				rn;
		real				max;

		rn = decode(in);
		//$write("MAX ");
		max = decode(get_max(in[PREC-1]));
		check_max = ( rn == max );
	endfunction



	//***** activation function
	static function real act_func (
		input [PREC-1:0]	in
	);

		real				rn;

		rn = decode(in);
		case (ACT)
			STEP : begin
				if ( rn > 0 ) begin
					act_func = 1.0;
				end else begin
					act_func = 0.0;
				end
			end

			LINEAR : begin
				act_func = rn;
			end

			ReLU: begin
				if ( rn > 0 ) begin
					act_func = rn;
				end else begin
					act_func = 0.0;
				end
			end

			SIGMOID : begin
				act_func = ($tanh(rn/2.0) + 1.0) / 2.0;
			end
		endcase
	endfunction
`endif
endclass



// Floating point calculation functions
`ifdef SIMULATION
class FpCalc #(
	parameter dconf_t I1_CONF = `DEF_DCONF_FP,
	parameter string I1_ATTR = "in1",
	parameter dconf_t I2_CONF = `DEF_DCONFL_FP,
	parameter string I2_ATTR = "in2"
);

	//***** internal parameters
	localparam I1_PREC = I1_CONF.prec;
	localparam I2_PREC = I2_CONF.prec;



	//***** class initialization
	//*** input 1
	FpUtils #(
		.CONF	( I1_CONF ),
		.ATTR	( I1_ATTR )
	) in1_fp;

	//*** input 2
	FpUtils #(
		.CONF	( I2_CONF ),
		.ATTR	( I2_ATTR )
	) in2_fp;



	//***** calculations
	function compare (
		input [I1_PREC-1:0]		in1,
		input [I2_PREC-1:0]		in2
	);
		real					ri1;
		real					ri2;

		ri1 = in1_fp.decode(in1);
		ri2 = in2_fp.decode(in2);
		compare = ( ri1 == ri2 );
	endfunction

	function real mult (
		input [I1_PREC-1:0]		in1,
		input [I2_PREC-1:0]		in2
	);
		real					ri1;
		real					ri2;

		ri1 = in1_fp.decode(in1);
		ri2 = in2_fp.decode(in2);
		mult = ri1 * ri2;
	endfunction

	function real add (
		input [I1_PREC-1:0]		in1,
		input [I2_PREC-1:0]		in2
	);
		real					ri1;
		real					ri2;

		ri1 = in1_fp.decode(in1);
		ri2 = in2_fp.decode(in2);
		add = ri1 + ri2;
	endfunction

	function real sub (
		input [I1_PREC-1:0]		in1,
		input [I2_PREC-1:0]		in2
	);
		real					ri1;
		real					ri2;

		ri1 = in1_fp.decode(in1);
		ri2 = in2_fp.decode(in2);

		sub = ri1 - ri2;
	endfunction

endclass
`endif

`endif // _FP_UTIL_SVH_INCLUDED_
