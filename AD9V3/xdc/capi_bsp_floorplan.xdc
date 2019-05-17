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

#Alpha Data 9V3 floorplan constraints

#create_pblock pci
#add_cells_to_pblock [get_pblocks pci] [get_cells -quiet [list pcihip0 hdk_inst]]
#resize_pblock  [get_pblocks pci] -add {CLOCKREGION_X5Y0:CLOCKREGION_X5Y3}
create_pblock capi_bsp
resize_pblock capi_bsp -add CLOCKREGION_X3Y0:CLOCKREGION_X5Y2
add_cells_to_pblock capi_bsp [get_cells [list c0/U0/p]]
