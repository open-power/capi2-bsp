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
#Reflex-Ces XpressVUP-LP9PT I/O constraints

###############################################################################
# IOs constraints
###############################################################################

set_property IOSTANDARD LVCMOS18 [get_ports fan_cde]
set_property DRIVE 12 [get_ports fan_cde]
set_property SLEW SLOW [get_ports fan_cde]
set_property PACKAGE_PIN AN21 [get_ports fan_cde]


## PCIE ########################################################################

## CLK #####################

set_property PACKAGE_PIN AP10 [get_ports {pcie_clkn}]
set_property PACKAGE_PIN AP11 [get_ports {pcie_clkp}]

## RST #####################

set_property PULLUP true [get_ports pcie_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rst_n]
set_property PACKAGE_PIN AR26 [get_ports {pcie_rst_n}]

## PCI LANES ###############
set_property PACKAGE_PIN BC2 [get_ports {pcie_rxp[15]}]
set_property PACKAGE_PIN BC1 [get_ports {pcie_rxn[15]}]
set_property PACKAGE_PIN BF5 [get_ports {pcie_txp[15]}]
set_property PACKAGE_PIN BF4 [get_ports {pcie_txn[15]}]
set_property PACKAGE_PIN BA2 [get_ports {pcie_rxp[14]}]
set_property PACKAGE_PIN BA1 [get_ports {pcie_rxn[14]}]
set_property PACKAGE_PIN BD5 [get_ports {pcie_txp[14]}]
set_property PACKAGE_PIN BD4 [get_ports {pcie_txn[14]}]
set_property PACKAGE_PIN AW4 [get_ports {pcie_rxp[13]}]
set_property PACKAGE_PIN AW3 [get_ports {pcie_rxn[13]}]
set_property PACKAGE_PIN BB5 [get_ports {pcie_txp[13]}]
set_property PACKAGE_PIN BB4 [get_ports {pcie_txn[13]}]
set_property PACKAGE_PIN AV2 [get_ports {pcie_rxp[12]}]
set_property PACKAGE_PIN AV1 [get_ports {pcie_rxn[12]}]
set_property PACKAGE_PIN AV7 [get_ports {pcie_txp[12]}]
set_property PACKAGE_PIN AV6 [get_ports {pcie_txn[12]}]
set_property PACKAGE_PIN AU4 [get_ports {pcie_rxp[11]}]
set_property PACKAGE_PIN AU3 [get_ports {pcie_rxn[11]}]
set_property PACKAGE_PIN AU9 [get_ports {pcie_txp[11]}]
set_property PACKAGE_PIN AU8 [get_ports {pcie_txn[11]}]
set_property PACKAGE_PIN AT2 [get_ports {pcie_rxp[10]}]
set_property PACKAGE_PIN AT1 [get_ports {pcie_rxn[10]}]
set_property PACKAGE_PIN AT7 [get_ports {pcie_txp[10]}]
set_property PACKAGE_PIN AT6 [get_ports {pcie_txn[10]}]
set_property PACKAGE_PIN AR9 [get_ports {pcie_txp[9]}]
set_property PACKAGE_PIN AR3 [get_ports {pcie_rxn[9]}]
set_property PACKAGE_PIN AR8 [get_ports {pcie_txn[9]}]
set_property PACKAGE_PIN AR4 [get_ports {pcie_rxp[9]}]
set_property PACKAGE_PIN AP2 [get_ports {pcie_rxp[8]}]
set_property PACKAGE_PIN AP1 [get_ports {pcie_rxn[8]}]
set_property PACKAGE_PIN AP7 [get_ports {pcie_txp[8]}]
set_property PACKAGE_PIN AP6 [get_ports {pcie_txn[8]}]
set_property PACKAGE_PIN AN4 [get_ports {pcie_rxp[7]}]
set_property PACKAGE_PIN AN3 [get_ports {pcie_rxn[7]}]
set_property PACKAGE_PIN AN9 [get_ports {pcie_txp[7]}]
set_property PACKAGE_PIN AN8 [get_ports {pcie_txn[7]}]
set_property PACKAGE_PIN AM2 [get_ports {pcie_rxp[6]}]
set_property PACKAGE_PIN AM1 [get_ports {pcie_rxn[6]}]
set_property PACKAGE_PIN AM7 [get_ports {pcie_txp[6]}]
set_property PACKAGE_PIN AM6 [get_ports {pcie_txn[6]}]
set_property PACKAGE_PIN AL4 [get_ports {pcie_rxp[5]}]
set_property PACKAGE_PIN AL3 [get_ports {pcie_rxn[5]}]
set_property PACKAGE_PIN AL9 [get_ports {pcie_txp[5]}]
set_property PACKAGE_PIN AL8 [get_ports {pcie_txn[5]}]
set_property PACKAGE_PIN AK2 [get_ports {pcie_rxp[4]}]
set_property PACKAGE_PIN AK1 [get_ports {pcie_rxn[4]}]
set_property PACKAGE_PIN AK7 [get_ports {pcie_txp[4]}]
set_property PACKAGE_PIN AK6 [get_ports {pcie_txn[4]}]
set_property PACKAGE_PIN AJ4 [get_ports {pcie_rxp[3]}]
set_property PACKAGE_PIN AJ3 [get_ports {pcie_rxn[3]}]
set_property PACKAGE_PIN AJ9 [get_ports {pcie_txp[3]}]
set_property PACKAGE_PIN AJ8 [get_ports {pcie_txn[3]}]
set_property PACKAGE_PIN AH2 [get_ports {pcie_rxp[2]}]
set_property PACKAGE_PIN AH1 [get_ports {pcie_rxn[2]}]
set_property PACKAGE_PIN AH7 [get_ports {pcie_txp[2]}]
set_property PACKAGE_PIN AH6 [get_ports {pcie_txn[2]}]
set_property PACKAGE_PIN AG4 [get_ports {pcie_rxp[1]}]
set_property PACKAGE_PIN AG3 [get_ports {pcie_rxn[1]}]
set_property PACKAGE_PIN AG9 [get_ports {pcie_txp[1]}]
set_property PACKAGE_PIN AG8 [get_ports {pcie_txn[1]}]
set_property PACKAGE_PIN AF2 [get_ports {pcie_rxp[0]}]
set_property PACKAGE_PIN AF1 [get_ports {pcie_rxn[0]}]
set_property PACKAGE_PIN AF7 [get_ports {pcie_txp[0]}]
set_property PACKAGE_PIN AF6 [get_ports {pcie_txn[0]}]

#Flash Interface
set_property PACKAGE_PIN AN26 [get_ports {spi_miso_secondary}]
set_property PACKAGE_PIN AM26 [get_ports {spi_mosi_secondary}]
set_property PACKAGE_PIN BF27 [get_ports {spi_cen_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_miso_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_mosi_secondary}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_cen_secondary}]


# Pushing properties early in the process :
set_property BITSTREAM.CONFIG.UNUSEDPIN {Pullnone} [current_design]

# removing external clock for Engineering sample, as it doesn't support it
# watch out that this property is not overridden in SNAP (hardware/setup/snap_bitstream_pre.tcl)
# set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DIV-1 [current_design]
# to check if it can fasten the flash loading ?
# set_property BITSTREAM.CONFIG.CONFIGRATE 36.4[current_design]
