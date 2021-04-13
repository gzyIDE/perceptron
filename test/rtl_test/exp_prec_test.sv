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

module exp_prec_test;
	parameter STEP = 10;
`ifdef SIM_INT
	// data type
	parameter dtype_t TYPE = INT;
	parameter SIGN = `Enable;	// for fixed point
	// input
	parameter I_PREC = 8;
	parameter I_FRAC = 0;
	// Output configuration
	parameter O_PREC = 16;
	parameter O_FRAC = 0;
`elsif SIM_FXP
	// data type
	parameter dtype_t TYPE = FXP;
	parameter SIGN = `Enable;	// for fixed point
	// input
	parameter I_PREC = 8;
	parameter I_FRAC = 3;
	// Output configuration
	parameter O_PREC = 16;
	parameter O_FRAC = 4;
`endif

	// Simulation Loop
	parameter LOOP = 1000;

	reg [I_PREC-1:0]		in;
	wire [O_PREC-1:0]		out;


	//***** Port configuration
	parameter dconf_t I_CONF 
		= dconf_t'{dtype:TYPE, sign: SIGN, prec: I_PREC, frac: I_FRAC};
	parameter dconf_t O_CONF 
		= dconf_t'{dtype:TYPE, sign: SIGN, prec: O_PREC, frac: O_FRAC};



	/***** expand *****/
	exp_prec #(
		.I_CONF		( I_CONF ),
		.O_CONF		( O_CONF )
	) exp_prec (
		.in			( in ),
		.out		( out )
	);



	/***** simulation utils *****/
`ifdef SIM_FXP
	`include "fxp_util.svh"

	//*** Fixed Point input1
	FxpUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_fxp;

	//*** Fixed point output
	FxpUtils #(
		.CONF		( O_CONF ),
		.ATTR		( "out" )
	) out_fxp;
`elsif SIM_INT
	`include "int_util.svh"

	//*** Int input1
	IntUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_int;

	//*** Int output
	IntUtils #(
		.CONF		( O_CONF ),
		.ATTR		( "out" )
	) out_int;
`endif



	//***** check functions
`ifdef SIM_FXP
	//*** Fixed Point
	task check_fxp_result;
		real		ans;	// answer from testbench
		real		res;	// result from module
		begin
			ans = in_fxp.decode(in);
			res = out_fxp.decode(out);

			$display("ans: %f", ans);
			if ( ans == res ) begin
				`SetCharGreenBold
				$display("Expand Precision OK");
				`ResetCharSetting
			end else begin
				`SetCharRedBold
				$display("Expand Precision NG");
				`ResetCharSetting
			end
		end
	endtask

`elsif SIM_INT
	//*** Integer
	task check_int_result;
		int ans;
		int res;
		begin
			ans = in_int.decode(in);
			res = out_int.decode(out);

			$display("ans: %d", ans);
			if ( ans == res ) begin
				`SetCharGreenBold
				$display("Expand Precision OK");
				`ResetCharSetting
			end else begin
				`SetCharRedBold
				$display("res: %d", res);
				$display("Expand Precision NG");
				`ResetCharSetting
			end
		end
	endtask

`endif



	/***** testvector main *****/
	integer i;
	initial begin
		in = {I_PREC{1'b0}};
		#(STEP);

`ifdef SIM_FXP
		// 1.75
		in_fxp.set(8'b00001_110, in);
		#(STEP);
		check_fxp_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in_fxp.set_random(in);
			#(STEP);
			check_fxp_result;
		end
`elsif SIM_INT
		// 2
		in_int.set(2, in);
		#(STEP);
		check_int_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in_int.set_random(in);
			#(STEP);
			check_int_result;
		end
`endif

		$finish;
	end

	`include "waves.vh"

endmodule
