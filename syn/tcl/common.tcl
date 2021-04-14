# Number of CPU Cores for compilation
set MAX_CORE	4

# Transistor Process selection
#set PROCESS "ASAP7"
set PROCESS "SKY130"

# toolchain setting
set synopsys_tools [info exist synopsys_program_name]
if { $synopsys_tools == 1 } {
	set USE_DB 1
} else {
	set USE_DB 0
}

# Process depending environment settings
if { $PROCESS == "ASAP7" } {
	# ASAP7 PDK
	#	url: 
	#		http://asap.asu.edu/asap/
	#	publication:
	#		L.T. Clark, V. Vashishtha, L. Shifren, A. Gujja, S. Sinha, 
	#		B. Cline, C. Ramamurthya, and G. Yeric, 
	#		"ASAP7: A 7-nm FinFET Predictive Process Design Kit,"
	#		Microelectronics Journal, vol. 53, pp. 105-115, July 2016
	set CELLLIB "./ASAP7_PDKandLIB_v1p6/lib_release_191006"
	if { $USE_DB == 1 } {
		set CELLDIR "${CELLLIB}/asap7_7p5t_library/rev25/DB/NLDM"
	} else {
		set CELLDIR "${CELLLIB}/asap7_7p5t_library/rev25/LIB/NLDM"
	}

	# set target library cells
	set CORNERS [list \
		FF_08302018 \
		SS_08302018 \
		TT_08302018 \
	]

	# name of libraries (except corner)
	#    (In this example, only regular VT cells are used)
	set TARGET_CELL_NAME [list \
		${CELLDIR}/asap7sc7p5t_SIMPLE_RVT_ \
		${CELLDIR}/asap7sc7p5t_SEQ_RVT_ \
		${CELLDIR}/asap7sc7p5t_OA_RVT_ \
		${CELLDIR}/asap7sc7p5t_INVBUF_RVT_ \
		${CELLDIR}/asap7sc7p5t_AO_RVT_ \
	]
} elseif { $PROCESS == "SKY130" } {
	# SkyWater Open Source PDK
	#	github:
	#		https://github.com/google/skywater-pdk
	#	url:
	#		https://skywater-pdk.readthedocs.io/en/latest/

	# this example uses only high speed standard cells 
	set CELLLIB "./skywater-pdk/libraries"
	# Create .db files in ${CELLDIR} if necessary...
	set CELLDIR "${CELLLIB}/sky130_fd_sc_hs/latest/timing"
	set CORNERS [list \
		ff_100C_1v95 \
		ff_150C_1v95 \
		ff_n40C_1v56 \
		ff_n40C_1v76 \
		ff_n40C_1v95 \
		ff_n40C_1v95_ccsnoise \
		ss_100C_1v60 \
		ss_150C_1v60 \
		ss_n40C_1v28 \
		ss_n40C_1v44 \
		ss_n40C_1v60 \
		ss_n40C_1v60_ccsnoise \
		tt_025C_1v20 \
		tt_025C_1v35 \
		tt_025C_1v44 \
		tt_025C_1v50 \
		tt_025C_1v62 \
		tt_025C_1v68 \
		tt_025C_1v80 \
		tt_025C_1v80_ccsnoise \
		tt_025C_1v89 \
		tt_025C_2v10 \
		tt_100C_1v80 \
		tt_150C_1v80 \
	]
	set TARGET_CELL_NAME [list \
		${CELLDIR}/sky130_fd_sc_hs__ \
	]
} elseif { $PROCESS == "TEMPLATE" } {
	set CELLLIB "cell_library_top"
	if { $USE_DB == 1 } {
		set CELLDIR "db_dir"
	} else {
		set CELLDIR "lib_dir"
	}

	# set target library cells
	set CORNERS [list \
		corners \
	]

	# name of libraries (except corner)
	#    (In this example, only regular VT cells are used)
	set TARGET_CELL_NAME [list \
		library_cells \
	]
} else {
	echo "Select Some Process for Synthesis"
	exit
}



##### Cell library settings
# cell libraries
set target_cell [list]
foreach cell_name $TARGET_CELL_NAME {
	foreach corner $CORNERS {
		lappend target_cell ${cell_name}${corner}
	}
}

# hard ip libraries
set hard_ip [list]
if { [info exist HARDIP] } {
	foreach ip $HARDIP {
		foreach corner $CORNERS {
			lappend hard_ip ${ip}_${corner}
		}
	}
}

# library format
if { $USE_DB == 1 } {
	### add library extention
	set target_library [list]
	foreach lib_each [concat $target_cell $hard_ip] {
		lappend target_library  ${lib_each}.db
	}
} else {
	# add library extention
	set target_library [list]
	foreach lib_each [concat $target_cell $hard_ip] {
		lappend target_library  ${lib_each}.lib
	}
}



##### Tool dependent scripts
if { [info exist synopsys_program_name] } {
	##### Synopsys Tool chain (Design Compiler, Formality)
	#### processor count
	set_host_option -max_cores ${MAX_CORE}

	### search path setting
	set_app_var search_path [concat $search_path ${DBDIR}]
} else {
	##### Cadence Tool chain (Genus, Conformal )
}

switch $env(tool_name) {
	"dc_shell" {
		### Design Compiler
		# verification file setting
		set_svf ${RESULTDIR}/${DESIGN}/${DESIGN}.mapped.svf

		# library for synthesis
		set DW_LIB ${synopsys_root}/libraries/syn/dw_foundation.sldb
		set_app_var synthetic_library ${DW_LIB}
		set_app_var link_library [concat $target_library $DW_LIB]

		# read verilog file
		if { [info exist FILE_LIST] } {
			analyze -format verilog ${FILE_LIST}
		}
		if { [info exist SV_FILE_LIST] } {
			analyze -format sverilog ${SV_FILE_LIST}
		}
		elaborate ${DESIGN}

		# dont touch constraints
		if { [info exist DONT_TOUCH_CELL] } {
			foreach cell ${DONT_TOUCH_CELL} {
				set_dont_touch [get_cells -hierarchical $cell]
			}
		}
		#set_dont_touch ${DONT_TOUCH_CELLS}

		# synthesis option and compile
		source -echo -verbose ${TCLDIR}/clk_const.tcl
		check_design > ${REPORTDIR}/${DESIGN}/check_design.rpt
		compile_ultra

		# reports
		report_area -nosplit > ${REPORTDIR}/${DESIGN}/report_area.rpt
		report_power -nosplit > ${REPORTDIR}/${DESIGN}/report_power.rpt
		report_timing -nosplit > ${REPORTDIR}/${DESIGN}/report_timing.rpt

		# output result
		write -hierarchy -format ddc -output ${RESULTDIR}/${DESIGN}/${DESIGN}.ddc
		write -hierarchy -format verilog -output ${RESULTDIR}/${DESIGN}/${DESIGN}.mapped.v
		if { [info exists SV_FILE_LIST] } {
			# if source contains systemverilog files, output systemverilog netlist wrapper
			write -hierarchy -format svsim -output ${RESULTDIR}/${DESIGN}/${DESIGN}_svsim.sv
		}
	}

	"fm_shell" {
		### Formality
		# library for formal verification
		# Setting Design Compiler Directory
		regexp {(.*)(bin/dc_shell)} [exec which dc_shell] -> dc_shell_path
		set_app_var hdlin_dwroot $dc_shell_path
		read_db -technology_library ${target_library}

		# load reference
		if { [info exist FILE_LIST] } {
			read_verilog -r ${FILE_LIST} -work_library WORK
		}
		if { [info exist SV_FILE_LIST] } {
			read_sverilog -r ${SV_FILE_LIST} -work_library WORK
		}
		set_top r:/WORK/${DESIGN}

		# load implementation
		read_ddc -i ${RESULTDIR}/${DESIGN}/${DESIGN}.ddc
		set_top i:/WORK/${DESIGN}

		# matching reference and implementation
		match

		# output result
		if { ![verify] } {  
			report_unmatched_points > ${REPORTDIR}/${DESIGN}/fmv_unmatched_points.rpt
			report_failing_points > ${REPORTDIR}/${DESIGN}/fmv_failing_points.rpt
			report_aborted > ${REPORTDIR}/${DESIGN}fmv_aborted_points.rpt
			analyze_points -failing > ${REPORTDIR}/${DESIGN}/fmv_failing_analysis.rpt
			report_svf_operation [find_svf_operation -status rejected]
		}
	}

	"lc_shell" {
		foreach ip ${hard_ip} {
			if { ![ file exists ${ip}.db ] } {
				# typical corner
				read_lib ${LIBDIR}/${ip}.lib
				write_lib ${ip} -output ${DBDIR}/${ip}.db
				remove_lib ${ip}
			}
		}
	}

	"genus" {
		##### Cadence Tool chain (GENUS)
		# target design
		set design ${DESIGN}

		# path/library settings
		set_db / .lib_search_path [concat . ${CELLDIR} ${LIBDIR}]
		set_db / .library $target_library

		# read hdl
		set_db / .hdl_search_path $search_path
		if { [info exist FILE_LIST] } {
			read_hdl ${FILE_LIST}
		}
		if { [info exist SV_FILE_LIST] } {
			read_hdl -sv ${SV_FILE_LIST}
			if { [info exist SV_COMPLEX_PORT]} {
				set_db / .hdl_sv_module_wrapper true
			}
		}
		elaborate

		# set top design
		#set design ${DESIGN}
		current_design ${DESIGN}

		# dont touch constraints
		if { [info exist DONT_TOUCH_CELL] } {
			foreach cell ${DONT_TOUCH_CELL} {
				set_dont_touch [get_cells -hierarchical $cell]
			}
		}
		#set_dont_touch ${DONT_TOUCH_CELLS}
		
		# synthesis option and compile
		source -echo -verbose ${TCLDIR}/clk_const.tcl
		check_design > ${REPORTDIR}/${DESIGN}/check_design.rpt

		# synthesis
		syn_generic
		syn_map
		syn_opt

		# output result
		write_hdl -generic ${DESIGN} > ${RESULTDIR}/${DESIGN}/${DESIGN}.generic_gate.v
		write_hdl -lec ${DESIGN} > ${RESULTDIR}/${DESIGN}/${DESIGN}.mapped.v
		if { [info exist SV_FILE_LIST] } {
			# if source contains systemverilog files, 
			#    and contains complex ports (array, union, interface, etc...)
			#    conoutput systemverilog netlist wrapper
			if { [info exist SV_COMPLEX_PORT] } {
				write_sv_wrapper -wrapper_name ${DESIGN}_svsim \
					-module ${DESIGN} > ${RESULTDIR}/${DESIGN}/${DESIGN}_svsim.sv
			}
		}

		# report
		report_area > ${REPORTDIR}/${DESIGN}/report_area.rpt
		report_power > ${REPORTDIR}/${DESIGN}/report_power.rpt
		report_timing > ${REPORTDIR}/${DESIGN}/report_timing.rpt
	}

	"lec" {
		# run on setup-mode
		# search path setting
		add_search_path ${search_path} -design
		add_search_path [concat . ${CELLDIR} ${LIBDIR}] -library

		# read library
		read_library $target_library -liberty

		# read original rtl files (golden)
		if { [info exist FILE_LIST] } {
			read_design $FILE_LIST -golden -verilog
		}
		if { [info exist SV_FILE_LIST] } {
			read_design $SV_FILE_LIST -golden -systemverilog
		}

		# read synthesized netlists (revised)
		read_design ${RESULTDIR}/${DESIGN}/${DESIGN}.mapped.v -revised -verilog

		# set top module (only if necessary)
		#set_root_module ${DESIGN}

		# switch to lec-mode
		set_system_mode lec

		# key point mapping ( Automatically run on entring to LEC mode )
		#map_key_points

		# run comparioson between Golden and revised
		add_compared_points -all
		compare

		# report compare result
		report_compared_points > ${REPORTDIR}/${DESIGN}/lec_compared_points.rpt
		report_compare_data > ${REPORTDIR}/${DESIGN}/lec_compare_data.rpt
		report_statistics > ${REPORTDIR}/${DESIGN}/lec_statistics.rpt

		# report current status
		#report_environment
	}
}
