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

# add pcie4_uscale_plus
add_files -norecurse                             $ip_dir/pcie4_uscale_plus_0/pcie4_uscale_plus_0.xci  -force >> $log_file
# export_ip_user_files -of_objects      [get_files $ip_dir/pcie4_uscale_plus_0/pcie4_uscale_plus_0.xci] -no_script -sync -force >> $log_file
# set_property used_in_simulation false [get_files $ip_dir/pcie4_uscale_plus_0/pcie4_uscale_plus_0.xci] >> $log_file
# add sem_ultra
add_files -norecurse                             $ip_dir/sem_ultra_0/sem_ultra_0.xci  -force >> $log_file
export_ip_user_files -of_objects      [get_files $ip_dir/sem_ultra_0/sem_ultra_0.xci] -no_script -sync -force >> $log_file
set_property used_in_simulation false [get_files $ip_dir/sem_ultra_0/sem_ultra_0.xci]  >> $log_file
# add uscale_plus_clk_wiz
add_files -norecurse                             $ip_dir/uscale_plus_clk_wiz/uscale_plus_clk_wiz.xci  -force >> $log_file
export_ip_user_files -of_objects      [get_files $ip_dir/uscale_plus_clk_wiz/uscale_plus_clk_wiz.xci] -no_script -sync -force >> $log_file
set_property used_in_simulation false [get_files $ip_dir/uscale_plus_clk_wiz/uscale_plus_clk_wiz.xci] >> $log_file
