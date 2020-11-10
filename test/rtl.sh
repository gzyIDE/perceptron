#!/bin/tcsh

switch ( $TOP_MODULE )
	case "exp_prec" :
		# Expand precision
		set TEST_FILE = "${TESTRTLDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/exp_int.sv \
				${RTLDIR}/exp_fxp.sv \
			)
		endif

		set valid = 1
	breaksw

	case "rdc_prec"
		# reduce precision
		set TEST_FILE = "${TESTRTLDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/rdc_int.sv \
				${RTLDIR}/rdc_fxp.sv \
			)
		endif

		set valid = 1
	breaksw

	case "p_mult"
		# reduce precision
		set TEST_FILE = "${TESTRTLDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/p_int_mult.sv \
				${RTLDIR}/p_fxp_mult.sv \
				${RTLDIR}/exp_int.sv \
				${RTLDIR}/exp_fxp.sv \
				${RTLDIR}/rdc_int.sv \
				${RTLDIR}/rdc_fxp.sv \
			)
		endif

		set valid = 1
	breaksw

	case "p_add"
		# reduce precision
		set TEST_FILE = "${TESTRTLDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/p_int_add.sv \
				${RTLDIR}/p_fxp_add.sv \
				${RTLDIR}/exp_int.sv \
				${RTLDIR}/exp_fxp.sv \
			)
		endif

		set valid = 1
	breaksw

	case "p_sub"
		# reduce precision
		set TEST_FILE = "${TESTRTLDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/p_int_sub.sv \
				${RTLDIR}/p_fxp_sub.sv \
				${RTLDIR}/exp_int.sv \
				${RTLDIR}/exp_fxp.sv \
				${RTLDIR}/rdc_int.sv \
				${RTLDIR}/rdc_fxp.sv \
			)
		endif

		set valid = 1
	breaksw

	case "act_func"
		# reduce precision
		set TEST_FILE = "${TESTRTLDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/act_step.sv \
				${RTLDIR}/act_relu.sv \
			)
		endif

		set valid = 1
	breaksw

	case "p_acc"
		# reduce precision
		set TEST_FILE = "${TESTRTLDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/p_int_acc.sv \
				${RTLDIR}/p_int_add.sv \
				${RTLDIR}/p_fxp_acc.sv \
				${RTLDIR}/p_fxp_add.sv \
			)
		endif

		set valid = 1
	breaksw

	case "p_infer"
		# reduce precision
		set TEST_FILE = "${TESTSLPDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${SLPDIR}/p_infer.sv \
				${RTLDIR}/p_mult.sv \
				${RTLDIR}/p_int_mult.sv  \
				${RTLDIR}/p_fxp_mult.sv \
				${RTLDIR}/p_int_add.sv \
				${RTLDIR}/p_fxp_add.sv \
				\
				${RTLDIR}/p_int_acc.sv \
				${RTLDIR}/p_fxp_acc.sv \
				\
				${RTLDIR}/act_func.sv \
				${RTLDIR}/act_step.sv \
				${RTLDIR}/act_relu.sv \
				\
				${RTLDIR}/cnv_prec.sv \
				${RTLDIR}/rdc_prec.sv \
				${RTLDIR}/exp_prec.sv \
				${RTLDIR}/exp_int.sv \
				${RTLDIR}/rdc_int.sv \
				${RTLDIR}/exp_fxp.sv \
				${RTLDIR}/rdc_fxp.sv \
			)
		endif

		set valid = 1
	breaksw

	case "calc_weight"
		# reduce precision
		set TEST_FILE = "${TESTSLPDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${SLPDIR}/calc_weight.sv \
				${RTLDIR}/p_mult.sv \
				${RTLDIR}/p_int_mult.sv  \
				${RTLDIR}/p_fxp_mult.sv \
				\
				${RTLDIR}/p_add.sv \
				${RTLDIR}/p_int_add.sv \
				${RTLDIR}/p_fxp_add.sv \
				\
				${RTLDIR}/calc_fxp_weight.sv \
				${RTLDIR}/calc_int_weight.sv \
				\
				${RTLDIR}/cnv_prec.sv \
				${RTLDIR}/rdc_prec.sv \
				${RTLDIR}/exp_prec.sv \
				${RTLDIR}/exp_int.sv \
				${RTLDIR}/rdc_int.sv \
				${RTLDIR}/exp_fxp.sv \
				${RTLDIR}/rdc_fxp.sv \
			)
		endif

		set valid = 1
	breaksw

	case "p_train"
		# reduce precision
		set TEST_FILE = "${TESTSLPDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${SLPDIR}/p_train.sv \
				${SLPDIR}/calc_fxp_weight.sv \
				${SLPDIR}/calc_int_weight.sv \
				\
				${RTLDIR}/p_mult.sv \
				${RTLDIR}/p_int_mult.sv  \
				${RTLDIR}/p_fxp_mult.sv \
				\
				${RTLDIR}/p_add.sv \
				${RTLDIR}/p_int_add.sv \
				${RTLDIR}/p_fxp_add.sv \
				${RTLDIR}/p_sub.sv \
				${RTLDIR}/p_int_sub.sv \
				${RTLDIR}/p_fxp_sub.sv \
				\
				${RTLDIR}/cnv_prec.sv \
				${RTLDIR}/rdc_prec.sv \
				${RTLDIR}/exp_prec.sv \
				${RTLDIR}/exp_int.sv \
				${RTLDIR}/rdc_int.sv \
				${RTLDIR}/exp_fxp.sv \
				${RTLDIR}/rdc_fxp.sv \
			)
		endif

		set valid = 1
	breaksw

	case "perceptron"
		set TEST_FILE = "${TESTSLPDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${RTLDIR}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${SLPDIR}/${TOP_MODULE}.sv \
				${SLPDIR}/p_infer.sv \
				${SLPDIR}/p_train.sv \
				${SLPDIR}/calc_weight.sv \
				${SLPDIR}/calc_int_weight.sv \
				${SLPDIR}/calc_fxp_weight.sv \
				${SLPDIR}/calc_bool_weight.sv \
				\
				${RTLDIR}/p_mult.sv \
				${RTLDIR}/p_int_mult.sv  \
				${RTLDIR}/p_fxp_mult.sv \
				${RTLDIR}/p_bool_mult.sv \
				\
				${RTLDIR}/p_add.sv \
				${RTLDIR}/p_int_add.sv \
				${RTLDIR}/p_fxp_add.sv \
				\
				${RTLDIR}/p_acc.sv \
				${RTLDIR}/p_int_acc.sv \
				${RTLDIR}/p_fxp_acc.sv \
				\
				${RTLDIR}/act_func.sv \
				${RTLDIR}/act_step.sv \
				${RTLDIR}/act_relu.sv \
				\
				${RTLDIR}/p_sub.sv \
				${RTLDIR}/p_int_sub.sv \
				${RTLDIR}/p_fxp_sub.sv \
				\
				${RTLDIR}/cnv_prec.sv \
				${RTLDIR}/rdc_prec.sv \
				${RTLDIR}/exp_prec.sv \
				${RTLDIR}/exp_int.sv \
				${RTLDIR}/rdc_int.sv \
				${RTLDIR}/exp_fxp.sv \
				${RTLDIR}/rdc_fxp.sv \
			)
		endif

		set valid = 1
	breaksw
endsw
