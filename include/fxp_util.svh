/*
* <fxp_util.svh>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _FXP_UTIL_SVH_INCLUDED_
`define _FXP_UTIL_SVH_INCLUDED_

`include "perceptron.svh"

virtual class FxpUtils #( 
	parameter dconf_t CONF = `DEF_DCONF_FXP,
	parameter actf_t ACT = `DEF_ACT,
`ifdef SIMULATION
	parameter string ATTR = "in",	// direction
`endif
	parameter DISP = `Disable		// print decoded result
);
	//***** internal parameter
	localparam SIGN = CONF.sign;
	localparam PREC = CONF.prec;
	localparam FRAC = CONF.frac;
	parameter INT = PREC - FRAC;

	// return value with maximum absolute value
	static function [PREC-1:0] get_max (
		input			sign
	);

		if ( SIGN ) begin
			if ( sign ) begin
				get_max = {1'b1, {INT-1{1'b0}}, {FRAC{1'b0}}};
			end else begin
				get_max = {1'b0, {INT-1{1'b1}}, {FRAC{1'b1}}};
			end
		end else begin
			get_max = {PREC{1'b1}};
		end
	endfunction

	// return value with minimum absolute value
	static function [PREC-1:0] get_min (
		input			sign
	);

		if ( SIGN ) begin
			if ( sign ) begin
				get_min = {1'b1, {INT-1{1'b1}}, {FRAC{1'b1}}};
			end else begin
				get_min = {1'b0, {INT-1{1'b0}}, {FRAC{1'b0}}};
			end
		end else begin
			get_min = 0;
		end
	endfunction

`ifdef SIMULATION
	task set (
		input [PREC-1:0]		in,
		output [PREC-1:0]		dst
	);

		dst = in;
	endtask



	static task set_random (
		output [PREC-1:0]		dst
	);

		dst = $random;
	endtask



	static function real decode (
		input [PREC-1:0]		fxp
	);
		integer					div;
		reg signed [PREC-1:0]	fxp_sign;
		real					rn;

		div = 1 << FRAC;
		if ( SIGN ) begin
			fxp_sign = fxp;
			rn = $itor(fxp_sign) / div;
		end else begin
			rn = $itor(fxp) / div;
		end

		if ( DISP ) begin
			$display("%s, fixed: %x, float: %f", ATTR, fxp, rn);
		end

		decode = rn;
	endfunction



	static function check_max (
		input [PREC-1:0]		in
	);
		real					rn;
		real					max;

		rn = decode(in);
		//$write("MAX ");
		max = decode(get_max(in[PREC-1]));
		check_max = ( rn == max );
	endfunction



	static function real act_func (
		input [PREC-1:0]	in
	);
		real				rn;

		rn = decode(in);
		case (ACT)
			STEP : begin
				if ( SIGN ) begin
					if ( rn >= 0 ) begin
						act_func = 1.0;
					end else begin
						act_func = 0.0;
					end
				end else begin
					if ( rn >= decode({1'b1, {PREC-1{1'b0}}}) ) begin
						act_func = decode({PREC{1'b1}});
					end else begin
						act_func = decode({1'b0, {PREC-1{1'b1}}});
					end
				end
			end

			LINEAR : begin
				act_func = rn;
			end

			ReLU: begin
				if ( SIGN ) begin
					if ( rn > 0 ) begin
						act_func = rn;
					end else begin
						act_func = 0.0;
					end
				end else begin
					if ( rn > decode({1'b1, {PREC-1{1'b0}}}) ) begin
						act_func = rn;
					end else begin
						act_func = decode({1'b1, {PREC-1{1'b0}}});
					end
				end
			end

			SIGMOID : begin
				act_func = ($tanh(rn/2.0) + 1.0) / 2.0;
			end
		endcase
	endfunction



	static function real act_check (
		input real			in
	);

		case (ACT)
			STEP : begin
				if ( SIGN ) begin
					if ( in >= 0 ) begin
						act_check = 1.0;
					end else begin
						act_check = 0.0;
					end
				end else begin
					if ( in >= decode({1'b1, {PREC-1{1'b0}}}) ) begin
						act_check = decode({PREC{1'b1}});
					end else begin
						act_check = decode({1'b0, {PREC-1{1'b1}}});
					end
				end
			end

			LINEAR : begin
				act_check = in;
			end

			ReLU: begin
				if ( SIGN ) begin
					if ( in > 0 ) begin
						act_check = in;
					end else begin
						act_check = 0.0;
					end
				end else begin
					if ( in > decode({1'b1, {PREC-1{1'b0}}}) ) begin
						act_check = in;
					end else begin
						act_check = decode({1'b1, {PREC-1{1'b0}}});
					end
				end
			end

			SIGMOID : begin
				act_check = ($tanh(in/2.0) + 1.0) / 2.0;
			end
		endcase
	endfunction
`endif
endclass


// Fixed points calculation functions
`ifdef SIMULATION
class FxpCalc #(
	// input1
	parameter dconf_t I1_CONF = `DEF_DCONF_FXP,
	parameter string I1_ATTR = "in1",
	// input2
	parameter dconf_t I2_CONF = `DEF_DCONF_FXP,
	parameter string I2_ATTR = "in2"
);

	//***** internal parameters
	localparam I1_PREC = I1_CONF.prec;
	localparam I2_PREC = I2_CONF.prec;



	//***** class initialization
	//*** input 1
	FxpUtils #(
		.CONF	( I1_CONF ),
		.ATTR	( I1_ATTR )
	) in1_fxp;

	//*** input 2
	FxpUtils #(
		.CONF	( I2_CONF ),
		.ATTR	( I2_ATTR )
	) in2_fxp;



	//***** calculations
	function compare;
		input [I1_PREC-1:0]		in1;
		input [I2_PREC-1:0]		in2;
		real					ri1;
		real					ri2;
		begin
			ri1 = in1_fxp.decode(in1);
			ri2 = in2_fxp.decode(in2);

			compare = ( ri1 == ri2 );
		end
	endfunction

	function real mult;
		input [I1_PREC-1:0]		in1;
		input [I2_PREC-1:0]		in2;
		real					ri1;
		real					ri2;
		begin
			ri1 = in1_fxp.decode(in1);
			ri2 = in2_fxp.decode(in2);

			mult = ri1 * ri2;
		end
	endfunction

	function real add;
		input [I1_PREC-1:0]		in1;
		input [I2_PREC-1:0]		in2;
		real					ri1;
		real					ri2;
		begin
			ri1 = in1_fxp.decode(in1);
			ri2 = in2_fxp.decode(in2);

			add = ri1 + ri2;
		end
	endfunction

	function real sub;
		input [I1_PREC-1:0]		in1;
		input [I2_PREC-1:0]		in2;
		real					ri1;
		real					ri2;
		begin
			ri1 = in1_fxp.decode(in1);
			ri2 = in2_fxp.decode(in2);

			sub = ri1 - ri2;
		end
	endfunction
endclass
`endif

`endif // _FXP_UTIL_SVH_INCLUDED_
