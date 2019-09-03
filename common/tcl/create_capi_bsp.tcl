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

set ip_dir           $::env(CARD_IP)
set psl_ip_dir       $::env(PSL_IP)
set psl_version      $::env(PSL_VERSION)
set capi_bsp_gen_dir $::env(CARD_CAPI_BSP_GEN)
set capi_bsp_version $::env(CAPI_BSP_VERSION)
set fpga_part        $::env(FPGA_PART)
set proj_dir         $::env(CARD_BUILD)/viv_project
set card_tcl         $::env(CARD_TCL)
set common_tcl       $::env(COMMON_TCL)
set card_src         $::env(CARD_SRC)
set common_src       $::env(COMMON_SRC)
set fpga_src         $::env(FPGA_SRC)
set card_xdc         $::env(CARD_XDC)
set vivado           $::env(XILINX_VIVADO)
set top_level        capi_bsp
set proj_name        capi_board_support
set fpga_card        $::env(FPGA_CARD)

source $common_tcl/create_ip.tcl

set log_file $::env(CARD_LOGS)/create_capi_bsp.log
## Create a new Vivado IP Project
puts "\[CREATE CAPI BSP.....\] start [clock format [clock seconds] -format {%T %a %b %d %Y}]"

create_project $proj_name $proj_dir -part $fpga_part -force >> $log_file
if {$fpga_card eq "U200"} {
  set_property board_part xilinx.com:au200:part0:1.0 [current_project]
#  set_property coreContainer.enable 1 [current_project]
}


#Add source files
puts "Adding design sources to capi_bsp project"
add_files -scan_for_includes $card_src >> $log_file
source $card_tcl/add_src.tcl

set_property top $top_level [current_fileset]

# Add PSL IP path to IP repository paths
puts "Adding PSL IP to capi_bsp project"
set_property ip_repo_paths "[file normalize $psl_ip_dir]" [current_project]
# Rebuild user ip_repo's index before adding any source files
update_ip_catalog >> $log_file
add_files -norecurse                             $psl_ip_dir/PSL9_WRAP_0/PSL9_WRAP_0.xci  -force >> $log_file

# Add card specific IP
puts "Adding card specific IP to capi_bsp project"
source $card_tcl/add_ip.tcl

# Add constraint files
puts "Adding constraints to capi_bsp project"
foreach xdc_file [glob -nocomplain -dir $card_xdc *] {
  add_files -fileset constrs_1 -norecurse $xdc_file >> $log_file
}

### Package project as IP
puts "Packaging capi_bsp project as IP"
update_compile_order -fileset sources_1 >> $log_file
ipx::package_project -root_dir $capi_bsp_gen_dir -vendor ibm.com -library CAPI -taxonomy /UserIP -import_files -force >> $log_file
set_property sim.ip.auto_export_scripts false [current_project] >> $log_file

set_property version $capi_bsp_version [ipx::current_core] >> $log_file
set_property vendor_display_name IBM [ipx::current_core] >> $log_file
set_property supported_families {zynquplus Production virtexuplus Production kintexuplus Production virtexuplushbm Production} [ipx::current_core] >> $log_file
set_property core_revision 1 [ipx::current_core] >> $log_file
ipx::create_xgui_files [ipx::current_core] >> $log_file
ipx::update_checksums [ipx::current_core] >> $log_file
ipx::save_core [ipx::current_core] >> $log_file
ipx::check_integrity [ipx::current_core] >> $log_file

### Add PSL and capi_bsp IP path to IP repository paths
set_property ip_repo_paths "[file normalize $psl_ip_dir] [file normalize $capi_bsp_gen_dir]" [current_project] >> $log_file
### Rebuild user ip_repo's index before creating IP container
update_ip_catalog >> $log_file

puts "Generating capi_bsp IP"
create_ip -name capi_bsp -vendor ibm.com -library CAPI -version $capi_bsp_version -module_name capi_bsp_wrap -dir $ip_dir >> $log_file
set_property generate_synth_checkpoint false [get_files capi_bsp_wrap.xci] >> $log_file
set_property used_in_simulation false [get_files capi_bsp_wrap.xci] >> $log_file
generate_target all [get_files capi_bsp_wrap.xci] >> $log_file

set capi_bsp_ip_dir $ip_dir/capi_bsp_wrap

## Apply patches (if required) before creating container
if [file exists $card_tcl/patch_ip.tcl] {
  puts "Applying patches"
  source $card_tcl/patch_ip.tcl >> $log_file
}


if [string match "*2018.3" $vivado] {
## Not create container in 2018.3
  close_project >> $log_file
} else {
  puts "Creating capi_bsp IP container"
  convert_ips -to_core_container [get_files $capi_bsp_ip_dir/capi_bsp_wrap.xci] >> $log_file
  
  close_project >> $log_file
  if [file exists $ip_dir/capi_bsp_wrap.xcix] {
    puts "Created $ip_dir/capi_bsp_wrap.xcix"
  } else {
    puts "ERROR: no capi_bsp_wrap.xcix file created!!!"
  }
}
puts "\[CREATE CAPI BSP.....\] done  [clock format [clock seconds] -format {%T %a %b %d %Y}]"
