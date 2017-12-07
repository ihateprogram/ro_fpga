# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CNT_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEVICE_ID" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DICTIONARY_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DICTIONARY_DEPTH_LOG" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LOOK_AHEAD_BUFF_DEPTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.CNT_WIDTH { PARAM_VALUE.CNT_WIDTH } {
	# Procedure called to update CNT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CNT_WIDTH { PARAM_VALUE.CNT_WIDTH } {
	# Procedure called to validate CNT_WIDTH
	return true
}

proc update_PARAM_VALUE.DEVICE_ID { PARAM_VALUE.DEVICE_ID } {
	# Procedure called to update DEVICE_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEVICE_ID { PARAM_VALUE.DEVICE_ID } {
	# Procedure called to validate DEVICE_ID
	return true
}

proc update_PARAM_VALUE.DICTIONARY_DEPTH { PARAM_VALUE.DICTIONARY_DEPTH } {
	# Procedure called to update DICTIONARY_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DICTIONARY_DEPTH { PARAM_VALUE.DICTIONARY_DEPTH } {
	# Procedure called to validate DICTIONARY_DEPTH
	return true
}

proc update_PARAM_VALUE.DICTIONARY_DEPTH_LOG { PARAM_VALUE.DICTIONARY_DEPTH_LOG } {
	# Procedure called to update DICTIONARY_DEPTH_LOG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DICTIONARY_DEPTH_LOG { PARAM_VALUE.DICTIONARY_DEPTH_LOG } {
	# Procedure called to validate DICTIONARY_DEPTH_LOG
	return true
}

proc update_PARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH { PARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH } {
	# Procedure called to update LOOK_AHEAD_BUFF_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH { PARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH } {
	# Procedure called to validate LOOK_AHEAD_BUFF_DEPTH
	return true
}


proc update_MODELPARAM_VALUE.DICTIONARY_DEPTH { MODELPARAM_VALUE.DICTIONARY_DEPTH PARAM_VALUE.DICTIONARY_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DICTIONARY_DEPTH}] ${MODELPARAM_VALUE.DICTIONARY_DEPTH}
}

proc update_MODELPARAM_VALUE.DICTIONARY_DEPTH_LOG { MODELPARAM_VALUE.DICTIONARY_DEPTH_LOG PARAM_VALUE.DICTIONARY_DEPTH_LOG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DICTIONARY_DEPTH_LOG}] ${MODELPARAM_VALUE.DICTIONARY_DEPTH_LOG}
}

proc update_MODELPARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH { MODELPARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH PARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH}] ${MODELPARAM_VALUE.LOOK_AHEAD_BUFF_DEPTH}
}

proc update_MODELPARAM_VALUE.CNT_WIDTH { MODELPARAM_VALUE.CNT_WIDTH PARAM_VALUE.CNT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CNT_WIDTH}] ${MODELPARAM_VALUE.CNT_WIDTH}
}

proc update_MODELPARAM_VALUE.DEVICE_ID { MODELPARAM_VALUE.DEVICE_ID PARAM_VALUE.DEVICE_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEVICE_ID}] ${MODELPARAM_VALUE.DEVICE_ID}
}

