#/bin/tcsh

###########################################
###              Synthesis              ###
###########################################

##### Top design name
if ( $#argv == 0 ) then
	# design name
	#set DESIGN_NAME = sample_com
	#set DESIGN_NAME = sample_seq
	set DESIGN_NAME = sample_lib_conv
else
	set DESIGN_NAME = $1
endif



##### tool settings
if ( $#argv <= 1 ) then
	set TOOL = dc_shell
	#set TOOL = genus
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



##### Run synthesis
if ( $TOOL == "dc_shell" ) then
	dc_shell -f ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/${DESIGN_NAME}.dc.log
else if ( $TOOL == "genus" ) then
	genus -f ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/${DESIGN_NAME}.genus.log
endif
