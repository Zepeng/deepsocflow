set TOP dnn_engine
# set TOP axis_conv_engine

#--------- CONFIG
set RTL_DIR ../../rtl
set XILINX 0
source ../../tcl/config.tcl
set_db hdl_max_loop_limit 10000000

set TECH 65nm
set NUM_MACS [expr $COLS   *$ROWS *$GROUPS*$COPIES]
set REPORT_DIR ../report/${TECH}/${TOP}/${NUM_MACS}
exec mkdir -p $REPORT_DIR

#--------- LIBRARIES
set LIB_DIR ../../../tsmc/${TECH}/GP
set_db library [glob $LIB_DIR/cc_lib/noise_scadv10_cln65gp_hvt_tt_1p0v_25c.lib $LIB_DIR/cc_lib/scadv10_cln65gp_hvt_tt_1p0v_25c.lib]
set_db lef_library [glob $LIB_DIR/lef/tsmc_cln65_a10_6X1Z_tech.lef $LIB_DIR/lef/tsmc_cln65_a10_6X2Z_tech.lef $LIB_DIR/lef/tsmc65_hvt_sc_adv10_macro.lef]
set_db qrc_tech_file $LIB_DIR/other/icecaps.tch
# set LIB_DIR ../../../tsmc/${TECH}/LP
# set_db library [glob $LIB_DIR/lib/sc12_cln65lp_base_hvt_tt_typical_max_1p00v_25c.lib $LIB_DIR/lib/sc12_cln65lp_base_hvt_tt_typical_max_1p20v_25c.lib]
# set_db lef_library [glob $LIB_DIR/lef/sc12_cln65lp_base_hvt.lef]

#--------- READ
read_hdl -mixvlog [glob $RTL_DIR/include/*]
read_hdl -mixvlog [glob $RTL_DIR/external/*]
read_hdl -mixvlog [glob $RTL_DIR/src/*]

#--------- ELABORATE & CHECK
set_db lp_insert_clock_gating true
elaborate $TOP
check_design > ${REPORT_DIR}/check_design.log
uniquify $TOP

#--------- CONSTRAINTS
set PERIOD [expr 1000.0/$FREQ_HIGH]
create_clock -name aclk -period $PERIOD [get_ports aclk]
set_dont_touch_network [all_clocks]
set_dont_touch_network [get_ports {aresetn}]

set design_inputs [get_ports {m_axis_tready s_axis_pixels_tvalid s_axis_pixels_tlast s_axis_pixels_tdata s_axis_pixels_tkeep s_axis_weights_tvalid s_axis_weights_tlast s_axis_weights_tdata s_axis_weights_tkeep}]
set design_outputs [get_ports {s_axis_pixels_tready  s_axis_weights_tready m_axis_tvalid m_axis_tlast m_axis_tdata m_axis_tkeep}]

set_input_delay  [expr $PERIOD * 0.6] -clock aclk $design_inputs
set_output_delay [expr $PERIOD * 0.6] -clock aclk $design_outputs

#--------- RETIME OPTIONS
set_db retime_async_reset true
set_db design:${TOP} .retime true

#--------- SYNTHESIZE
set_db syn_global_effort high
syn_generic
syn_map
syn_opt

#--------- NETLIST
write -mapped > ../output/${TOP}.v
write_sdc > ../output/${TOP}.sdc

#--------- REPORTS
report_area > ${REPORT_DIR}/area.log
report_gates > ${REPORT_DIR}/gates.log
report_timing  -nworst 10 > ${REPORT_DIR}/timing.log
report_congestion > ${REPORT_DIR}/congestion.log
report_messages > ${REPORT_DIR}/messages.log
report_hierarchy > ${REPORT_DIR}/hierarchy.log
report_clock_gating > ${REPORT_DIR}/clock_gating.log

build_rtl_power_models -clean_up_netlist
report_power > ${REPORT_DIR}/power.log