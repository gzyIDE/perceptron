//****** Class Instantiation
`ifdef SIM_INT
//*** integer perceptron
//* input activation
IntUtils #(
	.CONF		( I_CONF ),
	.ATTR		( "in" )
) in_int;

//* learning rate
IntUtils #(
	.CONF		( R_CONF ),
	.ATTR		( "rate" )
) rate_int;

//* weight
IntUtils #(
	.CONF		( W_CONF ),
	.ATTR		( "w" )
) weight_int;

//* output
IntUtils #(
	.CONF		( O_CONF ),
	.ATTR		( "o" )
) out_int;

`elsif SIM_FXP
//*** Fixed point perceptron
//* input
FxpUtils #(
	.CONF		( I_CONF ),
	.ATTR		( "in" )
) in_fxp;

//* learning rate
FxpUtils #(
	.CONF		( R_CONF ),
	.ATTR		( "rate" )
) rate_fxp;

//* weight
FxpUtils #(
	.CONF		( W_CONF ),
	.ATTR		( "weight" )
) weight_fxp;

//* output
FxpUtils #(
	.CONF		( O_CONF ),
	.ATTR		( "out" )
) out_fxp;
`elsif SIM_FP
//*** Floating point perceptron
//* input
FpUtils #(
	.CONF		( I_CONF ),
	.ATTR		( "in" )
) in_fp;

//* learning rate
FpUtils #(
	.CONF		( R_CONF ),
	.ATTR		( "rate" )
) rate_fp;

//* weight
FpUtils #(
	.CONF		( W_CONF ),
	.ATTR		( "weight" )
) weight_fp;

//* output
FpUtils #(
	.CONF		( O_CONF ),
	.ATTR		( "out" )
) out_fp;
`elsif SIM_BOOL
IntUtils #(
	.CONF		( W_CONF ),
	.ATTR		( "w" )
) weight_bool;
`endif



//***** Value Check
/* check weight */
task check_weight;
	int i;

	`SetCharBold
	`SetCharCyan
	$display("Dump Weights");
	`ResetCharSetting
	for ( i = 0; i < WEIGHT; i = i + 1 ) begin
		`SetCharBold
		`SetCharCyan
		$write("%2d: ", i);
		`ResetCharSetting

`ifdef SIM_FXP
		$display("weight: %f", 
			weight_fxp.decode(perceptron.weight[i]));
`elsif SIM_INT
		$display("weight: %d", 
			weight_int.decode(perceptron.weight[i]));
`elsif SIM_FP
		$display("weight: %f", 
			weight_fp.decode(perceptron.weight[i]));
`elsif SIM_BOOL
		$display("weight: %d",
			weight_bool.decode(perceptron.weight[i]));
`endif
	end
endtask

//*** check input
task check_input;
	int i;

	`SetCharBold
	`SetCharCyan
	$display("Dump Inputs");
	`ResetCharSetting
	for ( i = 0; i < IN; i = i + 1 ) begin
		`SetCharBold
		`SetCharCyan
		$write("%2d: ", i);
		`ResetCharSetting

`ifdef SIM_FXP
			$display("input: %f", in_fxp.decode(in[i]));
`elsif SIM_INT
			$display("input: %d", in_int.decode(in[i]));
`elsif SIM_FP
			$display("input: %f", in_fp.decode(in[i]));
`elsif SIM_BOOL
			$display("input: %b", in[i]);
`endif
	end
endtask

/* check output */
task check_out;
	`SetCharBold
	`SetCharCyan
	$display("Outputs");
	`ResetCharSetting
`ifdef SIM_FXP
	$display("output: %f", out_fxp.decode(out));
`elsif SIM_INT
	$display("output: %d", out_int.decode(out));
`elsif SIM_FP
	$display("output: %d", out_fp.decode(out));
`elsif SIM_BOOL
	$display("output: %b", out);
`endif
endtask
