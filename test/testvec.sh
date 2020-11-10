#!/bin/tcsh

#######################################
##### File and Directory Settings #####
#######################################
set TOPDIR = ".."
set RTLDIR = "${TOPDIR}/rtl"
set SLPDIR = "${TOPDIR}/slp"
set MLPDIR = "${TOPDIR}/mlp"
set TESTDIR = "${TOPDIR}/test"
set TESTRTLDIR = "${TESTDIR}/rtl_test"
set TESTSLPDIR = "${TESTDIR}/slp_test"
set TESTMLPDIR = "${TESTDIR}/mlp_test"
set GATEDIR = "${TOPDIR}/syn/result"
set DWDIR = "/cad/synopsys/syn/P-2019.03-SP1-1/dw/sim_ver"
set INCLUDE = ( \
	+incdir+$TOPDIR/include \
	+incdir+${TESTDIR}/include \
)

#############################################
#                 Defines                   #
#############################################
set DEFINES = ( \
	-y ${DWDIR} \
)

#############################################
#           Gate Level Simulation           #
#############################################
# set GATE = 1
set GATE = 0

#############################################
#              Process Setting              #
#############################################
set Process = "TSMC130"
#set Process = "TSMC65"
#set Process = "ASAP7"


if ( $GATE =~ 1 ) then
	switch ($Process)
		case "TSMC130":
			set CELL_RTL_DIR = "/cad/TSMC/digital/Front_End/verilog"
			set RTL_FILE = ( \
				$CELL_RTL_DIR/tcb013lvhp_211a/tcb013lvhp.v \
				$CELL_RTL_DIR/tcb013lvhphvt_211a/tcb013lvhphvt.v \
			)
		breaksw
		case "TSMC65" :
			set CELL_RTL_DIR = "/usr/users/ide/hard/archive/tsmc65_lib/TSMCHOME/digital/Front_End/verilog"
			set RTL_FILE =( \
				$CELL_RTL_DIR/tcbn65lplvt_100a/tcbn65lplvt.v \
	    		$CELL_RTL_DIR/tcbn65lp_120a/tcbn65lp.v \
	    		$CELL_RTL_DIR/tcbn65lphvt_100a/tcbn65lphvt.v \
			)
		breaksw
		case "ASAP7" :
			set CELL_RTL_DIR = "/usr/users/ide/hard/archive/asap7_lib/lib/Verilog"
			set RTL_FILE = ( \
				$CELL_RTL_DIR/asap7sc7p5t_AO_RVT_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_AO_SRAM_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_INVBUF_RVT_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_INVBUF_SRAM_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_OA_RVT_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_OA_SRAM_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_SEQ_RVT_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_SEQ_SRAM_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_SIMPLE_RVT_TT_08302018.v \
				$CELL_RTL_DIR/asap7sc7p5t_SIMPLE_SRAM_TT_08302018.v \
			)
		breaksw
		default :
			echo "no process is selected"
			exit 1
		breaksw
	endsw
else
	set RTL_FILE = ()
endif

########################################
#     Simulation Target Selection      #
########################################
#set DEFAULT_DESIGN = "p_add"
#set DEFAULT_DESIGN = "p_sub"
#set DEFAULT_DESIGN = "p_mult"
#set DEFAULT_DESIGN = "exp_prec"
#set DEFAULT_DESIGN = "rdc_prec"
#set DEFAULT_DESIGN = "p_acc"
set DEFAULT_DESIGN = "act_func"

if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif

set valid = 0
source rtl.sh

if ( $valid != 1 ) then
	echo "Invalid Target"
	exit 1
endif


########################################
#        Simulation Tool Setup         #
########################################
#set SIM_TOOL = "ncverilog"
set SIM_TOOL = "xmverilog"
#set SIM_TOOL = "vcs"

switch( $SIM_TOOL )
	case "ncverilog" :
		set SIM_OPT = ( \
			+nc64bit \
			+define+SimVision \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)
	breaksw
	case "xmverilog" :
		set SIM_OPT = ( \
			+64bit \
			+define+SimVision \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)
	breaksw
	case "vcs" :
		set SIM_OPT = ( \
			-o ${TOP_MODULE}.sim \
			-full64 \
			+define+VCS \
			+incdir+.include \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilogext+.sv \
			+verilog2001ext+.v \
		)
	breaksw
	default :
		echo "Simulation Tool is not selected"
		exit 1
	breaksw
endsw


##############################
#       run simulation       #
##############################
${SIM_TOOL} \
	${SIM_OPT} \
	${SRC_EXT} \
	+access+r \
	+notimingchecks \
	-ALLOWREDEFINITION \
	${INCLUDE} \
	${DEFINES} \
	${TEST_FILE} \
	${RTL_FILE}
