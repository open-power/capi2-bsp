create_pblock pblock_bsp
add_cells_to_pblock [get_pblocks pblock_bsp] -top
resize_pblock [get_pblocks pblock_bsp] -add {CLOCKREGION_X4Y5:CLOCKREGION_X5Y8}
# Add region for FRAME_ECCE4
resize_pblock [get_pblocks pblock_bsp] -add {CONFIG_SITE_X0Y2}
resize_pblock [get_pblocks pblock_bsp] -add {CONFIG_SITE_X0Y1}
resize_pblock [get_pblocks pblock_bsp] -add {CONFIG_SITE_X0Y0}


#remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells capi_bis/crc/FRAME_ECCE4_inst2]
#remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells capi_bis/crc/FRAME_ECCE4_inst1]
#remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells capi_bis/crc/FRAME_ECCE4_inst0]


##Global clocks need free reign
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells pcihip0/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk]
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells pcihip0/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk]
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells pcihip0/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_coreclk]
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells pcihip0/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_mcapclk]
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells pcihip0/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk]
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells pcihip0/inst/bufg_gt_sysclk]
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells pll0/inst/clkout1_buf]
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells pll0/inst/clkout3_buf]
#remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells *pcihip0/sys_clk_buf]
remove_cells_from_pblock [get_pblocks pblock_bsp] [get_cells refclk_ibuf]

set_property CONTAIN_ROUTING 1 [get_pblocks pblock_bsp]

#Hack VSEC address
set_property PF0_SECONDARY_PCIE_CAP_NEXTPTR 12'h400 [get_cells pcihip0/inst]
set_property PF0_PCIE_CAP_NEXTPTR 8'hb0 [get_cells pcihip0/inst]

#Place for ports
set_property HD.PARTITION true [current_design]
set_property HD.PARTPIN_RANGE {SLICE_X112Y300:SLICE_X118Y539} [get_ports {a0h* ha0* d0h* hd0* pci_user_reset gold* }]
#set_property HD.PARTPIN_RANGE {SLICE_X112Y300:SLICE_X116Y539} [get_ports {a0h_paren* a0h_tbreq* ha0_b* a0h_b* ha0_c* a0h_c* ha0_r* d0h* hd0* pci_user_reset}]
#set_property HD.PARTPIN_RANGE {SLICE_X117Y535:SLICE_X150Y539} [get_ports {a0h_mm* a0h_j* ha0_mm* ha0_j* gold* }]
