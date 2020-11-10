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

module rdc_prec_test;
	parameter STEP = 10;
`ifdef SIM_INT
	parameter dtype_t TYPE = INT;
	parameter SIGN = `Enable;	// for fixed point
	// input
	parameter I_PREC = 16;
	parameter I_FRAC = 0;
	// Output configuration
	parameter O_PREC = 8;
	parameter O_FRAC = 0;
`elsif SIM_FXP
	// data type
	parameter dtype_t TYPE = FXP;
	parameter SIGN = `Enable;	// for fixed point
	// input
	parameter I_PREC = 16;
	parameter I_FRAC = 4;
	// Output configuration
	parameter O_PREC = 8;
	parameter O_FRAC = 3;
`endif

	// Simulation Loop
	parameter LOOP = 1000;

	reg [I_PREC-1:0]	in;
	wire				udf;
	wire				ovf;
	wire				rounded;
	wire [O_PREC-1:0]	out;



	//***** Port configuration
	parameter dconf_t I_CONF 
		= dconf_t'{dtype:TYPE, sign: SIGN, prec: I_PREC, frac: I_FRAC};
	parameter dconf_t O_CONF 
		= dconf_t'{dtype:TYPE, sign: SIGN, prec: O_PREC, frac: O_FRAC};



	/***** shrink *****/
	rdc_prec #(
		.I_CONF		( I_CONF ),
		.O_CONF		( O_CONF )
	) rdc_prec (
		.in			( in ),
		.udf		( udf ), 
		.ovf		( ovf ),
		.rounded	( rounded ),
		.out		( out ) 
	);



	//***** class declaration
`ifdef SIM_FXP
	`include "fxp_util.svh"

	//*** Fixed point input
	FxpUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_fxp;

	//*** floating point output
	FxpUtils #(
		.CONF		( O_CONF ),
		.ATTR		( "out" )
	) out_fxp;

	//*** floating point calculation
	FxpCalc #(
		.I1_CONF	( I_CONF ),
		.I1_ATTR	( "in" ),
		.I2_CONF	( O_CONF ),
		.I2_ATTR	( "out" )
	) cmp_fxp;

	initial begin
		cmp_fxp = new;
	end

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

	//*** Int calculation
	IntCalc #(
		.I1_CONF	( I_CONF ),
		.I1_ATTR	( "in" ),
		.I2_CONF	( O_CONF ),
		.I2_ATTR	( "out" )
	) cmp_int;

	initial begin
		cmp_int = new;
	end
`endif


`ifdef SIM_FXP
	task check_fxp_result;
		begin
			if ( cmp_fxp.compare(in,out) ) begin
				`SetCharBold
				`SetCharGreen
				$display("Check: OK");
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharRed
				$display("Check: NG");
				`ResetCharSetting
			end
		end
	endtask

	task check_fxp_imp;
		begin
			in_fxp.decode(in);
			if ( out_fxp.check_max(out) ) begin
				`SetCharBold
				`SetCharCyan
				$display("Rounded to Maximum");
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharMagenta
				$display("Cut Lower Bits");
				`ResetCharSetting
			end
		end
	endtask
`elsif SIM_INT
	task check_int_result;
		begin
			if ( cmp_int.compare(in,out) ) begin
				`SetCharBold
				`SetCharGreen
				$display("Check: OK");
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharRed
				$display("Check: NG");
				`ResetCharSetting
			end
		end
	endtask

	task check_int_imp;
		begin
			in_int.decode(in);
			if ( out_int.check_max(out) ) begin
				`SetCharBold
				`SetCharCyan
				$display("Rounded to Maximum");
				`ResetCharSetting
			end else begin
				`SetCharBold
				`SetCharMagenta
				$display("Cut Lower Bits");
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
		in_fxp.set(16'b000000000001_1100, in);
		#(STEP);
		check_fxp_result;

		// 7.5
		in_fxp.set(16'b000000000111_1000, in);
		#(STEP);
		check_fxp_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in_fxp.set_random(in);
			#(STEP);
			if ( udf || ovf || rounded ) begin
				//fxp_check_imp;
				check_fxp_imp;
			end else begin
				check_fxp_result;
			end
		end
`elsif SIM_INT
		// 2
		in_int.set(2, in);
		#(STEP);
		check_int_result;

		// 10
		in_int.set(10, in);
		#(STEP);
		check_int_result;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in_int.set_random(in);
			#(STEP);
			if ( udf || ovf || rounded ) begin
				check_int_imp;
			end else begin
				check_int_result;
			end
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
