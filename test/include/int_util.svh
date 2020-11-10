/*
* <int_util.svh>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

virtual class IntUtils #(
	parameter dconf_t CONF = `DEF_DCONF_INT,
	parameter actf_t ACT = `DEF_ACT,
	parameter string ATTR = "in",	// direction
	parameter DISP = `Enable		// print decoded result
);

	/***** internal parameter *****/
	localparam SIGN = CONF.sign;
	localparam PREC = CONF.prec;
	localparam FRAC = CONF.frac;

	task set;
		input [PREC-1:0]		in;
		output [PREC-1:0]		dst;
		begin
			dst = in;
		end
	endtask

	task set_random;
		output [PREC-1:0]		dst;
		begin
			dst = $random;
		end
	endtask

	function int decode;
		input [PREC-1:0]		in;
		reg	 signed [PREC-1:0]	in_s;
		begin
			in_s = in;
			if ( SIGN ) begin
				if ( in[PREC-1] ) begin
					decode = in_s;
				end else begin
					decode = in;
				end
			end else begin
				decode = in;
			end
		end
	endfunction

	function [PREC-1:0] get_max;
		input			sign;
		begin
			if ( SIGN ) begin
				if ( sign ) begin
					get_max = {1'b1, {PREC-1{1'b0}}};
				end else begin
					get_max = {1'b0, {PREC-1{1'b1}}};
				end
			end else begin
				get_max = {PREC{1'b1}};
			end
		end
	endfunction

	function check_max;
		input [PREC-1:0]		in;
		bit [PREC-1:0]			max;
		begin
			max = this.get_max(in[PREC-1]);
			check_max = ( in == max );
		end
	endfunction

	function int act_func;
		input [PREC-1:0]	in;
		int					dn;
		begin
			dn = this.decode(in);
			case (ACT)
				STEP : begin
					if ( SIGN ) begin
						if ( dn >= 0 ) begin
							act_func = 1;
						end else begin
							act_func = 0;
						end
					end else begin
						if ( dn >= ( 1 << ( PREC - 1 ) ) ) begin
							act_func = this.decode({PREC{1'b1}});
						end else begin
							act_func = this.decode({1'b0, {PREC-1{1'b1}}});
						end
					end
				end
				LINEAR : begin
					act_func = dn;
				end
				ReLU: begin
					if ( SIGN ) begin
						if ( dn > 0 ) begin
							act_func = dn;
						end else begin
							act_func = 0.0;
						end
					end else begin
						if ( dn > ( 1 << ( PREC - 1 ) ) ) begin
							act_func = dn;
						end else begin
							act_func = 1 << ( PREC - 1 );
						end
					end
				end
				SIGMOID : begin
					act_func = int'(($tanh(dn/2.0) + 1.0) / 2.0);
				end
			endcase
		end
	endfunction
endclass


//***** Input calculation functions *****/
class IntCalc #(
	//*** input1
	parameter dconf_t I1_CONF = `DEF_DCONF_INT,
	parameter string I1_ATTR = "in1",
	//*** input2
	parameter dconf_t I2_CONF = `DEF_DCONF_INT,
	parameter string I2_ATTR = "in2"
);

	/***** internal parameters *****/
	/* input1 */
	localparam I1_PREC = I1_CONF.prec;
	/* input2 */
	localparam I2_PREC = I2_CONF.prec;



	/***** class initialization *****/
	/* input 1 */
	IntUtils #(
		.CONF	( I1_CONF ),
		.ATTR	( I1_ATTR )
	) in1_int;

	/* input 2 */
	IntUtils #(
		.CONF	( I2_CONF ),
		.ATTR	( I2_ATTR )
	) in2_int;

	/***** calculations *****/
	function compare;
		input [I1_PREC-1:0]		in1;
		input [I2_PREC-1:0]		in2;
		int						di1;
		int						di2;
		begin
			di1 = in1_int.decode(in1);
			di2 = in2_int.decode(in2);

			compare = ( di1 == di2 );
		end
	endfunction

	function real mult;
		input [I1_PREC-1:0]		in1;
		input [I2_PREC-1:0]		in2;
		int						di1;
		int						di2;
		begin
			di1 = in1_int.decode(in1);
			di2 = in2_int.decode(in2);

			mult = di1 * di2;
		end
	endfunction

	function real add;
		input [I1_PREC-1:0]		in1;
		input [I2_PREC-1:0]		in2;
		int						di1;
		int						di2;
		begin
			di1 = in1_int.decode(in1);
			di2 = in2_int.decode(in2);
			$display("in1: %d, in2: %d", di1, di2);

			add = di1 + di2;
		end
	endfunction

	function real sub;
		input [I1_PREC-1:0]		in1;
		input [I2_PREC-1:0]		in2;
		int						di1;
		int						di2;
		begin
			di1 = in1_int.decode(in1);
			di2 = in2_int.decode(in2);

			sub = di1 - di2;
		end
	endfunction

endclass
