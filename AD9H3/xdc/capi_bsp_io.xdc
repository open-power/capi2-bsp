############################################################################
############################################################################
##
## Copyright 2019 International Business Machines
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

#Alpha Data 9H3 I/O constraints

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
# package_pin for pcie lanes are specified by the location of the IP

#Flash Interface
set_property PACKAGE_PIN AW28 [get_ports {spi_miso_secondary}]
set_property PACKAGE_PIN AV28 [get_ports {spi_mosi_secondary}]
set_property PACKAGE_PIN AW24 [get_ports {spi_cen_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_miso_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_mosi_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_cen_secondary}]
