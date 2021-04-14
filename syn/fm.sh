#/bin/tcsh

###############################################
########    Formal Verification      ##########
###############################################

##### Top design name
if ( $#argv == 0 ) then
	# design name
	#set DESIGN_NAME = sample_com
	set DESIGN_NAME = sample_seq
	#set DESIGN_NAME = sample_lib_conv
else
	set DESIGN_NAME = $1
endif



##### tool settings
if ( $#argv == 0 || $#argv == 1 ) then
	#set TOOL = fm_shell
	set TOOL = lec
else
	set TOOL = $2
endif
setenv tool_name $TOOL



##### Log and Synthesis Result Directory
set TCL_DIR	= "tcl"
set LOG_DIR = "log"
set REPORT_DIR = "report"
set RESULT_DIR = "result"
mkdir -p ${LOG_DIR}
mkdir -p ${RESULT_DIR}
mkdir -p ${REPORT_DIR}
mkdir -p ${RESULT_DIR}/${DESIGN_NAME}
mkdir -p ${REPORT_DIR}/${DESIGN_NAME}



##### Run verification
if ( $TOOL == "fm_shell" ) then
	fm_shell -f ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/fm_${DESIGN_NAME}.log
else if ( $TOOL == "lec" ) then
	# conformal
	lec -NOGui -TclMode ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/lec_${DESIGN_NAME}.log
endif
