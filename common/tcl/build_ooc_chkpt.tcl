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

set root_dir         $::env(ROOT_DIR)
set common_dir       $::env(COMMON_DIR)
set common_tcl       $::env(COMMON_TCL)
set fpga_part        $::env(FPGA_PART)
set ooc_dir          $::env(CARD_BUILD_OOC)
set card_dir         $::env(CARD_DIR)
set ip_dir           $::env(CARD_IP)
set psl_ip_dir       $::env(PSL_IP)

set card_tcl         $::env(CARD_TCL)

###############################################################
###   Tcl Variables
###############################################################
#set tclParams [list <param1> <value> <param2> <value> ... <paramN> <value>]
set tclParams [list hd.visual 1 \
              ]

#Define location for "Tcl" directory. Defaults to "./Tcl"
set tclHome "$common_dir/ooc_flow_tcl"
if {[file exists $tclHome]} {
   set tclDir $tclHome
} elseif {[file exists "./Tcl"]} {
   set tclDir  "./Tcl"
} else {
   error "ERROR: No valid location found for required Tcl scripts. Set \$tclDir in design.tcl to a valid location."
}

###############################################################
### Define Part, Package, Speedgrade 
###############################################################
set part         $fpga_part
###############################################################
###  Setup Variables
###############################################################
### flow control
### for OOC bsp build: Just set oocSynth=1, oocImpl=1
set run.topSynth   0
set run.oocSynth   1
set run.tdImpl     0
set run.oocImpl    1
set run.topImpl    0
set run.flatImpl   0

####Report and DCP controls - values: 0-required min; 1-few extra; 2-all
set verbose      1
set dcpLevel     1

####Output Directories
set synthDir  "$ooc_dir/Synth"
set implDir   "$ooc_dir/Implement"
set dcpDir    "$ooc_dir/Checkpoint"

####Input Directories
set srcDir     "$card_dir/ooc_Sources"
#set pslDir     "$srcDir/psl"
#set topDir     "$srcDir/top"
#set afuDir     "$srcDir/afu0"
set prjDir     "$srcDir/prj"
set xdcDir     "$srcDir/xdc"
#set coreDir    "$srcDir/cores"

####Source required Tcl Procs
source $tclDir/design_utils.tcl
source $tclDir/synth_utils.tcl
source $tclDir/impl_utils.tcl
source $tclDir/hd_floorplan_utils.tcl

###############################################################
### Top Definition
### Note: this part was commented because we don't use this script
### to build top design. Top design will be built in snap.
###############################################################
#set top "psl_fpga"
#add_module $top
#set_attribute module $top    top_level     1
##set_attribute module $top    prj           $prjDir/$top.prj
#set_attribute module $top    synth         ${run.topSynth}
#set_attribute module $top    synth_options "-flatten_hierarchy rebuilt -fanout_limit 400 -fsm_extraction one_hot -keep_equivalent_registers -resource_sharing off -no_lc -shreg_min_size 5 -no_iobuf"
#
#add_implementation $top
#set_attribute impl $top      top           $top
##set_attribute impl $top      linkXDC       [list $xdcDir/b_xilinx_capi_pcie_gen3_alphadata_brd_topimp.xdc] 
#set_attribute impl $top      impl          ${run.topImpl}
#set_attribute impl $top      hd.impl       1
#set_attribute impl $top      opt_directive Explore
#set_attribute impl $top      place_directive Explore
#set_attribute impl $top      phys_directive Explore
#set_attribute impl $top      route_directive Explore
##TEMP: Workaround unexpected xilinx top level placement behavior
#set_attribute impl $top      place.pre     [list pre_place.tcl             \
#					   ]
#set_attribute impl $top      route.pre     [list pre_route.tcl                \
#                                           ]
#set_attribute impl $top      bitstream     1



####################################################################
### OOC Module Definition and OOC Implementation for each instance
####################################################################
set module1 "capi_bsp"
add_module $module1
set_attribute module $module1 prj          $prjDir/bsp.prj
set_attribute module $module1 synth        ${run.oocSynth}
set_attribute module $module1 synth_options "-flatten_hierarchy rebuilt -fanout_limit 400 -fsm_extraction one_hot -keep_equivalent_registers -resource_sharing off -no_lc -shreg_min_size 5"
set_attribute module $module1 ip           [list \
                                           $ip_dir/pcie4_uscale_plus_0/pcie4_uscale_plus_0.xci       \
                                           $ip_dir/sem_ultra_0/sem_ultra_0.xci   \
                                           $ip_dir/uscale_plus_clk_wiz/uscale_plus_clk_wiz.xci         \
                                           $psl_ip_dir/PSL9_WRAP_0/PSL9_WRAP_0.xci         \
                                           ]
set instance "c0"
add_ooc_implementation $instance
set_attribute ooc $instance   module       $module1
set_attribute ooc $instance   inst         $instance
set_attribute ooc $instance   hierInst     $instance
set_attribute ooc $instance   implXDC      [list $xdcDir/ooc_bsp_impl.xdc   \
                                                 $xdcDir/ooc_bsp_timing.xdc \
                                           ] 
set_attribute ooc $instance   impl         ${run.oocImpl}
set_attribute ooc $instance   preservation routing
set_attribute ooc $instance   opt_directive Explore
set_attribute ooc $instance   place_directive Explore
set_attribute ooc $instance   phys_directive Explore
set_attribute ooc $instance   route_directive Explore
set_attribute ooc $instance   opt.pre      [list $common_tcl/ooc_read_constraints.tcl             \
                                           ]
set_attribute ooc $instance   phys.pre     [list $common_tcl/ooc_rerun_phys_opt.tcl               \
                                           ]
set_attribute ooc $instance   route.pre    [list $common_tcl/ooc_pre_route.tcl                    \
                                           ]
#set_attribute ooc $instance   route.post   [list $common_tcl/ooc_post_route.tcl                  \
#                                           ]

# Create the listed IPs
source $common_tcl/create_ip.tcl
# Build the designs
source $tclDir/run.tcl

exit
