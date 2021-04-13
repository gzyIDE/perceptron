/*
* <slp_calc_weight_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"
`include "sim.vh"

//`define SIM_FXP
`define SIM_INT

module slp_calc_weight_test;
	parameter STEP =10;

`ifdef SIM_INT
	parameter dtype_t TYPE = INT;
	// input configuration
	parameter I_SIGN = `Enable;
	parameter I_PREC = 8;
	parameter I_FRAC = 0;
	// Learning Rate configuration
	parameter R_SIGN = `Disable;
	parameter R_PREC = 4;
	parameter R_FRAC = 0;
	// weight configuration
	parameter W_SIGN = `Enable;
	parameter W_PREC = 16;
	parameter W_FRAC = 0;
	// Prediction Result configuration
	parameter P_SIGN = `Enable;
	parameter P_PREC = 8;
	parameter P_FRAC = 0;
`else
	parameter dtype_t TYPE = FXP;
	// input configuration
	parameter I_SIGN = `Enable;
	parameter I_PREC = 8;
	parameter I_FRAC = 3;
	// Learning Rate configuration
	parameter R_SIGN = `Disable;
	parameter R_PREC = 5;
	parameter R_FRAC = 5;
	// weight configuration
	parameter W_SIGN = `Enable;
	parameter W_PREC = 14;
	parameter W_FRAC = 6;
	// Inference Result configuration
	parameter P_SIGN = `Enable;
	parameter P_PREC = 8;
	parameter P_FRAC = 3;
`endif

	//***** struct instantiation
	parameter dconf_t I_CONF 
		= dconf_t'{dtype: TYPE, sign: I_SIGN, prec: I_PREC, frac: I_FRAC};
	parameter dconf_t R_CONF 
		= dconf_t'{dtype: TYPE, sign: R_SIGN, prec: R_PREC, frac: R_FRAC};
	parameter dconf_t W_CONF 
		= dconf_t'{dtype: TYPE, sign: W_SIGN, prec: W_PREC, frac: W_FRAC};
	parameter dconf_t P_CONF 
		= dconf_t'{dtype: TYPE, sign: P_SIGN, prec: P_PREC, frac: P_FRAC};

	// simulation loop
	parameter LOOP = 1000;

	reg [I_PREC-1:0]	in;
	reg [R_PREC-1:0]	rate;
	reg [P_PREC-1:0]	error;
	reg [W_PREC-1:0]	weight;
	wire				udf;
	wire				ovf;
	wire				rounded;
	wire [W_PREC-1:0]	new_weight;



`ifdef SIM_FXP
	`include "fxp_util.svh"
	FxpUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_fxp;

	FxpUtils #(
		.CONF		( R_CONF ),
		.ATTR		( "rate" )
	) rate_fxp;

	FxpUtils #(
		.CONF		( W_CONF ),
		.ATTR		( "w" )
	) w_fxp;

	FxpUtils #(
		.CONF		( P_CONF ),
		.ATTR		( "p" )
	) error_fxp;

`elsif SIM_INT
	`include "int_util.svh"
	IntUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_int;

	IntUtils #(
		.CONF		( R_CONF ),
		.ATTR		( "rate" )
	) rate_int;

	IntUtils #(
		.CONF		( W_CONF ),
		.ATTR		( "w" )
	) w_int;

	IntUtils #(
		.CONF		( P_CONF ),
		.ATTR		( "p" )
	) error_int;
`endif

	
	slp_calc_weight #(
		.I_CONF		( I_CONF ),
		.R_CONF		( R_CONF ),
		.W_CONF		( W_CONF ),
		.P_CONF		( P_CONF )
	) calc_weight (
		.in			( in ),
		.rate		( rate ),
		.error		( error ),
		.weight		( weight ),
		.udf		( udf ),
		.ovf		( ovf ),
		.rounded	( rounded ),
		.new_weight	( new_weight )
	);



`ifdef SIM_FXP
	task check_weight_calc_fxp;
		real	delta;
		real	ans;
		real	res;
		begin
			delta = in_fxp.decode(in) * rate_fxp.decode(rate) * error_fxp.decode(error);
			ans = w_fxp.decode(weight) + delta;
			res = w_fxp.decode(new_weight);

			if ( udf || ovf || rounded ) begin
				check_weight_calc_imp(ans, res);
			end else begin
				if ( ans == res ) begin
					`SetCharBold
					`SetCharGreen
					$display("Ansewer: %f", res);
					$display("Inference OK");
					`ResetCharSetting
				end else begin
					`SetCharBold
					`SetCharRed
					$display("asn: %f, out: %f", ans, res);
					$display("Mult NG");
					`ResetCharSetting
				end
			end
		end
	endtask

	task check_weight_calc_imp;
		input real		ans;
		input real		res;
		begin
			if ( ans == res ) begin
				$display("result: %f", res);
				$display("exptected: %f", ans); 
				`SetCharBold
				`SetCharRed
				$display("Faluse Overflow Check!!");
				`ResetCharSetting
			end else begin
				$display("result: %f", res);
				$display("exptected: %f", ans); 
				`SetCharBold
				`SetCharYellow
				$display("Imprecise Result!!");
				`ResetCharSetting
			end
		end
	endtask
`elsif SIM_INT
	task check_weight_calc_int;
		int		delta;
		int		div;
		int		ans;
		int		res;
		begin
			//delta = in_int.decode(in) * rate_int.decode(rate) * error_int.decode(error);
			delta = in_int.decode(in) * error_int.decode(error);
			ans = w_int.decode(weight) + ( delta >>> R_CONF.prec);
			res = w_int.decode(new_weight);

			if ( udf || ovf || rounded ) begin
				check_weight_calc_imp(ans, res);
			end else begin
				if ( ans == res ) begin
					`SetCharBold
					`SetCharGreen
					$display("Answer: %d", res);
					$display("Inference OK");
					`ResetCharSetting
				end else begin
					`SetCharBold
					`SetCharRed
					$display("ans: %d, out: %d", ans, res);
					$display("Mult NG");
					`ResetCharSetting
				end
			end
		end
	endtask

	task check_weight_calc_imp;
		input int		ans;
		input int		res;
		begin
			if ( ans == res ) begin
				$display("result: %d", res);
				$display("exptected: %d", ans); 
				`SetCharBold
				`SetCharRed
				$display("Faluse Overflow Check!!");
				`ResetCharSetting
			end else begin
				$display("result: %d", res);
				$display("exptected: %d", ans); 
				`SetCharBold
				`SetCharYellow
				$display("Imprecise Result!!");
				`ResetCharSetting
			end
		end
	endtask
`endif



	/***** simulation body *****/
	initial begin
		in = {I_PREC{1'b0}};
		rate = {R_PREC{1'b0}};
		error = {P_PREC{1'b0}};
		weight = {W_PREC{1'b0}};

		#(STEP);
`ifdef SIM_FXP
		// input : 0.75
		in_fxp.set(8'b00000_110, in);
		// rate : 0.0625
		rate_fxp.set(5'b00010, rate);
		// error : -16
		error_fxp.set(8'b10000_000, error);
		// weight : 10
		w_fxp.set(12'b00001010_0000, weight);

		// check result
		#(STEP);
		//void'(in_fxp.decode(in));
		//void'(rate_fxp.decode(rate));
		//void'(error_fxp.decode(error));
		//void'(weight_fxp.decode(weight));
		//$write("New Weight -> ");
		//void'(weight_fxp.decode(new_weight));
		check_weight_calc_fxp;

		#(STEP);
		// input : 0.75
		in_fxp.set(8'b00000_110, in);
		// rate : 0.0625
		rate_fxp.set(5'b00010, rate);
		// error : 16
		error_fxp.set(8'b01110_000, error);
		// weight : 10
		w_fxp.set(14'b00001010_000000, weight);

		// check result
		#(STEP);
		//void'(in_fxp.decode(in));
		//void'(rate_fxp.decode(rate));
		//void'(error_fxp.decode(error));
		//void'(w_fxp.decode(weight));
		//$write("New Weight -> ");
		//void'(w_fxp.decode(new_weight));
		check_weight_calc_fxp;
`elsif SIM_INT
		// input: 2
		in_int.set(2, in);
		// rate : 3 (3bit right shift)
		rate_int.set(3, rate);
		// error: -16
		error_int.set(-16, error);
		// weight : 10
		w_int.set(10, weight);
		#(STEP);
		check_weight_calc_int;

		// input: 2
		in_int.set(2, in);
		// rate : 3 (3bit right shift)
		rate_int.set(3, rate);
		// error: -16
		error_int.set(20, error);
		// weight : 10
		w_int.set(10, weight);
		#(STEP);
		check_weight_calc_int;
`endif
	end

	`include "waves.vh"

endmodule
