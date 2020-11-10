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

module act_func_test;
	parameter Step = 10;
`ifdef SIM_INT
	parameter dtype_t TYPE = FXP;
	parameter SIGN = `Enable;
	parameter PREC = 8;
	parameter FRAC = 0;
	parameter actf_t ACT = ReLU;
	//parameter actf_t ACT = STEP;
`elsif SIM_FXP
	parameter dtype_t TYPE = FXP;
	parameter SIGN = `Enable;
	parameter PREC = 8;
	parameter FRAC = 3;
	parameter actf_t ACT = ReLU;
	//parameter actf_t ACT = STEP;
`endif

	// Simulation Loops
	parameter LOOP = 1000;

	reg [PREC-1:0]	in;
	wire [PREC-1:0]	out;


	//***** struct instantiation
	//*** port configuration
	parameter dconf_t CONF 
		= dconf_t'{dtype:TYPE, sign:SIGN, prec: PREC, frac: FRAC};


`ifdef SIM_FXP
	`include "fxp_util.svh"
	/* fixed point input */
	FxpUtils #(
		.CONF		( CONF ),
		.ACT		( ACT ),
		.ATTR		( "in" )
	) in_fxp;

	/* fixed point output */
	FxpUtils #(
		.CONF		( CONF ),
		.ACT		( ACT ),
		.ATTR		( "out" )
	) out_fxp;

`elsif SIM_INT
	`include "int_util.svh"
	/* Int input */
	IntUtils #(
		.CONF		( CONF ),
		.ACT		( ACT ),
		.ATTR		( "in" )
	) in_int;

	/* Int output */
	IntUtils #(
		.CONF		( CONF ),
		.ACT		( ACT ),
		.ATTR		( "out" )
	) out_int;
`endif



	/***** Activation Function *****/
	act_func #(
		.CONF	( CONF ),
		.ACT	( ACT )
	) act_func (
		.in		( in ),
		.out	( out )
	);


	/***** check function *****/
`ifdef SIM_FXP
	task check_fxp_result;
		real	ans;
		real	res;
		begin
			ans = in_fxp.act_func(in);
			res = out_fxp.decode(out);
			$display("ans: %f", ans);
			if ( ans == res ) begin
				`SetCharBold
				`SetCharGreen
				$display("Activation Function OK");
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharRed
				$display("Activation Function NG");
				`ResetCharSetting
			end
		end
	endtask
`elsif SIM_INT
	task check_int_result; 
		int ans;
		int res;
		begin
			ans = in_int.act_func(in);
			res = out_int.decode(out);
			$display("ans: %f", ans);
			if ( ans == res ) begin
				`SetCharBold
				`SetCharGreen
				$display("Activation Function OK");
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharRed
				$display("Activation Function NG");
				`ResetCharSetting
			end
		end
	endtask
`endif


	/***** simulation body *****/
	integer i;
	initial begin
		in = {PREC{1'b0}};
		#(Step);

`ifdef SIM_FXP
		// 3.5
		in_fxp.set(16'b000000000011_1000, in);
		#(Step);
		check_fxp_result;
		// -3.5
		in_fxp.set(16'b111111111101_1000, in);
		#(Step);
		check_fxp_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in_fxp.set_random(in);
			#(Step);
			check_fxp_result;
		end
`elsif SIM_INT
		// 3
		in_int.set(8'b0000_0011, in);
		#(Step);
		check_int_result;
		// -3
		in_int.set(8'b1111_1101, in);
		#(Step);
		check_int_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in_int.set_random(in);
			#(Step);
			check_int_result;
		end
`endif
	end

`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("ACF");
	end
`endif

endmodule
