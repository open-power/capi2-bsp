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

set_property IOSTANDARD LVCMOS18 [get_ports pci_pi_nperst0]
set_property PACKAGE_PIN K22 [get_ports pci_pi_nperst0]
set_property PULLUP true [get_ports *pci_pi_nperst0]

set_property PACKAGE_PIN AB5 [get_ports pci_pi_refclk_n0]
set_property PACKAGE_PIN AB6 [get_ports pci_pi_refclk_p0]


set_property PACKAGE_PIN M20 [get_ports {b_flash_dq[4]}]
set_property PACKAGE_PIN L20 [get_ports {b_flash_dq[5]}]
set_property PACKAGE_PIN R21 [get_ports {b_flash_dq[6]}]
set_property PACKAGE_PIN R22 [get_ports {b_flash_dq[7]}]
set_property PACKAGE_PIN P20 [get_ports {b_flash_dq[8]}]
set_property PACKAGE_PIN P21 [get_ports {b_flash_dq[9]}]
set_property PACKAGE_PIN N22 [get_ports {b_flash_dq[10]}]
set_property PACKAGE_PIN M22 [get_ports {b_flash_dq[11]}]
set_property PACKAGE_PIN R23 [get_ports {b_flash_dq[12]}]
set_property PACKAGE_PIN P23 [get_ports {b_flash_dq[13]}]
set_property PACKAGE_PIN R25 [get_ports {b_flash_dq[14]}]
set_property PACKAGE_PIN R26 [get_ports {b_flash_dq[15]}]

set_property PACKAGE_PIN T24 [get_ports {o_flash_a[0]}]
set_property PACKAGE_PIN T25 [get_ports {o_flash_a[1]}]
set_property PACKAGE_PIN T27 [get_ports {o_flash_a[2]}]
set_property PACKAGE_PIN R27 [get_ports {o_flash_a[3]}]
set_property PACKAGE_PIN P24 [get_ports {o_flash_a[4]}]
set_property PACKAGE_PIN P25 [get_ports {o_flash_a[5]}]
set_property PACKAGE_PIN P26 [get_ports {o_flash_a[6]}]
set_property PACKAGE_PIN N26 [get_ports {o_flash_a[7]}]
set_property PACKAGE_PIN N24 [get_ports {o_flash_a[8]}]
set_property PACKAGE_PIN M24 [get_ports {o_flash_a[9]}]
set_property PACKAGE_PIN M25 [get_ports {o_flash_a[10]}]
set_property PACKAGE_PIN M26 [get_ports {o_flash_a[11]}]
set_property PACKAGE_PIN L22 [get_ports {o_flash_a[12]}]
set_property PACKAGE_PIN K23 [get_ports {o_flash_a[13]}]
set_property PACKAGE_PIN L25 [get_ports {o_flash_a[14]}]
set_property PACKAGE_PIN K25 [get_ports {o_flash_a[15]}]
set_property PACKAGE_PIN L23 [get_ports {o_flash_a[16]}]
set_property PACKAGE_PIN L24 [get_ports {o_flash_a[17]}]
set_property PACKAGE_PIN M27 [get_ports {o_flash_a[18]}]
set_property PACKAGE_PIN L27 [get_ports {o_flash_a[19]}]
set_property PACKAGE_PIN J23 [get_ports {o_flash_a[20]}]
set_property PACKAGE_PIN H24 [get_ports {o_flash_a[21]}]
set_property PACKAGE_PIN J26 [get_ports {o_flash_a[22]}]
set_property PACKAGE_PIN H26 [get_ports {o_flash_a[23]}]
set_property PACKAGE_PIN J24 [get_ports {o_flash_a[24]}]
#Revision Select Pins H27 = RS0, G27 = RS1
set_property PACKAGE_PIN H27 [get_ports {o_flash_a[25]}]
#set_property PACKAGE_PIN G27 [get_ports {o_flash_a[26]}]

#Address extension pins only used for some Pass 1 flashgt cards
# set_property PACKAGE_PIN J24 [get_ports {o_flash_a_dup[25]}]
# set_property PACKAGE_PIN J25 [get_ports {o_flash_a_dup[26]}]
set_property PACKAGE_PIN G25  [get_ports o_flash_oen]
set_property PACKAGE_PIN G26  [get_ports o_flash_wen]
set_property PACKAGE_PIN N27  [get_ports o_flash_advn]
set_property PACKAGE_PIN AK17 [get_ports o_flash_rstn]
#set_property IOB TRUE [get_ports {b_flash*}]
#set_property IOB TRUE [get_ports {o_flash*}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[17]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[18]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[19]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[20]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[21]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[22]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[23]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[24]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_flash_a[25]}]
set_property IOSTANDARD LVCMOS18 [get_ports o_flash_advn]
set_property IOSTANDARD LVCMOS18 [get_ports o_flash_oen]
set_property IOSTANDARD LVCMOS18 [get_ports o_flash_rstn]
set_property IOSTANDARD LVCMOS18 [get_ports o_flash_wen]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_flash_dq[15]}]

set_property PACKAGE_PIN J13 [get_ports b_basei2c_sda]
set_property PACKAGE_PIN H13 [get_ports b_basei2c_scl]
set_property IOSTANDARD LVCMOS18 [get_ports b_basei2c_sda]
set_property IOSTANDARD LVCMOS18 [get_ports b_basei2c_scl]

set_property PACKAGE_PIN AG9 [get_ports b_smbus_scl]
set_property PACKAGE_PIN AE8 [get_ports b_smbus_sda]
set_property IOSTANDARD LVCMOS33 [get_ports  b_smbus_scl]
set_property IOSTANDARD LVCMOS33 [get_ports  b_smbus_sda]

# drive pin to UCD high to allow smbus access from host
#set_property PACKAGE_PIN AJ10 [get_ports o_ucd_gpio21]
#set_property IOSTANDARD LVCMOS33 [get_ports  o_ucd_gpio21]

#LEDs
set_property PACKAGE_PIN AE10 [get_ports {o_led_red[0]}]
set_property PACKAGE_PIN AK8 [get_ports {o_led_red[1]}]
set_property PACKAGE_PIN AK10 [get_ports {o_led_green[0]}]
set_property PACKAGE_PIN AJ8 [get_ports {o_led_green[1]}]
set_property PACKAGE_PIN AJ9 [get_ports {o_led_blue[0]}]
set_property PACKAGE_PIN AL9 [get_ports {o_led_blue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led_red[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led_green[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led_blue[*]}]
