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

## PCIe #########################################################

## RST ###########################
set_property IOSTANDARD LVCMOS18 [get_ports pci_pi_nperst0]
set_property PACKAGE_PIN AJ31 [get_ports pci_pi_nperst0]
set_property PULLUP true [get_ports *pci_pi_nperst0]

## CLK ###########################
set_property PACKAGE_PIN AA6 [get_ports pci_pi_refclk_n0]
set_property PACKAGE_PIN AA7 [get_ports pci_pi_refclk_p0]
#set_property PACKAGE_PIN AJ6 [get_ports pci_pi_refclk_n1]
#set_property PACKAGE_PIN AJ7 [get_ports pci_pi_refclk_p1]

## PCIE LANES ####################
#set_property PACKAGE_PIN H4 [get_ports pci0_o_txn_out0]
#set_property PACKAGE_PIN K4 [get_ports pci0_o_txn_out1]
#set_property PACKAGE_PIN M4 [get_ports pci0_o_txn_out2]
#set_property PACKAGE_PIN P4 [get_ports pci0_o_txn_out3]
#set_property PACKAGE_PIN T4 [get_ports pci0_o_txn_out4]
#set_property PACKAGE_PIN V4 [get_ports pci0_o_txn_out5]
#set_property PACKAGE_PIN AB4 [get_ports pci0_o_txn_out6]
#set_property PACKAGE_PIN AD4 [get_ports pci0_o_txn_out7]

set_property PACKAGE_PIN AV4 [get_ports {pcie_rxp[15]}]
set_property PACKAGE_PIN AV3 [get_ports {pcie_rxn[15]}]
set_property PACKAGE_PIN AW7 [get_ports {pcie_txp[15]}]
set_property PACKAGE_PIN AW6 [get_ports {pcie_txn[15]}]
set_property PACKAGE_PIN AU2 [get_ports {pcie_rxp[14]}]
set_property PACKAGE_PIN AU1 [get_ports {pcie_rxn[14]}]
set_property PACKAGE_PIN AU7 [get_ports {pcie_txp[14]}]
set_property PACKAGE_PIN AU6 [get_ports {pcie_txn[14]}]
set_property PACKAGE_PIN AR2 [get_ports {pcie_rxp[13]}]
set_property PACKAGE_PIN AR1 [get_ports {pcie_rxn[13]}]
set_property PACKAGE_PIN AT5 [get_ports {pcie_txp[13]}]
set_property PACKAGE_PIN AT4 [get_ports {pcie_txn[13]}]
set_property PACKAGE_PIN AN2 [get_ports {pcie_rxp[12]}]
set_property PACKAGE_PIN AN1 [get_ports {pcie_rxn[12]}]
set_property PACKAGE_PIN AP5 [get_ports {pcie_txp[12]}]
set_property PACKAGE_PIN AP4 [get_ports {pcie_txn[12]}]
set_property PACKAGE_PIN AL2 [get_ports {pcie_rxp[11]}]
set_property PACKAGE_PIN AL1 [get_ports {pcie_rxn[11]}]
set_property PACKAGE_PIN AM5 [get_ports {pcie_txp[11]}]
set_property PACKAGE_PIN AM4 [get_ports {pcie_txn[11]}]
set_property PACKAGE_PIN AJ2 [get_ports {pcie_rxp[10]}]
set_property PACKAGE_PIN AJ1 [get_ports {pcie_rxn[10]}]
set_property PACKAGE_PIN AK5 [get_ports {pcie_txp[10]}]
set_property PACKAGE_PIN AK4 [get_ports {pcie_txn[10]}]
set_property PACKAGE_PIN AG2 [get_ports {pcie_txp[9]}]
set_property PACKAGE_PIN AG1 [get_ports {pcie_rxn[9]}]
set_property PACKAGE_PIN AH4 [get_ports {pcie_txn[9]}]
set_property PACKAGE_PIN AH5 [get_ports {pcie_rxp[9]}]
set_property PACKAGE_PIN AE2 [get_ports {pcie_rxp[8]}]
set_property PACKAGE_PIN AE1 [get_ports {pcie_rxn[8]}]
set_property PACKAGE_PIN AF5 [get_ports {pcie_txp[8]}]
set_property PACKAGE_PIN AF4 [get_ports {pcie_txn[8]}]
set_property PACKAGE_PIN AC2 [get_ports {pcie_rxp[7]}]
set_property PACKAGE_PIN AC1 [get_ports {pcie_rxn[7]}]
set_property PACKAGE_PIN AD5 [get_ports {pcie_txp[7]}]
set_property PACKAGE_PIN AD4 [get_ports {pcie_txn[7]}]
set_property PACKAGE_PIN AA2 [get_ports {pcie_rxp[6]}]
set_property PACKAGE_PIN AA1 [get_ports {pcie_rxn[6]}]
set_property PACKAGE_PIN AB5 [get_ports {pcie_txp[6]}]
set_property PACKAGE_PIN AB4 [get_ports {pcie_txn[6]}]
set_property PACKAGE_PIN W2 [get_ports {pcie_rxp[5]}]
set_property PACKAGE_PIN W1 [get_ports {pcie_rxn[5]}]
set_property PACKAGE_PIN V5 [get_ports {pcie_txp[5]}]
set_property PACKAGE_PIN V4 [get_ports {pcie_txn[5]}]
set_property PACKAGE_PIN U2 [get_ports {pcie_rxp[4]}]
set_property PACKAGE_PIN U1 [get_ports {pcie_rxn[4]}]
set_property PACKAGE_PIN T5 [get_ports {pcie_txp[4]}]
set_property PACKAGE_PIN T4 [get_ports {pcie_txn[4]}]
set_property PACKAGE_PIN R2 [get_ports {pcie_rxp[3]}]
set_property PACKAGE_PIN R1 [get_ports {pcie_rxn[3]}]
set_property PACKAGE_PIN P5 [get_ports {pcie_txp[3]}]
set_property PACKAGE_PIN P4 [get_ports {pcie_txn[3]}]
set_property PACKAGE_PIN N2 [get_ports {pcie_rxp[2]}]
set_property PACKAGE_PIN N1 [get_ports {pcie_rxn[2]}]
set_property PACKAGE_PIN M5 [get_ports {pcie_txp[2]}]
set_property PACKAGE_PIN M4 [get_ports {pcie_txn[2]}]
set_property PACKAGE_PIN L2 [get_ports {pcie_rxp[1]}]
set_property PACKAGE_PIN L1 [get_ports {pcie_rxn[1]}]
set_property PACKAGE_PIN K5 [get_ports {pcie_txp[1]}]
set_property PACKAGE_PIN K4 [get_ports {pcie_txn[1]}]
set_property PACKAGE_PIN J2 [get_ports {pcie_rxp[0]}]
set_property PACKAGE_PIN J1 [get_ports {pcie_rxn[0]}]
set_property PACKAGE_PIN H5 [get_ports {pcie_txp[0]}]
set_property PACKAGE_PIN H4 [get_ports {pcie_txn[0]}]


#Flash Interface
set_property PACKAGE_PIN AG30 [get_ports {spi_miso_secondary}]
set_property PACKAGE_PIN AF30 [get_ports {spi_mosi_secondary}]
set_property PACKAGE_PIN AV30 [get_ports {spi_cen_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_miso_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_mosi_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_cen_secondary}]

#set_property PACKAGE_PIN AJ28 [get_ports {refclk100M}]
#set_property PACKAGE_PIN AE8 [get_ports {fpga_flash_ce1_l}]
#set_property PACKAGE_PIN AV30 [get_ports {fpga_flash_ce2_l}]
#set_property PACKAGE_PIN AB8 [get_ports {fpga_flash_dq0}]
#set_property PACKAGE_PIN AD8 [get_ports {fpga_flash_dq1}]
#set_property PACKAGE_PIN Y8  [get_ports {fpga_flash_dq2}]
#set_property PACKAGE_PIN AC8 [get_ports {fpga_flash_dq3}]
#set_property PACKAGE_PIN AF30 [get_ports {fpga_flash_dq4}]
#set_property PACKAGE_PIN AG30 [get_ports {fpga_flash_dq5}]
#set_property PACKAGE_PIN AF28 [get_ports {fpga_flash_dq6}]
#set_property PACKAGE_PIN AG28 [get_ports {fpga_flash_dq7}]
