#!/bin/tcsh

###########################################
########  Synthesis and Formality  ########
###########################################

##### Top design name
set DESIGN_NAME = slp



##### tool settings
### Logic Synthesis
set SYN_TOOL = dc_shell
#set SYN_TOOL = genus
### Formal Verification (RTL vs Netlist)
set FM_TOOL = fm_shell
#set FM_TOOL = lec



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



##### Run synthesis and verification
if ( $SYN_TOOL == dc_shell ) then
	./lib2db.sh $DESIGN_NAME
endif
./syn.sh $DESIGN_NAME $SYN_TOOL
./fm.sh $DESIGN_NAME $FM_TOOL
