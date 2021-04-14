# search path settings
set search_path [concat \
	. \
	../rtl \
	../slp \
	../include \
]

# name settings
set REPORTDIR	report
set RESULTDIR	result
set LIBDIR		lib
set DBDIR		db
set TCLDIR		tcl

set DESIGN		slp
# set FILE_LIST [list]
set SV_FILE_LIST	[list \
	${DESIGN}.sv \
	slp_infer.sv \
	slp_train.sv \
	\
	slp_calc_weight.sv \
	slp_calc_int_weight.sv \
	slp_calc_fxp_weight.sv \
	slp_calc_bool_weight.sv \
	\
	p_mult.sv \
	p_int_mult.sv  \
	p_fxp_mult.sv \
	p_bool_mult.sv \
	\
	p_add.sv \
	p_int_add.sv \
	p_fxp_add.sv \
	\
	p_acc.sv \
	p_bool_acc.sv \
	p_int_acc.sv \
	p_fxp_acc.sv \
	cnt_bits.sv \
	\
	act_func.sv \
	act_step.sv \
	act_relu.sv \
	\
	p_sub.sv \
	p_int_sub.sv \
	p_fxp_sub.sv \
	\
	cnv_prec.sv \
	rdc_prec.sv \
	exp_prec.sv \
	exp_int.sv \
	rdc_int.sv \
	exp_fxp.sv \
	rdc_fxp.sv \
]
# define following variable for designs with 
#    complex port definition such as enum, struct, array or interfaces
set SV_COMPLEX_PORT	true

# Hard IPs called in source files
#    In this example, we used standard cell library for demonstration.
#    But call Hardware IP provided by vendors in real use.
#set HARDIP [list]

# If your design include clock/reset signals, define following variables
#    otherwise leave them commented out
set CLOCK_SIG_NAME	clk
set RESET_SIG_NAME	reset_

source -echo -verbose $TCLDIR/common.tcl


exit
