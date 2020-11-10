/*
* <cnv_prec.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

module cnv_prec #(
	parameter dconf_t I_CONF = `DEF_DCONF_INT, 
	parameter dconf_t O_CONF = `DEF_DCONF_FXP,
	// constant
	parameter I_PREC = I_CONF.prec,
	parameter O_PREC = O_CONF.prec
)(
	input wire [I_PREC-1:0]		in,
	output wire					udf,
	output wire					ovf,
	output wire					rounded,
	output wire [O_PREC-1:0]	out
);

	// internal parameters
	localparam I_TYPE = I_CONF.dtype;
	localparam O_TYPE = O_CONF.dtype;
	localparam EXPAND = O_PREC > I_PREC;	// expand bit width
	localparam SHRINK = O_PREC < I_PREC;	// shrink bit width



	// converter select by combination
	generate
		if ( I_TYPE == O_TYPE ) begin : prec_cnv
			if ( EXPAND ) begin : exp
				// not used
				assign udf = `Disable;
				assign ovf = `Disable;
				assign rounded = `Disable;

				// expand bit width
				exp_prec #(
					.ICONF	( I_CONF ),
					.O_CONF	( O_CONF )
				) exp_prec (
					.in		( in ),
					.out	( out )
				);
			end else if ( SHRINK ) begin : shr
				// shrink bit width
				rdc_prec #(
					.ICONF	( I_CONF ),
					.O_CONF	( O_CONF )
				) exp_prec (	
					.in			( in ),
					.udf		( udf ),
					.ovf		( ovf ),
					.rounded	( rounded ),
					.out		( out )
				);
			end else begin : thr
				// through (exponent and binary point convert is not supported)
				assign out = in;
				assign udf = `Disable;
				assign ovf = `Disable;
				assign rounded = `Disable;
			end
		end else begin : cnv_type
			case ({ O_TYPE, I_TYPE })
				{FP, BOOL} : begin : b2fp
				end
				{FXP, BOOL} : begin : b2fxp
				end
				{BOOL, FP} : begin : fp2b
				end
				{FXP, FP} : begin : fp2fxp
				end
				{BOOL, FXP} : begin : fp2b
				end
				{FP, FXP} : begin : fp2fxp
				end
			endcase
		end
	endgenerate

endmodule
