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
set fpga_card        $::env(FPGA_CARD)

## Create a new Vivado IP Project
set log_file $::env(CARD_LOGS)/create_required_ip.log
puts "\[CREATE REQUIRED IP..\] start [clock format [clock seconds] -format {%T %a %b %d %Y}]"
exec rm -rf $ip_dir
create_project managed_ip_project $ip_dir/managed_ip_project -part $fpga_part -ip >> $log_file
if {$fpga_card eq "U200"} {
  set_property board_part xilinx.com:au200:part0:1.0 [current_project]
}

# Project IP Settings
# General
set_property target_language VHDL [current_project]

# Create card specific IPs
source $card_tcl/create_ip.tcl

close_project >> $log_file
puts "\[CREATE REQUIRED IP..\] done  [clock format [clock seconds] -format {%T %a %b %d %Y}]"
