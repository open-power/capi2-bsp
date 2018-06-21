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

#Alpha Data 9V3 I/O constraints

#PCIe
set_property IOSTANDARD LVCMOS18 [get_ports pci_pi_nperst0]
set_property PACKAGE_PIN AJ31 [get_ports pci_pi_nperst0]
set_property PULLUP true [get_ports *pci_pi_nperst0]

set_property PACKAGE_PIN AA6 [get_ports pci_pi_refclk_n0]
set_property PACKAGE_PIN AA7 [get_ports pci_pi_refclk_p0]

set_property PACKAGE_PIN H4 [get_ports pci0_o_txn_out0]
set_property PACKAGE_PIN K4 [get_ports pci0_o_txn_out1]
set_property PACKAGE_PIN M4 [get_ports pci0_o_txn_out2]
set_property PACKAGE_PIN P4 [get_ports pci0_o_txn_out3]
set_property PACKAGE_PIN T4 [get_ports pci0_o_txn_out4]
set_property PACKAGE_PIN V4 [get_ports pci0_o_txn_out5]
set_property PACKAGE_PIN AB4 [get_ports pci0_o_txn_out6]
set_property PACKAGE_PIN AD4 [get_ports pci0_o_txn_out7]

#Flash Interface
set_property PACKAGE_PIN AG30 [get_ports {spi_miso_secondary}]
set_property PACKAGE_PIN AF30 [get_ports {spi_mosi_secondary}]
set_property PACKAGE_PIN AV30 [get_ports {spi_cen_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_miso_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_mosi_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_cen_secondary}]

