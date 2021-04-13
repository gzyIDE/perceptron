/*
* <p_div_pow2_test.sv>
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

module p_div_pow2_test;
	parameter STEP = 10;
	// round up mode
	//		0: discard lower bits
	//		1: round up if lower bits are greater than or equal (1<<n)/2
	//		2: round up if lower bits are not zero
	parameter ROUND = 2;
	parameter SHIFT = 2;
`ifdef SIM_INT
	parameter dtype_t TYPE = INT;
	// input1 configuration
	parameter I_SIGN = `Enable;		// 0 : unsigned; 1 : signed (for FXP)
	parameter I_PREC = 8;			// input precision
	parameter I_FRAC = 0;			// exponet of input
	// input1 configuration
	parameter O_SIGN = `Enable;		// 0 : unsigned; 1 : signed (for FXP)
	parameter O_PREC = 8-SHIFT;			// input precision
	parameter O_FRAC = 0;			// exponet of input
`else
	parameter dtype_t TYPE = FXP;
	// input1 configuration
	parameter I_SIGN = `Enable;		// 0 : unsigned; 1 : signed (for FXP)
	parameter I_PREC = 8;			// input precision
	parameter I_FRAC = 3;			// exponet of input
	// input1 configuration
	parameter O_SIGN = `Enable;		// 0 : unsigned; 1 : signed (for FXP)
	parameter O_PREC = 8;			// input precision
	parameter O_FRAC = 3;			// exponet of input
`endif

	// Simulation Loops
	parameter LOOP = 1000;

	reg [I_PREC-1:0]		in;
	wire [SHIFT-1:0]		rem;
	wire [O_PREC-1:0]		out;

	//***** struct instantiation
	//*** port configuration
	parameter dconf_t I_CONF 
		= dconf_t'{dtype:TYPE, sign:I_SIGN, prec: I_PREC, frac: I_FRAC};
	parameter dconf_t O_CONF 
		= dconf_t'{dtype:TYPE, sign: O_SIGN, prec: O_PREC, frac: O_FRAC};



	//***** Utilities (include FxpUtils, Int Utils)
`ifdef SIM_FXP
	`include "fxp_util.svh"
	//*** Fixed Point input1
	FxpUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_fxp;

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



	//***** shift based divider module
	p_div_pow2 #(
		.SHIFT		( SHIFT ),
		.ROUND		( ROUND ),
		.I_CONF		( I_CONF ),
		.O_CONF		( O_CONF )
	) div (
		.in			( in ),
		.rem		( rem ),
		.out		( out )
	);



	//***** simulation body
	integer i;
	initial begin
		in = {I_PREC{1'b0}};
		#(STEP);

`ifdef SIM_FXP
		in_fxp.set(8'b00011_100, in);
		#(STEP);
		in_fxp.set(8'b11111_111, in);
`elsif SIM_INT
		in = 3;
		#(STEP);
		$display("in: %d, out: %d", in_int.decode(in), out_int.decode(out));
		in = -2;
		#(STEP);
		$display("in: %d, out: %d", in_int.decode(in), out_int.decode(out));

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			in_int.set_random(in);
			#(STEP);
			$display("in: %d, out: %d", in_int.decode(in), out_int.decode(out));
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
