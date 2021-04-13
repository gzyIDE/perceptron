/*
* <p_add_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"
`include "sim.vh"

`define SIM_FXP
//`define SIM_INT

module p_add_test;
	parameter STEP = 10;
`ifdef SIM_INT
	parameter dtype_t TYPE = INT;
	// input1 configuration
	parameter I1_SIGN = `Enable;	// 0 : unsigned; 1 : signed (for FXP)
	parameter I1_PREC = 8;			// input precision
	parameter I1_FRAC = 0;			// exponet of input
	// input2 configuration
	parameter I2_SIGN = `Enable;
	parameter I2_PREC = 8;
	parameter I2_FRAC = 0;
	// output configuration
	parameter O_SIGN = I1_SIGN || I2_SIGN;
	parameter O_PREC = `Max(I1_PREC,I2_PREC);
	parameter O_FRAC = `Max(I1_FRAC,I2_FRAC);
`elsif SIM_FXP
	parameter dtype_t TYPE = FXP;
	// input1 configuration
	parameter I1_SIGN = `Enable;	// 0 : unsigned; 1 : signed (for FXP)
	parameter I1_PREC = 8;			// input precision
	parameter I1_FRAC = 3;			// exponet of input
	// input2 configuration
	parameter I2_SIGN = `Enable;
	parameter I2_PREC = 16;
	parameter I2_FRAC = 4;
	// output configuration
	parameter O_SIGN = I1_SIGN || I2_SIGN;
	parameter O_PREC = `Max(I1_PREC,I2_PREC);
	parameter O_FRAC = `Max(I1_FRAC,I2_FRAC);
`endif

	// Simulation Loops
	parameter LOOP = 1000;

	reg [I1_PREC-1:0]	in1;
	reg [I2_PREC-1:0]	in2;
	wire				udf;
	wire				ovf;
	wire				rounded;
	wire [O_PREC-1:0]	out;

	//***** struct instantiation
	//*** port configuration
	parameter dconf_t I1_CONF 
		= dconf_t'{dtype:TYPE, sign:I1_SIGN, prec: I1_PREC, frac: I1_FRAC};
	parameter dconf_t I2_CONF 
		= dconf_t'{dtype:TYPE, sign:I2_SIGN, prec: I2_PREC, frac: I2_FRAC};
	parameter dconf_t O_CONF 
		= dconf_t'{dtype:TYPE, sign: O_SIGN, prec: O_PREC, frac: O_FRAC};


	//***** Utilities (include FxpUtils, IntUtils)
`ifdef SIM_FXP
	`include "fxp_util.svh"

	//*** Fixed Point input1
	FxpUtils #(
		.CONF		( I1_CONF ),
		.ATTR		( "in1" )
	) in1_fxp;

	//*** Fixed Point input2
	FxpUtils #(
		.CONF		( I2_CONF ),
		.ATTR		( "in2" )
	) in2_fxp;

	//*** Fixed point output
	FxpUtils #(
		.CONF		( O_CONF ),
		.ATTR		( "out" )
	) out_fxp;

	//*** in1 and in2 calculation
	FxpCalc #(
		.I1_CONF	( I1_CONF ),
		.I2_CONF	( I2_CONF )
	) fxp_calc;

	//*** class instanciate
	initial begin
		fxp_calc = new;
	end
`elsif SIM_INT
	`include "int_util.svh"

	//*** Int input1
	IntUtils #(
		.CONF		( I1_CONF ),
		.ATTR		( "in1" )
	) in1_int;

	//*** Int input2
	IntUtils #(
		.CONF		( I2_CONF ),
		.ATTR		( "in2" )
	) in2_int;

	//*** Int output
	IntUtils #(
		.CONF		( O_CONF ),
		.ATTR		( "out" )
	) out_int;

	//*** Int calculation
	IntCalc #(
		.I1_CONF	( I1_CONF ),
		.I2_CONF	( I2_CONF )
	) int_calc;

	//*** class instanciate
	initial begin
		int_calc = new;
	end
`endif



	//***** Adder Module (Type selectable)
	p_add #(
		.I1_CONF	( I1_CONF ),
		.I2_CONF	( I2_CONF ),
		.O_CONF		( O_CONF )
	) add (
		.*
	);



	//***** check functions
`ifdef SIM_FXP
	//*** Fixed Point
	task check_fxp_result;
		real		ans;	// answer from testbench
		real		res;	// result from module
		begin
			ans = fxp_calc.add(in1,in2);
			res = out_fxp.decode(out);

			$display("ans: %f", ans);
			if ( ans == res ) begin
				`SetCharBold
				`SetCharGreen
				$display("Add OK");
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharRed
				$display("Add NG");
				`ResetCharSetting
			end
		end
	endtask

	//*** check imprecise result
	task check_fxp_imp;
		real		ans;	// answer from testbench
		real		res;	// result from module
		begin
			ans = fxp_calc.add(in1,in2);
			res = out_fxp.decode(out);
			$display("ans: %f", ans);
			`SetCharBold
			`SetCharYellow
			$display("Result rounded");
			`ResetCharSetting
		end
	endtask

`elsif SIM_INT
	//*** Integer
	task check_int_result;
		int ans;
		int res;
		begin
			ans = int_calc.add(in1, in2);
			res = out_int.decode(out);

			$display("ans: %d", ans);
			if ( ans == res ) begin
				`SetCharBold
				`SetCharGreen
				$display("Add OK");
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharRed
				$display("res: %d", res);
				$display("Add NG");
				`ResetCharSetting
			end
		end
	endtask

	//*** check imprecise result
	task check_int_imp;
		int		ans;	// answer from testbench
		int		res;	// result from module
		begin
			ans = int_calc.add(in1, in2);
			res = out_int.decode(out);
			if ( ans == res ) begin
				$display("result: %d", res);
				$display("exptected: %d", ans); 
				`SetCharBold
				`SetCharRed
				$display("False Overflow Check!!");
				`ResetCharSetting
			end else begin
				$display("result: %d", res);
				$display("exptected: %d", ans); 
				`SetCharBold
				`SetCharYellow
				$display("Result Ruonded!!");
				`ResetCharSetting
			end
		end
	endtask
`endif

	//***** simulation body
	integer i;
	initial begin
		in1 = {I1_PREC{1'b0}};
		in2 = {I2_PREC{1'b0}};
		#(STEP);

`ifdef SIM_FXP
		// 3.5
		in1_fxp.set(8'b00011_100, in1);
		// 2.0
		in2_fxp.set(16'b000000000010_0000, in2);
		#(STEP);
		check_fxp_result;

		// 15.75
		in1_fxp.set(8'b01111_100, in1);
		// 31.125
		in2_fxp.set(16'b000000011111_0010, in2);
		#(STEP);
		check_fxp_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in1_fxp.set_random(in1);
			in2_fxp.set_random(in2);
			#(STEP);
			if ( udf || ovf || rounded ) begin
				check_fxp_imp;
			end else begin
				check_fxp_result;
			end
		end
`elsif SIM_INT
		in1 = 3;
		in2 = 2;
		#(STEP);
		check_int_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in1 = $random();
			in2 = $random();
			#(STEP);
			if ( udf || ovf || rounded ) begin
				check_int_imp;
			end else begin
				check_int_result;
			end
		end
`endif

		#(STEP);
		$finish;
	end

	`include "waves.vh"

endmodule
