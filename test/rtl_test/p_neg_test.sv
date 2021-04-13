/*
* <p_neg_test.sv>
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

module p_neg_test;
	parameter STEP = 10;
`ifdef SIM_INT
	parameter dtype_t TYPE = INT;
	parameter SIGN = `Enable;
	parameter PREC = 8;
	parameter FRAC =  0;
`elsif SIM_FXP
	parameter dtype_t TYPE = FXP;
	parameter SIGN = `Enable;
	parameter PREC = 8;
	parameter FRAC =  3;
`endif

	// Simulation Loops
	parameter LOOP = 1000; 

	reg [PREC-1:0]		in;
	wire [PREC-1:0]		out;

	//***** Struction instantiation
	parameter dconf_t CONF = 
		dconf_t'{dtype: TYPE, sign: SIGN, prec: PREC, frac: FRAC};

	//***** Utilities (include FxpUtils, IntUtils)
`ifdef SIM_FXP
	`include "fxp_util.svh"

	//*** Fixed Point
	FxpUtils #(
		.CONF	( CONF ),
		.ATTR	( "io" )
	) io_fxp;
`elsif SIM_INT
	`include "int_util.svh"

	//*** Int calculation
	IntUtils #(
		.CONF	( CONF ),
		.ATTR	( "in" )
	) io_int;
`endif



	//***** Neg module
	p_neg #(
		.CONF	( CONF )
	) p_net (
		.in		( in ),
		.out	( out )
	);



	//***** check functions
`ifdef SIM_FXP
	task check_fxp_result;
		real	ans;
		real 	res;
		bit		rounded;
		begin
			ans = - io_fxp.decode(in);
			res = io_fxp.decode(out);
			rounded = io_fxp.check_max(in);

			if ( ans == res ) begin
				`SetCharGreenBold
				$display("ans: %f", ans);
				$display("Neg OK");
				`ResetCharSetting
			end else if ( rounded ) begin
				`SetCharYellowBold
				$display("Result: %f, Expected: %f", res, ans);
				$display("Result Rounded");
				`ResetCharSetting
			end else begin
				`SetCharRedBold
				$display("Result: %f, Expected: %f", res, ans);
				$display("Neg NG");
				`ResetCharSetting
			end
		end
	endtask
`elsif SIM_INT
	task check_int_result;
		int	ans;
		int res;
		bit	rounded;
		begin
			ans = - io_int.decode(in);
			res = io_int.decode(out);
			rounded = io_int.check_max(in);

			if ( ans == res ) begin
				`SetCharGreenBold
				$display("ans: %d", ans);
				$display("Neg OK");
				`ResetCharSetting
			end else if ( rounded ) begin
				`SetCharYellowBold
				$display("Result: %d, Expected: %d", res, ans);
				$display("Result Rounded (OK)");
				`ResetCharSetting
			end else begin
				`SetCharRedBold
				$display("Result: %d, Expected: %d", res, ans);
				$display("Neg NG");
				`ResetCharSetting
			end
		end
	endtask
`endif



	//***** Simulation body
	integer i;
	initial begin
		in = {PREC{1'b0}};
		#(STEP);

`ifdef SIM_FXP
		// 3.5
		io_fxp.set(8'b00011_100, in);
		#(STEP);
		check_fxp_result;

		// 15.75
		io_fxp.set(8'b01111_100, in);
		#(STEP);
		check_fxp_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			io_fxp.set_random(in);
			#(STEP);
			check_fxp_result;
		end
`elsif SIM_INT
		io_int.set(3, in);
		#(STEP);
		check_int_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			io_int.set_random(in);
			#(STEP);
			check_int_result;
		end
`endif
	end

	`include "waves.vh"

endmodule
