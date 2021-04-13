#!/bin/tcsh

##### File and Directory Settings
set TOPDIR = ".."
set RTLDIR = "${TOPDIR}/rtl"
set SLPDIR = "${TOPDIR}/slp"
set MLPDIR = "${TOPDIR}/mlp"
set TESTDIR = "${TOPDIR}/test"
set TESTRTLDIR = "${TESTDIR}/rtl_test"
set TESTSLPDIR = "${TESTDIR}/slp_test"
set TESTMLPDIR = "${TESTDIR}/mlp_test"
set GATEDIR = "${TOPDIR}/syn/result"
set DEFINES = ()
set INCLUDE = ()
set DEFINE_LIST = ( SIMULATION )



##### Include directories
set INCDIR= ( \
	${TOPDIR}/include \
	${TESTDIR}/include \
)



##### Output Waves
set Waves = 1
set WaveOpt
if ( $Waves =~ 1 ) then
	set DEFINE_LIST = ($DEFINE_LIST WAVE_DUMP)
else
	set DEFINE_LIST = ()
endif



###### Gate Level Simulation
# set GATE = 1
set GATE = 0
if ( $GATE =~ 1 ) then
	set DEFINE_LIST = ($DEFINE_LIST NETLIST)
endif



##### Process Setting
#set Process = "ASAP7"
set Process = "None"

switch ($Process)
	case "ASAP7" :
		set CELL_LIB = "./ASAP7_PDKandLIB_v1p6/lib_release_191006"
		set CELL_RTL_DIR = "${CELL_LIB}/asap7_7p5t_library/rev25/Verilog"
		set DEFINE_LIST = (${DEFINE_LIST} ASAP7)

		set CORNERS = ( \
			TT_08302018 \
		)
		#	FF_08302018 \
		#	SS_08302018 \

		set CELL_NAME = ( \
			${CELL_RTL_DIR}/asap7sc7p5t_SIMPLE_RVT \
			${CELL_RTL_DIR}/asap7sc7p5t_SEQ_RVT \
			${CELL_RTL_DIR}/asap7sc7p5t_OA_RVT \
			${CELL_RTL_DIR}/asap7sc7p5t_INVBUF_RVT \
			${CELL_RTL_DIR}/asap7sc7p5t_AO_RVT \
		)

		set RTL_FILE = ()
		foreach cell ( $CELL_NAME )
			foreach corner ( $CORNERS )
				set RTL_FILE = ( \
					${RTL_FILE} \
					${cell}_${corner}.v \
				)
			end
		end
	breaksw

	default :
		# Simulation with simple gate model (Process = "None")
		# Nothing to set
		set RTL_FILE = ()
	breaksw
endsw

########################################
#     Simulation Target Selection      #
########################################
source target.sh

if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif

set valid = 0
source rtl.sh
source slp.sh

if ( $valid != 1 ) then
	echo "Invalid Target"
	exit 1
endif


########################################
#        Simulation Tool Setup         #
########################################
source sim_tool.sh

switch( $SIM_TOOL )
	case "ncverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+CADENCE
		endif

		set SIM_OPT = ( \
			+nc64bit \
			$WaveOpt \
			+access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "xmverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+CADENCE
		endif

		set SIM_OPT = ( \
			+64bit \
			$WaveOpt \
			+access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "vcs" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+SYNOPSYS
		endif

		set SIM_OPT = ( \
			-o ${TOP_MODULE}.sim \
			-full64 \
			$WaveOpt \
			+incdir+.include \
			-debug_access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilogext+.sv \
			+verilog2001ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "verilator" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+VCD
		endif

		set SIM_OPT = ( \
			-lint-only \
			$WaveOpt \
			+notimingchecks \
		)

		set SRC_EXT = ( \
			+libext+.v.sv \
			+systemverilogext+.sv \
		)

		set DEFINE_LIST = ( \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "xilinx_sim" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = (-d VCD)
		endif

		set SIM_OPT = ( \
			$WaveOpt \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				--define $def \
				$DEFINES \
			)
		end

		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				--include $dir \
				$INCLUDE \
			)
		end
	breaksw

	default :
		echo "Simulation Tool is not selected"
		exit 1
	breaksw
endsw



##### run simulation
if ( ${SIM_TOOL} =~ "xilinx_sim" ) then
	xvlog \
		--sv \
		${SIM_OPT} \
		${INCLUDE} \
		${DEFINES} \
		${TEST_FILE} \
		${RTL_FILE}

	xelab ${TOP_MODULE}_test
	xsim --R ${TOP_MODULE}_test
else
	${SIM_TOOL} \
		${SIM_OPT} \
		${SRC_EXT} \
		${INCLUDE} \
		${DEFINES} \
		${TEST_FILE} \
		${RTL_FILE}
endif

