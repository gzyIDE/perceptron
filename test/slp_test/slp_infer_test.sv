/*
* <slp_infer_test.sv>
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

module slp_infer_test;
	parameter STEP = 10;
	parameter IN = 4;
	parameter WEIGHT = IN + 1;
	parameter actf_t ACT = ReLU;
`ifdef SIM_INT
	parameter dtype_t TYPE = INT;
	// input configuration
	parameter I_SIGN = `Enable;
	parameter I_PREC = 8;
	parameter I_FRAC = 0;
	// weight configuration
	parameter W_SIGN = `Enable;
	parameter W_PREC = 8;
	parameter W_FRAC = 0;
	// Output configuration
	parameter O_SIGN = `Enable;
	parameter O_PREC = 8;
	parameter O_FRAC = 0;
`elsif SIM_FXP
	// Data Type
	parameter dtype_t TYPE = FXP;
	// input configuration
	parameter I_SIGN = `Enable;
	parameter I_PREC = 8;
	parameter I_FRAC = 3;
	// weight configuration
	parameter W_SIGN = `Enable;
	parameter W_PREC = 16;
	parameter W_FRAC = 4;
	// Output configuration
	parameter O_SIGN = `Enable;
	parameter O_PREC = 8;
	parameter O_FRAC = 3;
`endif

	// Simulation Loops
	parameter LOOP = 1000;

	//***** struct instantiation
	parameter dconf_t I_CONF 
		= dconf_t'{dtype: TYPE, sign: I_SIGN, prec: I_PREC, frac: I_FRAC};
	parameter dconf_t W_CONF 
		= dconf_t'{dtype: TYPE, sign: W_SIGN, prec: W_PREC, frac: W_FRAC};
	parameter dconf_t O_CONF 
		= dconf_t'{dtype: TYPE, sign: O_SIGN, prec: O_PREC, frac: O_FRAC};



	//***** wires and regs
	reg [IN-1:0][I_PREC-1:0]		in;
	reg [WEIGHT-1:0][W_PREC-1:0]	weight;
	wire							udf;
	wire							ovf;
	wire							roudned;
	wire [O_PREC-1:0]				out;



	//***** class declaration
`ifdef SIM_FXP
	`include "fxp_util.svh"
	FxpUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_fxp;

	FxpUtils #(
		.CONF		( W_CONF ),
		.ATTR		( "w" )
	) w_fxp;

	FxpUtils #(
		.CONF		( O_CONF ),
		.ATTR		( "out" )
	) out_fxp;
`elsif SIM_INT
	`include "int_util.svh"
	IntUtils #(
		.CONF		( I_CONF ),
		.ATTR		( "in" )
	) in_int;

	IntUtils #(
		.CONF		( W_CONF ),
		.ATTR		( "w" )
	) w_int;

	IntUtils #(
		.CONF		( O_CONF ),
		.ATTR		( "out" )
	) out_int;
`endif



	//***** module
	slp_infer #(
		.IN			( IN ),
		.I_CONF		( I_CONF ),
		.W_CONF		( W_CONF ),
		.O_CONF		( O_CONF ),
		.ACT		( ACT )
	) infer (
		.in			( in ),
		.weight		( weight ),
		.udf		( udf ),
		.ovf		( ovf ),
		.rounded	( rounded ),
		.out		( out )
	);



	//****** check function
`ifdef SIM_FXP
	task check_infer_fxp;
		int ti;
		real sum;
		real ans;
		real res;
		begin
			sum = 0;
			for ( ti = 0; ti < IN; ti = ti + 1 ) begin
				sum = sum + in_fxp.decode(in[ti]) * w_fxp.decode(weight[ti]);
			end
			sum = sum + w_fxp.decode(weight[WEIGHT-1]);
			ans = out_fxp.act_check(sum);
			res = out_fxp.decode(out);

			if ( udf || ovf || rounded ) begin
				check_infer_fxp_imp(ans, res);
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

	task check_infer_fxp_imp;
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
	task check_infer_int;
		int ti;
		int sum;
		int ans;
		int res;
		begin
			sum = 0;
			for ( ti = 0; ti < IN; ti = ti + 1 ) begin
				sum = sum + in_int.decode(in[ti]) * w_int.decode(weight[ti]);
			end
			sum = sum + w_int.decode(weight[WEIGHT-1]);
			ans = out_int.act_func(sum);
			res = out_int.decode(out);

			if ( udf || ovf || rounded ) begin
				check_infer_int_imp(ans, res);
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

	task check_infer_int_imp;
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



	//***** testvector body
	integer i;
	initial begin
		for ( i = 0; i < IN; i = i + 1 ) begin
			in[i] <= {I_PREC{1'b0}};
		end
		for ( i = 0; i < WEIGHT; i = i + 1 ) begin
			weight[i] <= {W_PREC{1'b0}};
		end
		#(STEP);

`ifdef SIM_FXP
			// 1
			in_fxp.set(8'b00001_000, in[0]);
			in_fxp.set(8'b00001_000, in[1]);
			// -0.25
			in_fxp.set(8'b11111_110, in[2]);
			in_fxp.set(8'b11111_110, in[3]);
			// 1.0
			w_fxp.set(16'b000000000001_0000, weight[0]);
			w_fxp.set(16'b000000000001_0000, weight[1]);
			// 2.0
			w_fxp.set(16'b000000000011_0000, weight[2]);
			w_fxp.set(16'b000000001010_0000, weight[3]);
			// bias 4
			w_fxp.set(16'b000000000100_0000, weight[4]);

			#(STEP);
			//void'(out_fxp.decode(out));
			check_infer_fxp;
`elsif SIM_INT
			// 1
			in_int.set(8'b0000_0001, in[0]);
			// -2
			in_int.set(8'b1111_1110, in[1]);
			// -3
			in_int.set(8'b1111_1101, in[2]);
			// 4
			in_int.set(8'b0000_0100, in[3]);

			// 1
			w_int.set(8'b0011_0001, weight[0]);
			// 1
			w_int.set(8'b0000_0001, weight[1]);
			// 1
			w_int.set(8'b0000_0001, weight[2]);
			// 1
			w_int.set(8'b0000_0001, weight[3]);
			// bias 5
			w_int.set(8'b0000_0101, weight[4]);

			#(STEP);
			//void'(out_int.decode(out));
			check_infer_int;
`endif

		$finish;
	end

	`include "waves.vh"

endmodule
