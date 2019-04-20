


#May have to use more strict delay values in the future, especially for delays marked as 2.5 by default
set memory_elements [all_registers]
set memory_elements [get_cells -hierarchical -filter {((PRIMITIVE_GROUP == BLOCKRAM) || (PRIMITIVE_GROUP == REGISTER) || (PRIMITIVE_SUBGROUP == LUTRAM)) && (IS_SEQUENTIAL == 1)}]
############ a0h ################
set_max_delay -from [get_ports {a0h_mm*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {a0h_c*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {a0h_j*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {a0h_paren*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {a0h_tbreq*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {d0h_dvalid*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {a0h_br*}] -to $memory_elements -datapath_only 2.0

############ d0h ################
set_max_delay -from [get_ports {d0h_req*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {d0h_dtype*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {d0h_datomic*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {d0h_dsize*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from [get_ports {d0h_ddata*}] -to $memory_elements -datapath_only 2.0

############ ha0 ################
set_max_delay -from $memory_elements -to [get_ports {ha0_r*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {ha0_bw*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {ha0_mm*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {ha0_j*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {ha0_c*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {ha0_br*}] -datapath_only 1.9

############ hd0 ################
set_max_delay -from $memory_elements -to [get_ports {hd0_sent*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {hd0_cpl_valid*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {hd0_cpl_utag*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {hd0_cpl_type*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {hd0_cpl_laddr*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {hd0_cpl_byte_count*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {hd0_cpl_size*}] -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {hd0_cpl_data*}] -datapath_only 2.0



set_max_delay -from [get_ports {gold*}] -to $memory_elements -datapath_only 2.0
set_max_delay -from $memory_elements -to [get_ports {pci_user_reset}] -datapath_only 2.0

