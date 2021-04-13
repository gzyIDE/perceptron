/*
* <slp_test.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "perceptron.svh"
`include "int_util.svh"
`include "fxp_util.svh"
`include "fp_util.svh"
`include "sim.vh"

//***** perceptron data type
//`define SIM_INT
`define SIM_FXP
//`define SIM_BOOL

//***** test target
//`define OR_TRAIN
`define AND_TRAIN

module slp_test;
	parameter Step = 10;
	parameter IN = 4;
	parameter WEIGHT = IN + 1;
	parameter actf_t ACT = STEP;

`ifdef SIM_INT
	parameter dtype_t TYPE = INT;

	// input configuration
	parameter I_SIGN = `Enable;
	parameter I_PREC = 4;
	parameter I_FRAC = 0;
	// Learning Rate configuration
	parameter R_SIGN = `Enable;
	parameter R_PREC = 0;
	parameter R_FRAC = 0;
	// weight configuration
	parameter W_SIGN = `Enable;
	parameter W_PREC = 4;
	parameter W_FRAC = 0;
	// Output configuration
	parameter O_SIGN = `Enable;
	parameter O_PREC = 4;
	parameter O_FRAC = 0;
	// constant
	parameter CONST1 = 4'b0001;
	parameter CONST0 = 4'b0000;
	// not used
	parameter RATE = 4'b0_000;
`elsif SIM_FXP
	parameter dtype_t TYPE = FXP;

	// input configuration
	parameter I_SIGN = `Disable;
	parameter I_PREC = 4;
	parameter I_FRAC = 3;
	// Learning Rate configuration
	parameter R_SIGN = `Disable;
	parameter R_PREC = 4;
	parameter R_FRAC = 3;
	// weight configuration
	parameter W_SIGN = `Enable;
	parameter W_PREC = 5;
	parameter W_FRAC = 3;
	// Output configuration
	parameter O_SIGN = `Enable;
	parameter O_PREC = 5;
	parameter O_FRAC = 3;
	// Learning Rate : 0.125
	parameter CONST1 = 4'b1_000;
	parameter CONST0 = 4'b0_000;
	parameter RATE = 4'b0_001;
`elsif SIM_BOOL
	parameter dtype_t TYPE = BOOL;

	// input configuration
	parameter I_PREC = 1;
	// Learning Rate configuration
	parameter R_PREC = 1;
	// weight configuration
	parameter W_PREC = 4;
	parameter W_SIGN = `Enable;
	// Output configuration
	parameter O_SIGN = `Enable;
	parameter CONST1 = 1'b1;
	parameter CONST0 = 1'b0;
	// Learning Rate : 1
	parameter RATE = 1'b1;
	// Don't care
	parameter I_SIGN = `Enable;
	parameter I_FRAC = 0;
	parameter R_SIGN = `Disable;
	parameter R_FRAC = 0;
	parameter W_FRAC = 0;
	parameter O_PREC = 1;
	parameter O_FRAC = 0;
`endif

	// Simulation Parameter
	parameter EPOCH = 100;

	//***** struct instantiation
	parameter dconf_t I_CONF 
		= dconf_t'{dtype: TYPE, sign: I_SIGN, prec: I_PREC, frac: I_FRAC};
	parameter dconf_t R_CONF 
		= dconf_t'{dtype: TYPE, sign: R_SIGN, prec: R_PREC, frac: R_FRAC};
	parameter dconf_t W_CONF 
		= dconf_t'{dtype: TYPE, sign: W_SIGN, prec: W_PREC, frac: W_FRAC};
	parameter dconf_t O_CONF 
		= dconf_t'{dtype: TYPE, sign: O_SIGN, prec: O_PREC, frac: O_FRAC};

	reg							clk;
	reg							reset_;

	/* inference */
	reg [IN-1:0][I_PREC-1:0]	in;
	wire [O_PREC-1:0]			out;

	/* train */
	reg [O_PREC-1:0]			train;
	reg [R_PREC-1:0]			rate;
	reg							t_en;

	slp #(
		.IN				( IN ),
		.I_CONF			( I_CONF ),
		.R_CONF			( R_CONF ),
		.W_CONF			( W_CONF ),
		.O_CONF			( O_CONF ),
		.ACT			( ACT )
	) perceptron (
		.clk			( clk ),
		.reset_			( reset_ ),
		.in				( in ),
		.out			( out ),
		.train			( train ),
		.rate			( rate ),
		.t_en			( t_en )
	);


	`include "slp_test.svh"
	`include "train_or.svh"
	`include "train_and.svh"



	//***** Clk generation
	always #(Step/2) begin
		clk <= ~clk;
	end



	/***** simulation body *****/
	int		si, sj;
	initial begin
		clk = `Low;
		reset_ = `Enable_;
		for ( si = 0; si < IN; si = si + 1 ) begin
			in[si] = {I_PREC{1'b0}};
		end
		train = {O_PREC{1'b0}};
		rate = {R_PREC{1'b0}};
		t_en = `Disable;
		#(Step);

		reset_ = `Disable_;
		#(Step);

		check_weight;

		// initialize learning rate
		rate = RATE;

		#(Step);
		for ( si = 0; si < EPOCH; si = si + 1 ) begin
			$display("Epoch %d", si);
			for ( sj = 0; sj < (1 << IN); sj = sj + 1 ) begin
`ifdef AND_TRAIN
				and_train($random);
`elsif OR_TRAIN
				or_train($random);
`endif
				#(Step);
				check_input;
			end
		end

		#(Step);

`ifdef AND_TRAIN
		and_test(CONST0, CONST1);
`elsif OR_TRAIN
		or_test(CONST0, CONST1);
`endif

		#(Step);
		check_out;
		check_weight;
		check_input;

		$finish;
	end

	`include "waves.vh"

endmodule
