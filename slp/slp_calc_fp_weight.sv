/*
* <slp_calc_fp_weight.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.h"

module slp_calc_fp_weight #(
	// Learning Scheme
	parameter ADALINE = `Enable,		// `Enable : Adaline, else Perceptron
	// input configuration
	parameter I_PREC = 8,				// input precision
	parameter I_EXP = 3,				// exponet of input
	// Learning Rate configuration
	parameter R_PREC = 5,
	parameter R_EXP = 5,
	// weight configuration
	parameter W_PREC = 16,
	parameter W_EXP = 4,
	// Inference Result configuration
	parameter F_PREC = 8,
	parameter F_EXP = 3
)(
	input wire [I_PREC-1:0]		in,
	input wire [R_PREC-1:0]		rate,
	input wire [F_PREC-1:0]		error,
	input wire [W_PREC-1:0]		weight,
	output wire [W_PREC-1:0]	new_weight
);

	/***** internal parameters *****/
	localparam E_PREC = W_PREC;
	localparam E_EXP = W_EXP;

	/***** internal wires *****/
	wire [E_PREC-1:0]	in_ext;
	wire [E_PREC-1:0]	rate_ext;
	wire [E_PREC-1:0]	error_ext;

	generate
		if ( E_PREC > I_PREC ) begin : exp_in
			exp_fp #(
				.I_PREC		( I_PREC ),
				.I_EXP		( I_EXP ),
				.O_PREC		( E_PREC ),
				.O_EXP		( E_EXP )
			) exp (
				.in			( in ),
				.out		( in_ext )
			);
		end

		if ( E_PREC > R_PREC ) begin : exp_rate
			exp_fp #(
				.I_PREC		( R_PREC ),
				.I_EXP		( R_EXP ),
				.O_PREC		( E_PREC ),
				.O_EXP		( E_EXP )
			) exp (
				.in			( rate ),
				.out		( rate_ext )
			);
		end

		if ( E_PREC > F_PREC ) begin : exp_w
			exp_fp #(
				.I_PREC		( F_PREC ),
				.I_EXP		( F_EXP ),
				.O_PREC		( E_PREC ),
				.O_EXP		( E_EXP )
			) exp (
				.in			( error ),
				.out		( error_ext )
			);
		end
	endgenerate


	generate
		if ( ADALINE ) begin : adaline
			/***** Wires for Adaline *****/
			wire [E_PREC-1:0]	ir;
			wire [E_PREC-1:0]	delta;



			/***** Input x Rate *****/
			wire		dummy_ovf1;
			wire		dummy_udf1;
			wire		dummy_rounded1;
			p_fp_mult #(
				.I1_PREC	( E_PREC ),
				.I1_EXP		( E_EXP ),
				.I2_PREC	( E_PREC ),
				.I2_EXP		( E_EXP ),
				.O_PREC		( E_PREC ),
				.O_EXP		( E_EXP )
			) mult1 (
				.in1		( in_ext ),
				.in2		( rate_ext ),
				.udf		( dummy_udf1 ),
				.ovf		( dummy_ovf1 ),
				.rounded	( dummy_rounded1 ),
				.out		( ir )
			);



			/***** Error x (Input x Rate) *****/
			wire		dummy_ovf2;
			wire		dummy_udf2;
			wire		dummy_rounded2;
			p_fp_mult #(
				.I1_PREC	( E_PREC ),
				.I1_EXP		( E_EXP ),
				.I2_PREC	( E_PREC ),
				.I2_EXP		( E_EXP ),
				.O_PREC		( E_PREC ),
				.O_EXP		( E_EXP )
			) mult2 (
				.in1		( ir ),
				.in2		( error_ext ),
				.udf		( dummy_udf2 ),
				.ovf		( dummy_ovf2 ),
				.rounded	( dummy_rounded2 ),
				.out		( delta )
			);



			/***** calculate update weight *****/
			wire		dummy_ovf3;
			wire		dummy_udf3;
			wire		dummy_rounded3;
			p_fp_add #(
				.I1_PREC	( E_PREC ),
				.I1_EXP		( E_EXP ),
				.I2_PREC	( E_PREC ),
				.I2_EXP		( E_EXP ),
				.O_PREC		( E_PREC ),
				.O_EXP		( E_EXP )
			) add (
				.in1		( delta ),
				.in2		( weight ),
				.udf		( dummy_udf3 ),
				.ovf		( dummy_ovf3 ),
				.rounded	( dummy_rounded3 ),
				.out		( new_weight )
			);

		end else begin : percep
			/***** Wires for Perceptron *****/
			wire [E_PREC-1:0]		delta;



			/***** Input * Error Data *****/
			wire		dummy_ovf1;
			wire		dummy_udf1;
			wire		dummy_rounded1;
			p_fp_mult #(
				.I1_PREC	( E_PREC ),
				.I1_EXP		( E_EXP ),
				.I2_PREC	( E_PREC ),
				.I2_EXP		( E_EXP ),
				.O_PREC		( E_PREC ),
				.O_EXP		( E_EXP )
			) mult1 (
				.in1		( in_ext ),
				.in2		( error_ext ),
				.udf		( dummy_udf1 ),
				.ovf		( dummy_ovf1 ),
				.rounded	( dummy_rounded1 ),
				.out		( delta )
			);



			/***** calculate update weight *****/
			wire		dummy_ovf2;
			wire		dummy_udf2;
			wire		dummy_rounded2;
			p_fp_add #(
				.I1_PREC	( E_PREC ),
				.I1_EXP		( E_EXP ),
				.I2_PREC	( E_PREC ),
				.I2_EXP		( E_EXP ),
				.O_PREC		( E_PREC ),
				.O_EXP		( E_EXP )
			) add (
				.in1		( delta ),
				.in2		( weight ),
				.udf		( dummy_udf2 ),
				.ovf		( dummy_ovf2 ),
				.rounded	( dummy_rounded2 ),
				.out		( new_weight )
			);
		end
	endgenerate

endmodule
