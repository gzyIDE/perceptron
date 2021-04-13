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

//`define SIM_FXP
`define SIM_INT

module p_acc_test;
	parameter STEP = 10;
	parameter IN = 5;
`ifdef SIM_INT
	parameter dtype_t TYPE = INT;
	parameter SIGN = `Enable;
	parameter PREC = 8;
	parameter FRAC = 0;
`else
	parameter dtype_t TYPE = FXP;
	parameter SIGN = `Enable;
	parameter PREC = 16;
	parameter FRAC = 4;
`endif

	// Simulation Loops
	parameter LOOP = 1000;

	reg [IN-1:0][PREC-1:0]	in;
	wire					udf;
	wire					ovf;
	wire					rounded;
	wire [PREC-1:0]			out;



	//***** struct instantiation
	parameter dconf_t CONF 
		= dconf_t'{dtype:TYPE, sign:SIGN, prec: PREC, frac: FRAC};



	/***** class declaration *****/
`ifdef SIM_FXP
	`include "fxp_util.svh"
	FxpUtils #(
		.CONF		( CONF ),
		.ATTR		( "in" )
	) data_fxp;

`elsif SIM_INT
	`include "int_util.svh"
	IntUtils #(
		.CONF		( CONF ),
		.ATTR		( "in" )
	) data_int;
`endif



	/***** module *****/
	p_acc #(
		.IN			( IN ),
		.CONF		( CONF )
	) acc (
		.in			( in ),
		.udf		( udf ),
		.ovf		( ovf ),
		.rounded	( rounded ),
		.out		( out )
	);



	/***** simulation tasks *****/
`ifdef SIM_FXP
	task set_fxp_all;
		integer i;
		begin
			for ( i = 0; i < IN; i = i + 1 ) begin
				data_fxp.set_random(in[i]);
			end
		end
	endtask

	task check_fxp;
		integer	i;
		real	sum;
		real	res;
		begin
			sum = 0.0;

			for ( i = 0; i < IN; i = i + 1 ) begin
				$write("in%1d :", i);
				sum = sum + data_fxp.decode(in[i]);
			end

			$write("out :");
			res = data_fxp.decode(out);
			$display("ans : %f", sum);
			if ( res == sum ) begin
				`SetCharBold
				`SetCharGreen
				$display("Accumulate OK");
				`ResetCharSetting
			end else begin
				if ( udf || ovf || rounded ) begin
					`SetCharBold
					`SetCharYellow
					$display("Result Rounded");
					`ResetCharSetting
				end else begin
					`SetCharBold
					`SetCharRed
					$display("Accumulate NG");
					`ResetCharSetting
				end 
			end
		end
	endtask
`elsif SIM_INT
	task set_int_all;
		integer i;
		begin
			for ( i = 0; i < IN; i = i + 1 ) begin
				data_int.set_random(in[i]);
			end
		end
	endtask

	task check_int;
		integer	i;
		int		sum;
		int		res;
		begin
			sum = 0.0;

			for ( i = 0; i < IN; i = i + 1 ) begin
				$write("in[%1d] : %4d, ", i, data_int.decode(in[i]));
				sum = sum + data_int.decode(in[i]);
			end

			res = data_int.decode(out);
			$display("out : %4d", res);

			$display("ans : %4d", sum);
			if ( res == sum ) begin
				`SetCharBold
				`SetCharGreen
				$display("Accumulate OK");
				`ResetCharSetting
			end else begin
				if ( udf || ovf || rounded ) begin
					`SetCharBold
					`SetCharYellow
					$display("Result Rounded");
					`ResetCharSetting
				end else begin
					`SetCharBold
					`SetCharRed
					$display("Accumulate NG");
					`ResetCharSetting
				end 
			end
		end
	endtask
`endif



	/***** testvector body *****/
	integer i;
	initial begin
		in <= {PREC*IN{1'b0}};
		#(STEP);

`ifdef SIM_FXP
		// all 0 ~ IN-1
		for ( i = 0; i < IN; i = i + 1 ) begin
			data_fxp.set({i, {EXP{1'b0}}}, in[i]);
		end
		#(STEP);
		check_fxp;

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			set_fxp_all;
			#(STEP);
			check_fxp;
		end
`elsif SIM_INT
		// all 0 ~ IN-1
		for ( i = 0; i < IN; i = i + 1 ) begin
			data_int.set(i, in[i]);
		end
		#(STEP);
		//void'(data_int.decode(out));

		for ( i = 0; i < LOOP; i = i + 1 ) begin
			set_int_all;
			#(STEP);
			check_int;
		end
`endif

		$finish;
	end

`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("ACF");
	end
`endif

endmodule
