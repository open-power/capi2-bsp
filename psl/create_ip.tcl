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

set fpga_part $::env(FPGA_PART)
set fpga_card $::env(FPGA_CARD)

set psl_version $::env(PSL_VERSION)
set ver_major [string range $psl_version 0 [string first "." $psl_version]-1]
set ver_minor [string range $psl_version [string first "." $psl_version]+1 end]

set psl9_src   $::env(PSL9_SRC)

if { [info exists ::env(PSL_ROOT_DIR)] == 1 } {
  set psl_root_dir  $::env(PSL_ROOT_DIR)
} else {
  set psl_root_dir  .
}
if { [info exists ::env(BUILD_DIR)] == 1 } {
  set build_dir  $::env(BUILD_DIR)
} else {
  set build_dir  $psl_root_dir/build_$fpga_part
}
if { [info exists ::env(PSL9_DIR)] == 1 } {
  set psl9_dir  $::env(PSL9_DIR)
} else {
  set psl9_dir  $psl_root_dir/psl9
}
if { [info exists ::env(PSL9_SRC)] == 1 } {
  set psl9_src  $::env(PSL9_SRC)
} else {
  set psl9_src  $psl9_dir/src/verilog
}
if { [info exists ::env(OUTPUT_DIR)] == 1 } {
  set output_dir $::env(OUTPUT_DIR)
} else {
  set output_dir $build_dir/output
}
if { [info exists ::env(PSL9_IP_REPO)] == 1 } {
  set ip_repo_dir $::env(PSL9_IP_REPO)
} else {
  set ip_repo_dir $psl9_dir/ip_repo
}
if { [info exists ::env(PSL_LOGS_DIR)] == 1 } {
  set logs_dir  $::env(PSL_LOGS_DIR)
} else {
  set logs_dir  $build_dir/logs
}
set log_file   $logs_dir/create_ip.log


# Create project
create_project psl9d $build_dir/viv_project -part $fpga_part -force >> $log_file

if {$fpga_card eq "U200"} {
  set_property board_part xilinx.com:au200:part0:1.0 [current_project]
}


if { ! [file exists $ip_repo_dir] } {
  puts "Creating PSL9 IP core from encrypted sources"
  set obj [get_filesets sources_1]
  add_files -norecurse -fileset $obj $psl9_src >> $log_file

  set file_obj [get_files -of_objects [get_filesets sources_1] [list "*defines*"]]
  set_property "file_type" "Verilog Header" $file_obj

  set_property -name "top" -value "PSL9_WRAP" -objects $obj


  # Set 'constrs_1' fileset object
  set obj [get_filesets constrs_1]

  # Add/Import constrs file and set constrs file properties
  set file [file normalize $psl_root_dir/psl9_clocks_ooc.xdc]
  set file_added [add_files -norecurse -fileset $obj $file]
  set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
  set_property -name "file_type" -value "XDC" -objects $file_obj >> $log_file
  set_property -name "library" -value "work" -objects $file_obj >> $log_file
  set_property -name "used_in" -value "out_of_context" -objects $file_obj >> $log_file
  set_property -name "used_in_implementation" -value "0" -objects $file_obj >> $log_file
  set_property -name "used_in_synthesis" -value "0" -objects $file_obj >> $log_file

  update_compile_order -fileset sources_1 >> $log_file


  # Package IP
  ipx::package_project -root_dir $ip_repo_dir -vendor ibm.com -library CAPI -taxonomy /UserIP -import_files -generated_files -force >> $log_file
  set_property version $ver_major.$ver_minor [ipx::current_core] >> $log_file
  set_property display_name PSL9_WRAP_v${ver_major}_$ver_minor [ipx::current_core] >> $log_file
  set_property description PSL9_WRAP_v${ver_major}_$ver_minor [ipx::current_core] >> $log_file
  set_property supported_families {virtexu Production zynquplus Production virtexuplus Production kintexuplus Production kintexu Production virtexuplushbm Production} [ipx::current_core] >> $log_file
  set_property core_revision 1 [ipx::current_core] >> $log_file
  update_compile_order -fileset sources_1 >> $log_file
  ipx::create_xgui_files [ipx::current_core] >> $log_file
  ipx::update_checksums [ipx::current_core] >> $log_file
  ipx::save_core [ipx::current_core] >> $log_file
  ipx::check_integrity -quiet [ipx::current_core] >> $log_file
}

file mkdir $output_dir
file link -symbolic $output_dir/ip_repo $ip_repo_dir
set_property ip_repo_paths $output_dir/ip_repo [current_project] >> $log_file
update_ip_catalog >> $log_file

create_ip -name PSL9_WRAP -vendor ibm.com -library CAPI -version $ver_major.$ver_minor -module_name PSL9_WRAP_0 -dir $output_dir >> $log_file
set_property generate_synth_checkpoint false [get_files PSL9_WRAP_0.xci] >> $log_file
generate_target all                          [get_files PSL9_WRAP_0.xci] >> $log_file
