# parameter settings

# For ASAP7
#   time unit : ps (different by process technology)
#	synthesis target : 2GHz
#set CLK_CYC			500

# For Skywater-130
#   time unit : ns
#	synthesis target : 1GHz
set CLK_CYC			1

set IN_DELAY_RATIO	0.1
set OUT_DELAY_RATIO	0.1

########## clock constraints ##########
if {[info exists CLOCK_SIG_NAME]} {
	create_clock \
		[get_ports ${CLOCK_SIG_NAME}] \
		-name CPU_CLK \
		-period ${CLK_CYC} \
		-waveform [list 0.000 [expr $CLK_CYC/2.0]]

	set inputs [remove_from_collection [all_inputs] [get_ports ${CLOCK_SIG_NAME}]]
	set_input_delay [expr $IN_DELAY_RATIO * $CLK_CYC] -clock CPU_CLK $inputs

	set outputs [all_outputs]
	set_output_delay [expr $OUT_DELAY_RATIO * $CLK_CYC] -clock CPU_CLK $outputs

	set_ideal_network [get_ports ${CLOCK_SIG_NAME}]
	set_dont_touch_network [get_ports ${CLOCK_SIG_NAME}]
}

########## reset configuration ##########
if { [info exists RESET_SIG_NAME] } {
	set_ideal_network [ get_ports ${RESET_SIG_NAME} ]
	#set_ideal_latency [expr CLK_CYC/2] [get_ports reset_]
	#set_ideal_transition 0.30 [get_ports reset_]
}

if {![info exists RESET_SIG_NAME] && ![info exists RESET_SIG_NAME]} {
	set_max_delay $CLK_CYC -from [all_inputs] -to [all_outputs]
}

if {[info exists MAX_FANOUT]} {
	set_max_fanout ${MAX_FANOUT} ${DESIGN}
}
