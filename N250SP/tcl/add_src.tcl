############################################################################
############################################################################
##
## Copyright 2018 International Business Machines
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
############################################################################
############################################################################

#Adding source files
add_files -norecurse $common_src/capi_en_rise_dff.vhdl >> $log_file
add_files -norecurse $common_src/capi_en_rise_vdff.vhdl >> $log_file
add_files -norecurse $common_src/CAPI_FPGA_RESET_GEN.v >> $log_file
add_files -norecurse $common_src/capi_gpio12.vhdl >> $log_file
add_files -norecurse $common_src/capi_gpio1.vhdl >> $log_file
add_files -norecurse $common_src/capi_gpo1.vhdl >> $log_file
add_files -norecurse $common_src/capi_gpo26.vhdl >> $log_file
add_files -norecurse $common_src/capi_i2cacc.vhdl >> $log_file
add_files -norecurse $common_src/capi_i2c.vhdl >> $log_file
add_files -norecurse $common_src/capi_ram32x8.vhdl >> $log_file
add_files -norecurse $common_src/capi_reversebus16.vhdl >> $log_file
add_files -norecurse $common_src/capi_rise_dff_init1.vhdl >> $log_file
add_files -norecurse $common_src/capi_rise_dff.vhdl >> $log_file
add_files -norecurse $common_src/capi_rise_vdff.vhdl >> $log_file
add_files -norecurse $common_src/capi_sreconfig.vhdl >> $log_file
add_files -norecurse $common_src/CAPI_STP_COUNTER.v >> $log_file
add_files -norecurse $common_src/capi_xilstrte3.vhdl >> $log_file

add_files -scan_for_includes $fpga_src/capi_gpo.vhdl >> $log_file
add_files -scan_for_includes $fpga_src/capi_gpio.vhdl >> $log_file
add_files -scan_for_includes $fpga_src/capi_svcrc.vhdl >> $log_file
