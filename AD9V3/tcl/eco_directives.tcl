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

#Post-Build ECO directives for ad9v3 card
#set_property PF0_PCIE_CAP_NEXTPTR 8'hB0 [get_cells -hierarchical -filter {PRIMITIVE_SUBGROUP == PCIE}]
set_property PF0_SECONDARY_PCIE_CAP_NEXTPTR 12'h400 [get_cells -hierarchical -filter {PRIMITIVE_SUBGROUP == PCIE}]
#PCI PF0 SUBSYSTEM ID must be unique foe each card
#TODO: ad9v3 does not actually have one assigned, I just picked this (decimal) value for now:
#set_property PF0_SUBSYSTEM_ID 39030 [get_cells pcihip0/inst]
