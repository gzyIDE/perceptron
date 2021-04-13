#!/bin/tcsh

switch ( $TOP_MODULE )
	case "slp_infer"
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
				${SLPDIR}/slp_infer.sv \
				\
				${RTLDIR}/p_mult.sv \
				${RTLDIR}/p_int_mult.sv  \
				${RTLDIR}/p_fxp_mult.sv \
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

	case "slp_calc_weight"
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
				${SLPDIR}/slp_calc_weight.sv \
				${SLPDIR}/slp_calc_fxp_weight.sv \
				${SLPDIR}/slp_calc_int_weight.sv \
				\
				${RTLDIR}/p_mult.sv \
				${RTLDIR}/p_int_mult.sv  \
				${RTLDIR}/p_fxp_mult.sv \
				\
				${RTLDIR}/p_add.sv \
				${RTLDIR}/p_int_add.sv \
				${RTLDIR}/p_fxp_add.sv \
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

	case "slp_train"
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
				${SLPDIR}/slp_train.sv \
				${SLPDIR}/slp_calc_weight.sv \
				${SLPDIR}/slp_calc_fxp_weight.sv \
				${SLPDIR}/slp_calc_int_weight.sv \
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

	case "slp"
		set TEST_FILE = "${TESTSLPDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}_svsim.sv \
			)
		else
			set RTL_FILE = ( \
				$RTL_FILE \
				${SLPDIR}/${TOP_MODULE}.sv \
				${SLPDIR}/slp_infer.sv \
				${SLPDIR}/slp_train.sv \
				${SLPDIR}/slp_calc_weight.sv \
				${SLPDIR}/slp_calc_int_weight.sv \
				${SLPDIR}/slp_calc_fxp_weight.sv \
				${SLPDIR}/slp_calc_bool_weight.sv \
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
				${RTLDIR}/p_bool_acc.sv \
				${RTLDIR}/p_int_acc.sv \
				${RTLDIR}/p_fxp_acc.sv \
				${RTLDIR}/cnt_bits.sv \
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
