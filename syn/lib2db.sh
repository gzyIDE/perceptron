#!/bin/tcsh

###########################################
###            db generation            ###
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
set TOOL = lc_shell
setenv tool_name $TOOL



##### Log and Synthesis Result Directory
set TCL_DIR	= "tcl"
set LOG_DIR = "log"
set DB_DIR = "db"
set REPORT_DIR = "report"
set RESULT_DIR = "result"
mkdir -p ${LOG_DIR}
mkdir -p ${DB_DIR}



##### Run library convertion
$TOOL -f ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/${DESIGN_NAME}.lc.log
