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

# Flyslice FX609 has changed following:
# Max LINK SPEED: 8GT/s
# Max LINK WIDTH: X16
# SUBSYSTEM_ID: 0x0661
# PCIE_ID_IF = flase
# PCIE BANK 227/226/225/224 (SLR1 X1Y2)

# Create PCIe4 IP
create_ip -name pcie4_uscale_plus -vendor xilinx.com -library ip -module_name pcie4_uscale_plus_0 -dir $ip_dir >> $log_file
set_property -dict [list                                               \
                    CONFIG.enable_gen4 {false}                         \
                    CONFIG.gen4_eieos_0s7 {true}                       \
                    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s}       \
                    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X16}            \
                    CONFIG.AXISTEN_IF_EXT_512_CQ_STRADDLE {true}       \
                    CONFIG.AXISTEN_IF_EXT_512_RC_4TLP_STRADDLE {false} \
                    CONFIG.axisten_if_enable_client_tag {true}         \
                    CONFIG.PF0_CLASS_CODE {1200ff}                     \
                    CONFIG.PF0_DEVICE_ID {0477}                        \
                    CONFIG.PF0_REVISION_ID {02}                        \
                    CONFIG.PF0_SUBSYSTEM_ID {0660}                     \
                    CONFIG.PF0_SUBSYSTEM_VENDOR_ID {1014}              \
                    CONFIG.PCIE_ID_IF {false}                          \
                    CONFIG.ins_loss_profile {Add-in_card}              \
                    CONFIG.PHY_LP_TXPRESET {4}                         \
                    CONFIG.pf0_bar0_64bit {true}                       \
                    CONFIG.pf0_bar0_prefetchable {true}                \
                    CONFIG.pf0_bar0_scale {Megabytes}                  \
                    CONFIG.pf0_bar0_size {256}                         \
                    CONFIG.pf0_bar2_enabled {true}                     \
                    CONFIG.pf0_bar2_64bit {true}                       \
                    CONFIG.pf0_bar2_prefetchable {true}                \
                    CONFIG.pf0_bar4_enabled {true}                     \
                    CONFIG.pf0_bar4_64bit {true}                       \
                    CONFIG.pf0_bar4_prefetchable {true}                \
                    CONFIG.pf0_bar4_scale {Gigabytes}                  \
                    CONFIG.pf0_bar4_size {256}                         \
                    CONFIG.pf0_dev_cap_max_payload {512_bytes}         \
                    CONFIG.vendor_id {1014}                            \
                    CONFIG.ext_pcie_cfg_space_enabled {true}           \
                    CONFIG.legacy_ext_pcie_cfg_space_enabled {true}    \
                    CONFIG.mode_selection {Advanced}                   \
                    CONFIG.en_gt_selection {true}                      \
                    CONFIG.pcie_blk_locn {X1Y2}                        \
                    CONFIG.gen_x0y1 {false}                            \
                    CONFIG.gen_x1y2 {true}                             \
                    CONFIG.select_quad {GTY_Quad_227}                  \
                    CONFIG.AXISTEN_IF_EXT_512_RQ_STRADDLE {true}       \
                    CONFIG.PF0_MSIX_CAP_PBA_BIR {BAR_1:0}              \
                    CONFIG.PF0_MSIX_CAP_TABLE_BIR {BAR_1:0}            \
                    CONFIG.PF2_DEVICE_ID {9048}                        \
                    CONFIG.PF3_DEVICE_ID {9048}                        \
                    CONFIG.pf2_bar2_enabled {true}                     \
                    CONFIG.pf3_bar2_enabled {true}                     \
                    CONFIG.pf1_bar2_enabled {true}                     \
                    CONFIG.pf1_bar2_type {Memory}                      \
                    CONFIG.pf1_bar4_type {Memory}                      \
                    CONFIG.pf2_bar2_type {Memory}                      \
                    CONFIG.pf2_bar4_type {Memory}                      \
                    CONFIG.pf3_bar2_type {Memory}                      \
                    CONFIG.pf3_bar4_type {Memory}                      \
                    CONFIG.pf0_bar2_type {Memory}                      \
                    CONFIG.pf0_bar4_type {Memory}                      \
                    CONFIG.pf1_bar4_enabled {true}                     \
                    CONFIG.pf1_bar4_scale {Gigabytes}                  \
                    CONFIG.pf1_vendor_id {1014}                        \
                    CONFIG.pf2_vendor_id {1014}                        \
                    CONFIG.pf3_vendor_id {1014}                        \
                    CONFIG.pf1_bar0_scale {Megabytes}                  \
                    CONFIG.pf1_bar0_size {256}                         \
                    CONFIG.axisten_if_width {512_bit}                  \
                    CONFIG.pf1_bar4_size {256}                         \
                    CONFIG.pf2_bar4_enabled {true}                     \
                    CONFIG.pf2_bar4_scale {Gigabytes}                  \
                    CONFIG.pf2_bar0_scale {Megabytes}                  \
                    CONFIG.pf2_bar0_size {256}                         \
                    CONFIG.pf2_bar4_size {256}                         \
                    CONFIG.pf3_bar4_enabled {true}                     \
                    CONFIG.pf3_bar4_scale {Gigabytes}                  \
                    CONFIG.pf3_bar0_scale {Megabytes}                  \
                    CONFIG.pf3_bar0_size {256}                         \
                    CONFIG.pf3_bar4_size {256}                         \
                    CONFIG.coreclk_freq {500}                          \
                    CONFIG.plltype {QPLL0}                             \
                    CONFIG.axisten_freq {250}                          \
                   ] [get_ips pcie4_uscale_plus_0] >> $log_file


#Create 250MHz Clock IP
create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name uscale_plus_clk_wiz -dir  $ip_dir >> $log_file

#set_property -dict [list CONFIG.CLKIN1_JITTER_PS {40.0} \
#CONFIG.CLKOUT1_DRIVES {BUFG} \
#CONFIG.CLKOUT1_JITTER {85.736} \
#CONFIG.CLKOUT1_PHASE_ERROR {79.008} \
#CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {250} \
#CONFIG.CLKOUT2_DRIVES {BUFG} \
#CONFIG.CLKOUT2_JITTER {98.122} \
#CONFIG.CLKOUT2_PHASE_ERROR {79.008} \
#CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
#CONFIG.CLKOUT2_USED {true} \
#CONFIG.CLKOUT3_DRIVES {BUFGCE} \
#CONFIG.CLKOUT3_JITTER {98.122} \
#CONFIG.CLKOUT3_PHASE_ERROR {79.008} \
#CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {125} \
#CONFIG.CLKOUT3_USED {true} \
#CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
#CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
#CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
#CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
#CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000} \
#CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
#CONFIG.MMCM_CLKOUT2_DIVIDE {10} \
#CONFIG.MMCM_DIVCLK_DIVIDE {1} \
#CONFIG.NUM_OUT_CLKS {2} \
#CONFIG.NUM_OUT_CLKS {3} \
#CONFIG.PRIM_IN_FREQ {250}] [get_ips uscale_plus_clk_wiz]

#Increase psl clock period by 10% to ease timing
set_property -dict [list                                        \
                    CONFIG.CLKIN1_JITTER_PS {40.0}              \
                    CONFIG.CLKOUT1_DRIVES {BUFG}                \
                    CONFIG.CLKOUT1_JITTER {88.305}              \
                    CONFIG.CLKOUT1_PHASE_ERROR {80.553}         \
                    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {225.000} \
                    CONFIG.CLKOUT2_DRIVES {BUFG}                \
                    CONFIG.CLKOUT2_JITTER {99.067}              \
                    CONFIG.CLKOUT2_PHASE_ERROR {80.553}         \
                    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.000} \
                    CONFIG.CLKOUT2_USED {true}                  \
                    CONFIG.CLKOUT3_DRIVES {BUFGCE}              \
                    CONFIG.CLKOUT3_JITTER {99.067}              \
                    CONFIG.CLKOUT3_PHASE_ERROR {80.553}         \
                    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {125.000} \
                    CONFIG.CLKOUT3_USED {true}                  \
                    CONFIG.FEEDBACK_SOURCE {FDBK_AUTO}          \
                    CONFIG.MMCM_CLKFBOUT_MULT_F {4.500}         \
                    CONFIG.MMCM_CLKIN1_PERIOD {4.000}           \
                    CONFIG.MMCM_CLKIN2_PERIOD {14.999}          \
                    CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000}        \
                    CONFIG.MMCM_CLKOUT1_DIVIDE {9}              \
                    CONFIG.MMCM_CLKOUT2_DIVIDE {9}              \
                    CONFIG.MMCM_DIVCLK_DIVIDE {1}               \
                    CONFIG.NUM_OUT_CLKS {3}                     \
                    CONFIG.PRIM_IN_FREQ {250.000}               \
                    CONFIG.USE_INCLK_SWITCHOVER {false}         \
                   ] [get_ips uscale_plus_clk_wiz] >> $log_file

# Create UltraScale Soft Error Mitigation IP
create_ip -name sem_ultra -vendor xilinx.com -library ip -module_name sem_ultra_0 -dir $ip_dir >> $log_file
set_property -dict [list                       \
                    CONFIG.MODE {detect_only}  \
                    CONFIG.CLOCK_PERIOD {8000} \
                   ] [get_ips sem_ultra_0] >> $log_file

set_property generate_synth_checkpoint false [get_files pcie4_uscale_plus_0.xci] >> $log_file
set_property generate_synth_checkpoint false [get_files uscale_plus_clk_wiz.xci] >> $log_file
set_property generate_synth_checkpoint false [get_files sem_ultra_0.xci] >> $log_file
