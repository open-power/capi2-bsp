-- *!***************************************************************************
-- *! Copyright 2014-2018 International Business Machines
-- *!
-- *! Licensed under the Apache License, Version 2.0 (the "License");
-- *! you may not use this file except in compliance with the License.
-- *! You may obtain a copy of the License at
-- *!
-- *!     http://www.apache.org/licenses/LICENSE-2.0
-- *!
-- *! Unless required by applicable law or agreed to in writing, software
-- *! distributed under the License is distributed on an "AS IS" BASIS,
-- *! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- *! See the License for the specific language governing permissions and
-- *! limitations under the License.
-- *!
-- *!***************************************************************************

library ieee;
use ieee.std_logic_1164.all;

-- CAPI board support
ENTITY capi_bsp IS
  PORT(
    --spi_miso_secondary    : in    std_logic;
    --spi_mosi_secondary    : out   std_logic;
    --spi_cen_secondary     : out   std_logic;

-- pci interface
    pcie_rst_n            : in    std_logic                     ;                                       -- Active low reset from the PCIe reset pin of the device
    pcie_clkp      	  : in    std_logic                     ;                                       -- 100MHz Refclk
    pcie_clkn             : in    std_logic                     ;                                       -- 100MHz Refclk

-- Xilinx requires both pins of differential transceivers
    pcie_txp              : out std_logic_vector(15 downto 0)   ;
    pcie_txn              : out std_logic_vector(15 downto 0)   ;
    pcie_rxp              : in  std_logic_vector(15 downto 0)   ;
    pcie_rxn              : in  std_logic_vector(15 downto 0)   ;

-- AFU interface (psl_accel)
    -- Command interface
    a0h_cvalid            : in    std_logic                  ; -- Command valid
    a0h_ctag              : in    std_logic_vector(0 to 7)   ; -- Command tag
    a0h_ctagpar           : in    std_logic                  ; -- Command tag parity
    a0h_com               : in    std_logic_vector(0 to 12)  ; -- Command code
    a0h_compar            : in    std_logic                  ; -- Command code parity
    a0h_cabt              : in    std_logic_vector(0 to 2)   ; -- Command ABT
    a0h_cea               : in    std_logic_vector(0 to 63)  ; -- Command address
    a0h_ceapar            : in    std_logic                  ; -- Command address parity
    a0h_cch               : in    std_logic_vector(0 to 15)  ; -- Command context handle
    a0h_csize             : in    std_logic_vector(0 to 11)  ; -- Command size
    a0h_cpagesize         : in    std_logic_vector(0 to 3)   ; -- ** New tie to 0000
    ha0_croom             : out   std_logic_vector(0 to 7)   ; -- Command room
    -- Buffer interface
    ha0_brvalid           : out   std_logic                  ; -- Buffer Read valid
    ha0_brtag             : out   std_logic_vector(0 to 7)   ; -- Buffer Read tag
    ha0_brtagpar          : out   std_logic                  ; -- Buffer Read tag parity
    ha0_brad              : out   std_logic_vector(0 to 5)   ; -- Buffer Read address
    a0h_brlat             : in    std_logic_vector(0 to 3)   ; -- Buffer Read latency
    a0h_brdata            : in    std_logic_vector(0 to 1023); -- Buffer Read data
    a0h_brpar             : in    std_logic_vector(0 to 15)  ; -- Buffer Read data parity
    ha0_bwvalid           : out   std_logic                  ; -- Buffer Write valid
    ha0_bwtag             : out   std_logic_vector(0 to 7)   ; -- Buffer Write tag
    ha0_bwtagpar          : out   std_logic                  ; -- Buffer Write tag parity
    ha0_bwad              : out   std_logic_vector(0 to 5)   ; -- Buffer Write address
    ha0_bwdata            : out   std_logic_vector(0 to 1023); -- Buffer Write data
    ha0_bwpar             : out   std_logic_vector(0 to 15)  ; -- Buffer Write data parity
    -- Response interface
    ha0_rvalid            : out   std_logic                  ; -- Response valid
    ha0_rtag              : out   std_logic_vector(0 to 7)   ; -- Response tag
    ha0_rtagpar           : out   std_logic                  ; -- Response tag parity
    ha0_rditag            : out   std_logic_vector(0 to 8)   ; -- **New DMA Translation Tag for xlat_* requests
    ha0_rditagpar         : out   std_logic                  ; -- **New Parity bit for above
    ha0_response          : out   std_logic_vector(0 to 7)   ; -- Response
    ha0_response_ext      : out   std_logic_vector(0 to 7)   ; -- **New Response Ext
    ha0_rpagesize         : out   std_logic_vector(0 to 3)   ; -- **New Command translated Page size.  Provided by PSL to allow
    ha0_rcachestate       : out   std_logic_vector(0 to 1)   ; -- Response cache state
    ha0_rcachepos         : out   std_logic_vector(0 to 12)  ; -- Response cache pos
    ha0_rcredits          : out   std_logic_vector(0 to 8)   ; -- Response credits
--     ha0_reoa              : out   std_logic_vector(0 to 185);  -- **New unknown width or use
    -- MMIO interface
    ha0_mmval             : out   std_logic                  ; -- A valid MMIO is present
    ha0_mmcfg             : out   std_logic                  ; -- afu descriptor space access
    ha0_mmrnw             : out   std_logic                  ; -- 1 = read, 0 = write
    ha0_mmdw              : out   std_logic                  ; -- 1 = doubleword, 0 = word
    ha0_mmad              : out   std_logic_vector(0 to 23)  ; -- mmio address
    ha0_mmadpar           : out   std_logic                  ; -- mmio address parity
    ha0_mmdata            : out   std_logic_vector(0 to 63)  ; -- Write data
    ha0_mmdatapar         : out   std_logic                  ; -- mmio data parity
    a0h_mmack             : in    std_logic                  ; -- Write is complete or Read is valid
    a0h_mmdata            : in    std_logic_vector(0 to 63)  ; -- Read data
    a0h_mmdatapar         : in    std_logic                  ; -- mmio data parity
    -- Control interface
    ha0_jval              : out   std_logic                  ; -- Job valid
    ha0_jcom              : out   std_logic_vector(0 to 7)   ; -- Job command
    ha0_jcompar           : out   std_logic                  ; -- Job command parity
    ha0_jea               : out   std_logic_vector(0 to 63)  ; -- Job address
    ha0_jeapar            : out   std_logic                  ; -- Job address parity
--  ha0_lop               : out   std_logic_vector(0 to 4)   ; -- LPC/Internal Cache Op code
--  ha0_loppar            : out   std_logic                  ; -- Job address parity
--  ha0_lsize             : out   std_logic_vector(0 to 6)   ; -- Size/Secondary Op code
--  ha0_ltag              : out   std_logic_vector(0 to 11)  ; -- LPC Tag/Internal Cache Tag
--  ha0_ltagpar           : out   std_logic                  ; -- LPC Tag/Internal Cache Tag parity
    a0h_jrunning          : in    std_logic                  ; -- Job running
    a0h_jdone             : in    std_logic                  ; -- Job done
    a0h_jcack             : in    std_logic                  ; -- completion of llcmd
    a0h_jerror            : in    std_logic_vector(0 to 63)  ; -- Job error
-- AM. Sept08, 2016                  a0h_jyield          : inx std_logic                  ; -- Job yield
--  a0h_ldone             : in    std_logic                  ; -- LPC/Internal Cache Op done
--  a0h_ldtag             : in    std_logic_vector(0 to 11)  ; -- ltag is done
--  a0h_ldtagpar          : in    std_logic                  ; -- ldtag parity
--  a0h_lroom             : in    std_logic_vector(0 to 7)   ; -- LPC/Internal Cache Op AFU can handle
    a0h_tbreq             : in    std_logic                  ; -- Timebase command request
    a0h_paren             : in    std_logic                  ; -- parity enable
    ha0_pclock            : out   std_logic                  ;

-- New DMA Interface
    -- Port 0
    -- DMA port 0 Request interface
    d0h_dvalid            : in    std_logic                  ; -- New PSL/AFU interface
    d0h_req_utag          : in    std_logic_vector(0 to 9)   ; -- New PSL/AFU interface
    d0h_req_itag          : in    std_logic_vector(0 to 8)   ; -- New PSL/AFU interface
    d0h_dtype             : in    std_logic_vector(0 to 2)   ; -- New PSL/AFU interface
    d0h_datomic_op        : in    std_logic_vector(0 to 5)   ; -- New PSL/AFU interface
    d0h_datomic_le        : in    std_logic                  ; -- New PSL/AFU interface
    d0h_dsize             : in    std_logic_vector(0 to 9)   ; -- New PSL/AFU interface
    d0h_ddata             : in    std_logic_vector(0 to 1023); -- New PSL/AFU interface
--    d0h_dpar              : in    std_logic_vector(0 to 15)  ; -- New PSL/AFU interface
    -- DMA port 0 Sent interface
    hd0_sent_utag_valid   : out   std_logic                  ;
    hd0_sent_utag         : out   std_logic_vector(0 to 9)   ;
    hd0_sent_utag_sts     : out   std_logic_vector(0 to 2)   ;
    -- DMA port 0 Completion interface
    hd0_cpl_valid         : out   std_logic                  ;
    hd0_cpl_utag          : out   std_logic_vector(0 to 9)   ;
    hd0_cpl_type          : out   std_logic_vector(0 to 2)   ;
    hd0_cpl_laddr         : out   std_logic_vector(0 to 6)   ;
    hd0_cpl_byte_count    : out   std_logic_vector(0 to 9)   ;
    hd0_cpl_size          : out   std_logic_vector(0 to 9)   ;
    hd0_cpl_data          : out   std_logic_vector(0 to 1023);
--    hd0_cpl_dpar          : out   std_logic_vector(0 to 15);

    gold_factory          : in    std_logic;

    pci_user_reset        : out   std_logic;  --PCI hip user_reset signal if required
    pci_clock_125MHz      : out   std_logic   --125MHz clock if required
);

END capi_bsp;

ARCHITECTURE capi_bsp OF capi_bsp IS


-- OBUF: Output Buffer
-- UltraScale
-- Xilinx HDL Libraries Guide, version 2015.4
Component OBUF
    PORT (O : out std_logic;
          I : in std_logic);
End Component OBUF;

-- Component pcie4_uscale_plus_0
Component pcie4_uscale_plus_0
  PORT(
    pci_exp_txn : out STD_LOGIC_VECTOR (15 downto 0);
    pci_exp_txp : out STD_LOGIC_VECTOR (15 downto 0);
    pci_exp_rxn : in STD_LOGIC_VECTOR (15 downto 0);
    pci_exp_rxp : in STD_LOGIC_VECTOR (15 downto 0);
    user_clk : out STD_LOGIC;
    user_reset : out STD_LOGIC;
    user_lnk_up : out STD_LOGIC;
    s_axis_rq_tdata : in STD_LOGIC_VECTOR ( 511 downto 0 );
    s_axis_rq_tkeep : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_rq_tlast : in STD_LOGIC;
    s_axis_rq_tready : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_rq_tuser : in STD_LOGIC_VECTOR ( 136 downto 0 );
    s_axis_rq_tvalid : in STD_LOGIC;
    m_axis_rc_tdata : out STD_LOGIC_VECTOR ( 511 downto 0 );
    m_axis_rc_tkeep : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_rc_tlast : out STD_LOGIC;
    m_axis_rc_tready : in STD_LOGIC_VECTOR ( 0 downto 0 );
    m_axis_rc_tuser : out STD_LOGIC_VECTOR ( 160 downto 0 );
    m_axis_rc_tvalid : out STD_LOGIC;
    m_axis_cq_tdata : out STD_LOGIC_VECTOR ( 511 downto 0 );
    m_axis_cq_tkeep : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_cq_tlast : out STD_LOGIC;
    m_axis_cq_tready : in STD_LOGIC_VECTOR ( 0 downto 0 );
    m_axis_cq_tuser : out STD_LOGIC_VECTOR ( 182 downto 0 );
    m_axis_cq_tvalid : out STD_LOGIC;
    s_axis_cc_tdata : in STD_LOGIC_VECTOR ( 511 downto 0 );
    s_axis_cc_tkeep : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_cc_tlast : in STD_LOGIC;
    s_axis_cc_tready : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_cc_tuser : in STD_LOGIC_VECTOR ( 80 downto 0 );
    s_axis_cc_tvalid : in STD_LOGIC;
    pcie_rq_seq_num0 : out STD_LOGIC_VECTOR ( 5 downto 0 );
    pcie_rq_seq_num_vld0 : out STD_LOGIC;
    pcie_rq_seq_num1 : out STD_LOGIC_VECTOR ( 5 downto 0 );
    pcie_rq_seq_num_vld1 : out STD_LOGIC;
    pcie_rq_tag0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_rq_tag1 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_rq_tag_av : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pcie_rq_tag_vld0 : out STD_LOGIC;
    pcie_rq_tag_vld1 : out STD_LOGIC;
    pcie_tfc_nph_av : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pcie_tfc_npd_av : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pcie_cq_np_req : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pcie_cq_np_req_count : out STD_LOGIC_VECTOR ( 5 downto 0 );
    cfg_phy_link_down : out STD_LOGIC;
    cfg_phy_link_status : out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_negotiated_width : out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_current_speed : out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_max_payload : out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_max_read_req : out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_function_status : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_function_power_state : out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_vf_status : out STD_LOGIC_VECTOR ( 503 downto 0 );
    cfg_vf_power_state : out STD_LOGIC_VECTOR ( 755 downto 0 );
    cfg_link_power_state : out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_mgmt_addr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    cfg_mgmt_function_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_mgmt_write : in STD_LOGIC;
    cfg_mgmt_write_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_mgmt_byte_enable : in STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_mgmt_read : in STD_LOGIC;
    cfg_mgmt_read_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_mgmt_read_write_done : out STD_LOGIC;
    cfg_mgmt_debug_access : in STD_LOGIC;
    cfg_err_cor_out : out STD_LOGIC;
    cfg_err_nonfatal_out : out STD_LOGIC;
    cfg_err_fatal_out : out STD_LOGIC;
    cfg_local_error_valid : out STD_LOGIC;
--    cfg_ltr_enable : out STD_LOGIC;
    cfg_local_error_out : out STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_ltssm_state : out STD_LOGIC_VECTOR ( 5 downto 0 );
    cfg_rx_pm_state : out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_tx_pm_state : out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_rcb_status : out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_obff_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_pl_status_change : out STD_LOGIC;
    cfg_tph_requester_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_tph_st_mode : out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_vf_tph_requester_enable : out STD_LOGIC_VECTOR ( 251 downto 0 );
    cfg_vf_tph_st_mode : out STD_LOGIC_VECTOR ( 755 downto 0 );
    cfg_msg_received : out STD_LOGIC;
    cfg_msg_received_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_msg_received_type : out STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_msg_transmit : in STD_LOGIC;
    cfg_msg_transmit_type : in STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_msg_transmit_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_msg_transmit_done : out STD_LOGIC;
    cfg_fc_ph : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_fc_pd : out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_fc_nph : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_fc_npd : out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_fc_cplh : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_fc_cpld : out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_fc_sel : in STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_dsn : in STD_LOGIC_VECTOR ( 63 downto 0 );
    cfg_bus_number : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_power_state_change_ack : in STD_LOGIC;
    cfg_power_state_change_interrupt : out STD_LOGIC;
    cfg_err_cor_in : in STD_LOGIC;
    cfg_err_uncor_in : in STD_LOGIC;
    cfg_flr_in_process : out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_flr_done : in STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_vf_flr_in_process : out STD_LOGIC_VECTOR ( 251 downto 0 );
    cfg_vf_flr_func_num : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_vf_flr_done : in STD_LOGIC_VECTOR ( 0 to 0 );
    cfg_link_training_enable : in STD_LOGIC;
    cfg_ext_read_received : out STD_LOGIC;
    cfg_ext_write_received : out STD_LOGIC;
    cfg_ext_register_number : out STD_LOGIC_VECTOR ( 9 downto 0 );
    cfg_ext_function_number : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_ext_write_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_ext_write_byte_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_ext_read_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_ext_read_data_valid : in STD_LOGIC;
    cfg_interrupt_int : in STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_interrupt_pending : in STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_interrupt_sent : out STD_LOGIC;

    cfg_interrupt_msi_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_interrupt_msi_mmenable : out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_interrupt_msi_mask_update : out STD_LOGIC;
    cfg_interrupt_msi_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_interrupt_msi_select : in STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_interrupt_msi_int : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_interrupt_msi_pending_status : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_interrupt_msi_pending_status_data_enable : in STD_LOGIC;
    cfg_interrupt_msi_pending_status_function_num : in STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_interrupt_msi_sent : out STD_LOGIC;
    cfg_interrupt_msi_fail : out STD_LOGIC;
    cfg_interrupt_msi_attr : in STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_interrupt_msi_tph_present : in STD_LOGIC;
    cfg_interrupt_msi_tph_type : in STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_interrupt_msi_tph_st_tag : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_interrupt_msi_function_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_pm_aspm_l1_entry_reject : in STD_LOGIC;
    cfg_pm_aspm_tx_l0s_entry_disable : in STD_LOGIC;
    cfg_hot_reset_out : out STD_LOGIC;
    cfg_config_space_enable : in STD_LOGIC;
    cfg_req_pm_transition_l23_ready : in STD_LOGIC;
    cfg_hot_reset_in : in STD_LOGIC;
    cfg_ds_port_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_ds_bus_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_ds_device_number : in STD_LOGIC_VECTOR ( 4 downto 0 );

--    cfg_pm_aspm_l1_entry_reject : in STD_LOGIC;
--    cfg_pm_aspm_tx_l0s_entry_disable : in STD_LOGIC;
--    cfg_hot_reset_out : out STD_LOGIC;
--    cfg_config_space_enable : in STD_LOGIC;
--    cfg_req_pm_transition_l23_ready : in STD_LOGIC;
--    cfg_hot_reset_in : in STD_LOGIC;
--    cfg_ds_port_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
--    cfg_ds_bus_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
--    cfg_ds_device_number : in STD_LOGIC_VECTOR ( 4 downto 0 );
--    cfg_ds_function_number : in STD_LOGIC_VECTOR ( 2 downto 0 );
--    cfg_subsys_vend_id : in STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_dev_id_pf0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_dev_id_pf1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_dev_id_pf2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_dev_id_pf3 : in STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_vend_id : in STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_rev_id_pf0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
----    cfg_rev_id_pf1 : in STD_LOGIC_VECTOR ( 7 downto 0 );
----    cfg_rev_id_pf2 : in STD_LOGIC_VECTOR ( 7 downto 0 );
----    cfg_rev_id_pf3 : in STD_LOGIC_VECTOR ( 7 downto 0 );
--    cfg_subsys_id_pf0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_subsys_id_pf1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_subsys_id_pf2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_subsys_id_pf3 : in STD_LOGIC_VECTOR ( 15 downto 0 );

    sys_clk : in STD_LOGIC;
    sys_clk_gt : in STD_LOGIC;
    sys_reset : in STD_LOGIC;
    phy_rdy_out : out STD_LOGIC

 -- New for 2016.4
    --int_qpll0lock_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    --int_qpll0outrefclk_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    --int_qpll0outclk_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    --int_qpll1lock_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    --int_qpll1outrefclk_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    --int_qpll1outclk_out : out STD_LOGIC_VECTOR ( 1 downto 0 )

  );

end Component pcie4_uscale_plus_0;

-- IBUFDS_GTE4: Gigabit Transceiver Buffer
-- UltraScale
-- Xilinx HDL Libraries Guide, version 2015.4

Component IBUFDS_GTE4
-- generic(
-- REFCLK_EN_TX_PATH : in std_logic;
-- REFCLK_HROW_CK_SEL : in std_logic_vector(0 to 1);
-- REFCLK_ICNTL_RX  : in std_logic_vector(0 to 1)
-- );
PORT
    (O : out STD_LOGIC;
              ODIV2                                          : out   STD_LOGIC;
              I                                              : in    STD_LOGIC;
              CEB                                            : in    STD_LOGIC;
     IB : in STD_LOGIC
);
end Component IBUFDS_GTE4;

Component IBUF
PORT (
              O                                              : out   STD_LOGIC;
I : in  STD_LOGIC
);
end Component IBUF;

Component uscale_plus_clk_wiz
PORT (
              clk_in1                                        : in    STD_LOGIC;
              clk_out1                                       : out   STD_LOGIC;
              clk_out2                                       : out   STD_LOGIC;
              clk_out3                                       : out   STD_LOGIC;
              clk_out3_ce                                    : in    STD_LOGIC;
              reset                                          : in    STD_LOGIC;
    locked : out STD_LOGIC
  );
end Component uscale_plus_clk_wiz;

-- Component capi_fpga_reset
Component CAPI_FPGA_RESET_GEN
  PORT(PLL_LOCKED    : in  std_logic;
              CLK                                            : in    std_logic;
       RESET     : out std_logic);
End Component CAPI_FPGA_RESET_GEN;

-- Component capi_stp_counter
Component CAPI_STP_COUNTER
  PORT(CLK     : in  std_logic;
              RESET                                          : in    std_logic;
              STP_COUNTER_1sec                               : out   std_logic;
       STP_COUNTER_MSB  : out std_logic);
End Component CAPI_STP_COUNTER;

-- Component psl
Component PSL9_WRAP_0
--Component PSL9_WRAP
  PORT(
------        psl_clk: in std_logic;
------        psl_rst: in std_logic;
------        pcihip0_psl_clk: in std_logic;
------        pcihip0_psl_rst: in std_logic;
------        crc_error: in std_logic;
              a0h_cvalid                                     : in    std_logic;
              a0h_ctag                                       : in    std_logic_vector(0 to 7);
              a0h_com                                        : in    std_logic_vector(0 to 12);
------        a0h_cpad: in std_logic_vector(0 to 2);
              a0h_cabt                                       : in    std_logic_vector(0 to 2);
              a0h_cea                                        : in    std_logic_vector(0 to 63);
              a0h_cch                                        : in    std_logic_vector(0 to 15);
              a0h_csize                                      : in    std_logic_vector(0 to 11);
              a0h_cpagesize                                  : in    std_logic_vector(0 to 3);
              ha0_croom                                      : out   std_logic_vector(0 to 7);
              a0h_ctagpar                                    : in    std_logic;
              a0h_compar                                     : in    std_logic;
              a0h_ceapar                                     : in    std_logic;
              ha0_brvalid                                    : out   std_logic;
              ha0_brtag                                      : out   std_logic_vector(0 to 7);
              ha0_brad                                       : out   std_logic_vector(0 to 5);
              a0h_brlat                                      : in    std_logic_vector(0 to 3);
              a0h_brdata                                     : in    std_logic_vector(0 to 1023);
              a0h_brpar                                      : in    std_logic_vector(0 to 15);
              ha0_bwvalid                                    : out   std_logic;
              ha0_bwtag                                      : out   std_logic_vector(0 to 7);
              ha0_bwad                                       : out   std_logic_vector(0 to 5);
              ha0_bwdata                                     : out   std_logic_vector(0 to 1023);
              ha0_bwpar                                      : out   std_logic_vector(0 to 15);
              ha0_brtagpar                                   : out   std_logic;
              ha0_bwtagpar                                   : out   std_logic;
              ha0_rvalid                                     : out   std_logic;
              ha0_rtag                                       : out   std_logic_vector(0 to 7);
              ha0_rtagpar                                    : out   std_logic;
              ha0_rditag                                     : out   std_logic_vector(0 to 8);
              ha0_rditagpar                                  : out   std_logic;
              ha0_response                                   : out   std_logic_vector(0 to 7);
              ha0_response_ext                               : out   std_logic_vector(0 to 7);
              ha0_rpagesize                                  : out   std_logic_vector(0 to 3);
              ha0_rcredits                                   : out   std_logic_vector(0 to 8);
              ha0_rcachestate                                : out   std_logic_vector(0 to 1);
              ha0_rcachepos                                  : out   std_logic_vector(0 to 12);
              ha0_reoa                                       : out   std_logic_vector(0 to 185);

              ha0_mmval                                      : out   std_logic;
              ha0_mmcfg                                      : out   std_logic;
              ha0_mmrnw                                      : out   std_logic;
              ha0_mmdw                                       : out   std_logic;
              ha0_mmad                                       : out   std_logic_vector(0 to 23);
              ha0_mmadpar                                    : out   std_logic;
              ha0_mmdata                                     : out   std_logic_vector(0 to 63);
              ha0_mmdatapar                                  : out   std_logic;
              a0h_mmack                                      : in    std_logic;
              a0h_mmdata                                     : in    std_logic_vector(0 to 63);
              a0h_mmdatapar                                  : in    std_logic;

              ha0_jval                                       : out   std_logic;
              ha0_jcom                                       : out   std_logic_vector(0 to 7);
              ha0_jcompar                                    : out   std_logic;
              ha0_jea                                        : out   std_logic_vector(0 to 63);
              ha0_jeapar                                     : out   std_logic;
              a0h_jrunning                                   : in    std_logic;
              a0h_jdone                                      : in    std_logic;
              a0h_jcack                                      : in    std_logic;
              a0h_jerror                                     : in    std_logic_vector(0 to 63);
--        a0h_jyield: in std_logic;
              a0h_tbreq                                      : in    std_logic;
              a0h_paren                                      : in    std_logic;
              ha0_pclock                                     : out   std_logic;


              D0H_DVALID                                     : in    std_logic;
              D0H_REQ_UTAG                                   : in    std_logic_vector(0 to 9);
              D0H_REQ_ITAG                                   : in    std_logic_vector(0 to 8);
              D0H_DTYPE                                      : in    std_logic_vector(0 to 2);
--         DH_DRELAXED:in  std_logic;
              D0H_DATOMIC_OP                                 : in    std_logic_vector(0 to 5);
              D0H_DATOMIC_LE                                 : in    std_logic                    ;-- New PSL/AFU interface
              D0H_DSIZE                                      : in    std_logic_vector(0 to 9);
              D0H_DDATA                                      : in    std_logic_vector(0 to 1023);
--         D0H_DPAR: in std_logic_vector(0 to 15);
--         // ----------------------------------------------------------------------------------------------------------------------
--         // ----------------------------
--         // PSL DMA Completion Interface
--         // ----------------------------
              HD0_CPL_VALID                                  : out   std_logic;
              HD0_CPL_UTAG                                   : out   std_logic_vector(0 to 9);
              HD0_CPL_TYPE                                   : out   std_logic_vector(0 to 2);
              HD0_CPL_LADDR                                  : out   std_logic_vector(0 to 6);
              HD0_CPL_BYTE_COUNT                             : out   std_logic_vector(0 to 9);
              HD0_CPL_SIZE                                   : out   std_logic_vector(0 to 9);
              HD0_CPL_DATA                                   : out   std_logic_vector(0 to 1023);
--         HD0_CPL_DPAR : out std_logic_vector(0 to 15);
--         // ----------------------------------------------------------------------------------------------------------------------
--         // ----------------------
--         // PSL DMA Sent Interface
--         // ----------------------
              HD0_SENT_UTAG_VALID                            : out   std_logic;
              HD0_SENT_UTAG                                  : out   std_logic_vector(0 to 9);
              HD0_SENT_UTAG_STS                              : out   std_logic_vector(0 to 2);



              AXIS_CQ_TVALID                                 : in    std_logic;
              AXIS_CQ_TDATA                                  : in    std_logic_vector(511 downto 0);
              AXIS_CQ_TREADY                                 : out   std_logic;
              AXIS_CQ_TUSER                                  : in    std_logic_vector(182 downto 0);
              AXIS_CQ_NP_REQ                                 : out   std_logic_vector(1 downto 0);
--         //XLX IP RC Interface
              AXIS_RC_TVALID                                 : in    std_logic;
              AXIS_RC_TDATA                                  : in    std_logic_vector(511 downto 0);
              AXIS_RC_TREADY                                 : out   std_logic;
              AXIS_RC_TUSER                                  : in    std_logic_vector(160 downto 0);
--         //-----------------------------------------------------------------------------------------------------------------------
--         //XLX IP RQ Interface
              AXIS_RQ_TVALID                                 : out   std_logic;
              AXIS_RQ_TDATA                                  : out   std_logic_vector(511 downto 0);
              AXIS_RQ_TREADY                                 : in    std_logic;
              AXIS_RQ_TLAST                                  : out   std_logic;
              AXIS_RQ_TUSER                                  : out   std_logic_vector(136 downto 0);
              AXIS_RQ_TKEEP                                  : out   std_logic_vector(15 downto 0);
--         //XLX IP CC Interface
              AXIS_CC_TVALID                                 : out   std_logic;
              AXIS_CC_TDATA                                  : out   std_logic_vector(511 downto 0);
              AXIS_CC_TREADY                                 : in    std_logic;
              AXIS_CC_TLAST                                  : out   std_logic;
              AXIS_CC_TUSER                                  : out   std_logic_vector(80 downto 0);
              AXIS_CC_TKEEP                                  : out   std_logic_vector(15 downto 0);
--         //----------------------------------------------------------------------------------------------------------------------
--         // Configuration Interface
--         // cfg_fc_sel[2:0] = 101b, cfg_fc_ph[7:0], cfg_fc_pd[11:0] cfg_fc_nph[7:0]
              XIP_CFG_FC_SEL                                 : out   std_logic_vector(2 downto 0);
              XIP_CFG_FC_PH                                  : in    std_logic_vector(7 downto 0);
              XIP_CFG_FC_PD                                  : in    std_logic_vector(11 downto 0);
              XIP_CFG_FC_NP                                  : in    std_logic_vector(7 downto 0);

              psl_kill_link                                  : out   std_logic;
              psl_build_ver                                  : in    std_logic_vector(0 to 31);
              afu_clk                                        : in    std_logic;

              PSL_RST                                        : in    std_logic;
              PSL_CLK                                        : in    std_logic;
              PCIHIP_PSL_RST                                 : in    std_logic;
        PCIHIP_PSL_CLK : in std_logic

);
-- End Component psl;
End Component PSL9_WRAP_0;
--End Component PSL9_WRAP;

-- CAPI board infrastructure
Component capi_board_infrastructure
  PORT(
              cfg_ext_read_received                          : IN    STD_LOGIC;
              cfg_ext_write_received                         : IN    STD_LOGIC;
              cfg_ext_register_number                        : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
              cfg_ext_function_number                        : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
              cfg_ext_write_data                             : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
              cfg_ext_write_byte_enable                      : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
              cfg_ext_read_data                              : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
              cfg_ext_read_data_valid                        : OUT   STD_LOGIC;

     --    spi_miso_secondary            : in    std_logic;
     --    spi_mosi_secondary            : out   std_logic;
     --    spi_cen_secondary             : out   std_logic;

              pci_pi_nperst0                                 : in    std_logic;
              pcihip0_psl_clk                                : in    std_logic;
              icap_clk                                       : in    std_logic;
              cpld_usergolden                                : in    std_logic                     ;  -- bool
              crc_error                                      : out   std_logic
               );
END Component capi_board_infrastructure;

Component capi_rise_dff
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_rise_dff;

attribute mark_debug : string;
Signal ha0_reoa: std_logic_vector(0 to 185);

Signal hip_npor0: std_logic;  -- bool
Signal i_cpld_sda: std_logic;  -- bool
Signal crc_error: std_logic;  -- bool
Signal i_therm_sda: std_logic;  -- bool
Signal i_ucd_sda: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_app_int_ack: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_app_msi_ack: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_cfg_par_err: std_logic;  -- bool
Signal pcihip0_psl_coreclkout_hip: std_logic;  -- bool
Signal pcihip0_psl_cseb_addr: std_logic_vector(0 to 32);  -- v33bit
Signal pcihip0_psl_cseb_addr_parity: std_logic_vector(0 to 4);  -- v5bit
Signal pcihip0_psl_cseb_be: std_logic_vector(0 to 3);  -- v4bit
Signal pcihip0_psl_cseb_rden: std_logic;  -- bool
Signal pcihip0_psl_cseb_wrdata: std_logic_vector(0 to 31);  -- v32bit
Signal pcihip0_psl_cseb_wrdata_parity: std_logic_vector(0 to 3);  -- v4bit
Signal pcihip0_psl_cseb_wren: std_logic;  -- bool
Signal pcihip0_psl_cseb_wrresp_req: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_derr_cor_ext_rcv: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_derr_cor_ext_rpl: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_derr_rpl: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_hip_reconfig_readdata: std_logic_vector(0 to 15);  -- v16bit
-- Apr13 Signal pcihip0_psl_ko_cpl_spc_data: std_logic_vector(0 to 11);  -- v12bit
-- Apr13 Signal pcihip0_psl_ko_cpl_spc_header: std_logic_vector(0 to 7);  -- v8bit
-- Apr13 Signal pcihip0_psl_lmi_ack: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_lmi_dout: std_logic_vector(0 to 31);  -- v32bit
Signal pcihip0_psl_pld_clk_inuse: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_pme_to_sr: std_logic;  -- bool
Signal pcihip0_psl_reset_status: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_rx_par_err: std_logic;  -- bool
Signal pcihip0_psl_rx_st_bar: std_logic_vector(0 to 7);  -- v8bit
Signal pcihip0_psl_rx_st_data: std_logic_vector(0 to 255);  -- v256bit
Signal pcihip0_psl_rx_st_empty: std_logic_vector(0 to 1);  -- v2bit
Signal pcihip0_psl_rx_st_eop: std_logic;  -- bool
Signal pcihip0_psl_rx_st_err: std_logic;  -- bool
Signal pcihip0_psl_rx_st_parity: std_logic_vector(0 to 31);  -- v32bit
Signal pcihip0_psl_rx_st_sop: std_logic;  -- bool
Signal pcihip0_psl_rx_st_valid: std_logic;  -- bool
-- Apr13 Signal pcihip0_psl_testin_zero: std_logic;  -- bool
Signal pcihip0_psl_tl_cfg_add: std_logic_vector(0 to 3);  -- v4bit
Signal pcihip0_psl_tl_cfg_ctl: std_logic_vector(0 to 31);  -- v32bit
-- Apr13 Signal pcihip0_psl_tl_cfg_sts: std_logic_vector(0 to 52);  -- v53bit
Signal pcihip0_psl_tx_cred_datafccp: std_logic_vector(0 to 11);  -- v12bit
Signal pcihip0_psl_tx_cred_datafcnp: std_logic_vector(0 to 11);  -- v12bit
Signal pcihip0_psl_tx_cred_datafcp: std_logic_vector(0 to 11);  -- v12bit
Signal pcihip0_psl_tx_cred_fchipcons: std_logic_vector(0 to 5);  -- v6bit
Signal pcihip0_psl_tx_cred_fcinfinite: std_logic_vector(0 to 5);  -- v6bit
Signal pcihip0_psl_tx_cred_hdrfccp: std_logic_vector(0 to 7);  -- v8bit
Signal pcihip0_psl_tx_cred_hdrfcnp: std_logic_vector(0 to 7);  -- v8bit
Signal pcihip0_psl_tx_cred_hdrfcp: std_logic_vector(0 to 7);  -- v8bit
-- Apr13 Signal pcihip0_psl_tx_par_err: std_logic_vector(0 to 1);  -- v2bit
Signal pcihip0_psl_tx_st_ready: std_logic;  -- bool
Signal psl_clk: std_logic;  -- bool
Signal psl_clk_div2: std_logic;  -- bool

Signal sys_clk_p   : std_logic ;
Signal sys_clk_n   : std_logic ;
Signal sys_rst_n   : std_logic ;
Signal pci_exp_txn : STD_LOGIC_VECTOR (15 downto 0);
Signal pci_exp_txp : STD_LOGIC_VECTOR (15 downto 0);
Signal pci_exp_rxn : STD_LOGIC_VECTOR (15 downto 0);
Signal pci_exp_rxp : STD_LOGIC_VECTOR (15 downto 0);

signal        psl_reset_sig : std_logic;
signal        axis_cq_tvalid : std_logic;
signal        axis_cq_tdata  : std_logic_vector(511 downto 0);
signal        axis_cq_tready : std_logic;
signal        axis_cq_tready_22 : std_logic_vector(0 downto 0);
signal        axis_cq_tuser  : std_logic_vector(182 downto 0);
signal        axis_cq_np_req : std_logic_vector(1 downto 0);
--         //XLX IP RC Interface
signal        axis_rc_tvalid  : std_logic;
signal        axis_rc_tdata   : std_logic_vector(511 downto 0);
signal        axis_rc_tready  : std_logic;
-- signal        axis_rc_tready_22  : std_logic_vector(0 downto 0);
signal        axis_rc_tready_22  : std_logic;
signal        axis_rc_tuser   : std_logic_vector(160 downto 0);
--         //-----------------------------------------------------------------------------------------------------------------------
--         //XLX IP RQ Interface
signal        axis_rq_tvalid  : std_logic;
signal        axis_rq_tdata   : std_logic_vector(511 downto 0);
signal        axis_rq_tready  : std_logic_vector(3 downto 0);
signal        axis_rq_tlast   : std_logic;
signal        axis_rq_tuser   : std_logic_vector(136 downto 0);
signal        axis_rq_tkeep   : std_logic_vector(15 downto 0);
--         //XLX IP CC Interface
signal        axis_cc_tvalid  : std_logic;
signal        axis_cc_tdata   : std_logic_vector(511 downto 0);
signal        axis_cc_tready  : std_logic_vector(3 downto 0);
signal        axis_cc_tlast   : std_logic;
signal        axis_cc_tuser   : std_logic_vector(80 downto 0);
signal        axis_cc_tkeep   : std_logic_vector(15 downto 0);

Signal pcihip0_psl_clk  : std_logic;
Signal pcihip0_psl_rst  : std_logic;
Signal user_lnk_up  : std_logic;

Signal xip_cfg_fc_sel_sig   : std_logic_vector(2 downto 0);
Signal xip_cfg_fc_ph_sig    : std_logic_vector(7 downto 0);
Signal xip_cfg_fc_pd_sig    : std_logic_vector(11 downto 0);
Signal xip_cfg_fc_np_sig    : std_logic_vector(7 downto 0);
Signal cfg_dsn_sig  : std_logic_vector(63 downto 0);

Signal sys_clk    : std_logic;
Signal sys_clk_gt   : std_logic;
Signal sys_rst_n_c   : std_logic;

Signal stp_counter_msb_sig : std_logic;
Signal stp_counter_1sec_sig : std_logic;
Signal sys_clk_counter_1sec_sig : std_logic;
Signal user_clock_sig  : std_logic;

signal clk_wiz_2_locked : std_logic;

signal efes32             : std_logic_vector(31 downto 0);
--signal efes1024           : std_logic_vector(1023 downto 0);
signal one1             : std_logic;
signal two2             : std_logic_vector(1 downto 0);

signal psl_build_ver: std_logic_vector(0 to 31);

Signal icap_clk: std_logic;  -- 125Mhz clock from PCIe refclk
Signal icap_clk_ce: std_logic;  -- bool
Signal icap_clk_ce_d: std_logic;

Signal cfg_ext_read_received : STD_LOGIC;
Signal cfg_ext_write_received : STD_LOGIC;
Signal cfg_ext_register_number : STD_LOGIC_VECTOR(9 DOWNTO 0);
Signal cfg_ext_function_number : STD_LOGIC_VECTOR(7 DOWNTO 0);
Signal cfg_ext_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
Signal cfg_ext_write_byte_enable : STD_LOGIC_VECTOR(3 DOWNTO 0);
Signal cfg_ext_read_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
Signal cfg_ext_read_data_valid : STD_LOGIC;


Signal led_red : std_logic_vector(3 downto 0);
Signal led_green : std_logic_vector(3 downto 0);
Signal led_blue : std_logic_vector(3 downto 0);

begin

-- psl_build_ver   <= x"0000685a";    -- March 15, 2017 With Subsystem ID = x060f for capi_flash script
psl_build_ver   <= x"00006900";    -- March 22, 2017 With fixes and With Subsystem ID = x060f for capi_flash script
-- hd0_cpl_laddr <= "000" & hd0_cpl_laddr_0_6;



    -- PSL logic
p:  PSL9_WRAP_0
      PORT MAP (
-- Apr13         crc_error => crc_errorinternal,
         a0h_cvalid => a0h_cvalid,
         a0h_ctag => a0h_ctag,
         a0h_com => a0h_com,
-- Apr13         a0h_cpad => a0h_cpad,
         a0h_cabt => a0h_cabt,
         a0h_cea => a0h_cea,
         a0h_cch => a0h_cch,
         a0h_csize => a0h_csize,
         a0h_cpagesize => a0h_cpagesize,
         ha0_croom => ha0_croom,
         a0h_ctagpar => a0h_ctagpar,
         a0h_compar => a0h_compar,
         a0h_ceapar => a0h_ceapar,
         ha0_brvalid => ha0_brvalid,
         ha0_brtag => ha0_brtag,
         ha0_brad => ha0_brad,
         a0h_brlat => a0h_brlat,
         a0h_brdata => a0h_brdata,
         a0h_brpar => a0h_brpar,
         ha0_bwvalid => ha0_bwvalid,
         ha0_bwtag => ha0_bwtag,
         ha0_bwad => ha0_bwad,
         ha0_bwdata => ha0_bwdata,
         ha0_bwpar => ha0_bwpar,
         ha0_brtagpar => ha0_brtagpar,
         ha0_bwtagpar => ha0_bwtagpar,
         ha0_rcredits => ha0_rcredits,

         ha0_response_ext => ha0_response_ext,
         ha0_rditag => ha0_rditag,
         ha0_rditagpar => ha0_rditagpar,
         ha0_rpagesize => ha0_rpagesize,

         ha0_rvalid => ha0_rvalid,
         ha0_rtag => ha0_rtag,
         ha0_response => ha0_response,
         ha0_rcachestate => ha0_rcachestate,
         ha0_rcachepos => ha0_rcachepos,
         ha0_rtagpar => ha0_rtagpar,
         ha0_reoa => ha0_reoa,

         ha0_mmval => ha0_mmval,
         ha0_mmrnw => ha0_mmrnw,
         ha0_mmdw => ha0_mmdw,
         ha0_mmad => ha0_mmad,
         ha0_mmdata => ha0_mmdata,
         ha0_mmcfg => ha0_mmcfg,
         a0h_mmack => a0h_mmack,
         a0h_mmdata => a0h_mmdata,
         ha0_mmadpar => ha0_mmadpar,
         ha0_mmdatapar => ha0_mmdatapar,
         a0h_mmdatapar => a0h_mmdatapar,

         ha0_jval => ha0_jval,
         ha0_jcom => ha0_jcom,
         ha0_jea => ha0_jea,
         a0h_jrunning => a0h_jrunning,
         a0h_jdone => a0h_jdone,
         a0h_jcack => a0h_jcack,
         a0h_jerror => a0h_jerror,
         a0h_tbreq => a0h_tbreq,
--          a0h_jyield => a0h_jyield,
         ha0_jeapar => ha0_jeapar,
         ha0_jcompar => ha0_jcompar,
         a0h_paren => a0h_paren,
         ha0_pclock => ha0_pclock,

        D0H_DVALID => d0h_dvalid,
        D0H_REQ_UTAG => d0h_req_utag,
        D0H_REQ_ITAG => d0h_req_itag,
        D0H_DTYPE => d0h_dtype,
        D0H_DATOMIC_OP => d0h_datomic_op,
        D0H_DATOMIC_LE => d0h_datomic_le,
--        DH_DRELAXED => d0h_drelaxed,
        D0H_DSIZE => d0h_dsize,
        D0H_DDATA => d0h_ddata,
--         D0H_DPAR => d0h_dpar,

        HD0_CPL_VALID => hd0_cpl_valid,
        HD0_CPL_UTAG => hd0_cpl_utag,
        HD0_CPL_TYPE => hd0_cpl_type,
        HD0_CPL_LADDR => hd0_cpl_laddr,
        HD0_CPL_BYTE_COUNT => hd0_cpl_byte_count,
        HD0_CPL_SIZE => hd0_cpl_size,
        HD0_CPL_DATA => hd0_cpl_data,
--         HD0_CPL_DPAR => hd0_cpl_dpar,
--
        HD0_SENT_UTAG_VALID => hd0_sent_utag_valid,
        HD0_SENT_UTAG => hd0_sent_utag,
        HD0_SENT_UTAG_STS => hd0_sent_utag_sts,




        AXIS_CQ_TVALID  => axis_cq_tvalid,
        AXIS_CQ_TDATA   => axis_cq_tdata,
        AXIS_CQ_TREADY  => axis_cq_tready,
        AXIS_CQ_TUSER   => axis_cq_tuser,
        AXIS_CQ_NP_REQ  => axis_cq_np_req,
--         //XLX IP RC Interface
        AXIS_RC_TVALID  => axis_rc_tvalid,
        AXIS_RC_TDATA   => axis_rc_tdata,
        AXIS_RC_TREADY  => axis_rc_tready,
        AXIS_RC_TUSER   => axis_rc_tuser,
--         //-----------------------------------------------------------------------------------------------------------------------
--         //XLX IP RQ Interface
        AXIS_RQ_TVALID  => axis_rq_tvalid,
        AXIS_RQ_TDATA   => axis_rq_tdata,
        AXIS_RQ_TREADY  => axis_rq_tready(0),  -- AM. TDB
        AXIS_RQ_TLAST   => axis_rq_tlast,
        AXIS_RQ_TUSER   => axis_rq_tuser,
        AXIS_RQ_TKEEP   => axis_rq_tkeep,
--         //XLX IP CC Interface
        AXIS_CC_TVALID  => axis_cc_tvalid,
        AXIS_CC_TDATA   => axis_cc_tdata,
        AXIS_CC_TREADY  => axis_cc_tready(0),  -- AM. TDB
        AXIS_CC_TLAST   => axis_cc_tlast,
        AXIS_CC_TUSER   => axis_cc_tuser,
        AXIS_CC_TKEEP   => axis_cc_tkeep,
--         //----------------------------------------------------------------------------------------------------------------------
--         // Configuration Interface
--         // cfg_fc_sel[2:0] = 101b, cfg_fc_ph[7:0], cfg_fc_pd[11:0] cfg_fc_nph[7:0]
        XIP_CFG_FC_SEL  => xip_cfg_fc_sel_sig,
        XIP_CFG_FC_PH   => xip_cfg_fc_ph_sig,
        XIP_CFG_FC_PD   => xip_cfg_fc_pd_sig,
        XIP_CFG_FC_NP   => xip_cfg_fc_np_sig,

        psl_kill_link  => open,
        psl_build_ver   => psl_build_ver,
        afu_clk         => psl_clk,            -- TBD AM.

        PSL_RST         => psl_reset_sig,
        PSL_CLK         => psl_clk,
        PCIHIP_PSL_RST  => pcihip0_psl_rst,
        PCIHIP_PSL_CLK  => pcihip0_psl_clk

    );

cfg_dsn_sig <= x"00000001" & x"01" & x"000A35";

efes32   <= x"00000000";
--efes1024 <= x"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
one1   <= '1';
two2   <= one1 & one1;

sys_clk_p   <= pcie_clkp;
sys_clk_n   <= pcie_clkn;
sys_rst_n   <= pcie_rst_n;

pcie_txn(15 downto 0)    <= pci_exp_txn(15 downto 0);
pcie_txp(15 downto 0)    <= pci_exp_txp(15 downto 0);
pci_exp_rxn(15 downto 0) <= pcie_rxn(15 downto 0);
pci_exp_rxp(15 downto 0) <= pcie_rxp(15 downto 0);
--pci0_o_txn_out0 <= pci_exp_txn(0);
--pci0_o_txp_out0 <= pci_exp_txp(0);
--pci_exp_rxn(0) <= pci0_i_rxp_in0;
--pci_exp_rxp(0) <= pci0_i_rxn_in0;
--pci0_o_txn_out1 <= pci_exp_txn(1);
--pci0_o_txp_out1 <= pci_exp_txp(1);
--pci_exp_rxn(1) <= pci0_i_rxp_in1;
--pci_exp_rxp(1) <= pci0_i_rxn_in1;
--pci0_o_txn_out2 <= pci_exp_txn(2);
--pci0_o_txp_out2 <= pci_exp_txp(2);
--pci_exp_rxn(2) <= pci0_i_rxp_in2;
--pci_exp_rxp(2) <= pci0_i_rxn_in2;
--pci0_o_txn_out3 <= pci_exp_txn(3);
--pci0_o_txp_out3 <= pci_exp_txp(3);
--pci_exp_rxn(3) <= pci0_i_rxp_in3;
--pci_exp_rxp(3) <= pci0_i_rxn_in3;
--pci0_o_txn_out4 <= pci_exp_txn(4);
--pci0_o_txp_out4 <= pci_exp_txp(4);
--pci_exp_rxn(4) <= pci0_i_rxp_in4;
--pci_exp_rxp(4) <= pci0_i_rxn_in4;
--pci0_o_txn_out5 <= pci_exp_txn(5);
--pci0_o_txp_out5 <= pci_exp_txp(5);
--pci_exp_rxn(5) <= pci0_i_rxp_in5;
--pci_exp_rxp(5) <= pci0_i_rxn_in5;
--pci0_o_txn_out6 <= pci_exp_txn(6);
--pci0_o_txp_out6 <= pci_exp_txp(6);
--pci_exp_rxn(6) <= pci0_i_rxp_in6;
--pci_exp_rxp(6) <= pci0_i_rxn_in6;
--pci0_o_txn_out7 <= pci_exp_txn(7);
--pci0_o_txp_out7 <= pci_exp_txp(7);
--pci_exp_rxn(7) <= pci0_i_rxp_in7;
--pci_exp_rxp(7) <= pci0_i_rxn_in7;
--
--pci0_o_txn_out8 <= pci_exp_txn(8);
--pci0_o_txp_out8 <= pci_exp_txp(8);
--pci_exp_rxn(8) <= pci0_i_rxp_in8;
--pci_exp_rxp(8) <= pci0_i_rxn_in8;
--pci0_o_txn_out9 <= pci_exp_txn(9);
--pci0_o_txp_out9 <= pci_exp_txp(9);
--pci_exp_rxn(9) <= pci0_i_rxp_in9;
--pci_exp_rxp(9) <= pci0_i_rxn_in9;
--pci0_o_txn_out10 <= pci_exp_txn(10);
--pci0_o_txp_out10 <= pci_exp_txp(10);
--pci_exp_rxn(10) <= pci0_i_rxp_in10;
--pci_exp_rxp(10) <= pci0_i_rxn_in10;
--pci0_o_txn_out11 <= pci_exp_txn(11);
--pci0_o_txp_out11 <= pci_exp_txp(11);
--pci_exp_rxn(11) <= pci0_i_rxp_in11;
--pci_exp_rxp(11) <= pci0_i_rxn_in11;
--pci0_o_txn_out12 <= pci_exp_txn(12);
--pci0_o_txp_out12 <= pci_exp_txp(12);
--pci_exp_rxn(12) <= pci0_i_rxp_in12;
--pci_exp_rxp(12) <= pci0_i_rxn_in12;
--pci0_o_txn_out13 <= pci_exp_txn(13);
--pci0_o_txp_out13 <= pci_exp_txp(13);
--pci_exp_rxn(13) <= pci0_i_rxp_in13;
--pci_exp_rxp(13) <= pci0_i_rxn_in13;
--pci0_o_txn_out14 <= pci_exp_txn(14);
--pci0_o_txp_out14 <= pci_exp_txp(14);
--pci_exp_rxn(14) <= pci0_i_rxp_in14;
--pci_exp_rxp(14) <= pci0_i_rxn_in14;
--pci0_o_txn_out15 <= pci_exp_txn(15);
--pci0_o_txp_out15 <= pci_exp_txp(15);
--pci_exp_rxn(15) <= pci0_i_rxp_in15;
--pci_exp_rxp(15) <= pci0_i_rxn_in15;

pci_user_reset <= pcihip0_psl_rst;
pci_clock_125MHz <= psl_clk_div2;


pcihip0:      pcie4_uscale_plus_0
PORT MAP (
    pci_exp_txn =>  pci_exp_txn ,   -- out STD_LOGIC_VECTOR ( 15 downto 0 );
    pci_exp_txp =>  pci_exp_txp ,   -- out STD_LOGIC_VECTOR ( 15 downto 0 );
    pci_exp_rxn =>  pci_exp_rxn ,   -- in STD_LOGIC_VECTOR ( 15 downto 0 );
    pci_exp_rxp =>  pci_exp_rxp ,   -- in STD_LOGIC_VECTOR ( 15 downto 0 );

    user_clk  => pcihip0_psl_clk,     -- out STD_LOGIC;
    user_reset  => pcihip0_psl_rst,     -- out STD_LOGIC;
    user_lnk_up => user_lnk_up,      -- out STD_LOGIC;

    s_axis_rq_tdata => axis_rq_tdata,     -- in  STD_LOGIC_VECTOR ( 511 downto 0 );
    s_axis_rq_tkeep => axis_rq_tkeep,     -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_rq_tlast => axis_rq_tlast,     -- in  STD_LOGIC;
    s_axis_rq_tready => axis_rq_tready,   -- out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_rq_tuser => axis_rq_tuser,     -- in  STD_LOGIC_VECTOR ( 136 downto 0 );
    s_axis_rq_tvalid => axis_rq_tvalid,   -- in  STD_LOGIC;
    m_axis_rc_tdata => axis_rc_tdata,     -- out STD_LOGIC_VECTOR ( 511 downto 0 );
    m_axis_rc_tkeep => open,      -- out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_rc_tlast => open,      -- out STD_LOGIC;
    m_axis_rc_tready(0) => axis_rc_tready,  -- axis_rc_tready,    -- in  STD_LOGIC_VECTOR ( 21 downto 0 );
    m_axis_rc_tuser => axis_rc_tuser,     -- out STD_LOGIC_VECTOR ( 160 downto 0 );
    m_axis_rc_tvalid => axis_rc_tvalid,   -- out STD_LOGIC;
    m_axis_cq_tdata => axis_cq_tdata,     -- out STD_LOGIC_VECTOR ( 511 downto 0 );
    m_axis_cq_tkeep => open,      -- out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_cq_tlast => open,      -- out STD_LOGIC;
    m_axis_cq_tready(0) => axis_cq_tready,  -- axis_cq_tready,    -- in  STD_LOGIC_VECTOR ( 21 downto 0 );
    m_axis_cq_tuser => axis_cq_tuser,     -- out STD_LOGIC_VECTOR ( 182 downto 0 );
    m_axis_cq_tvalid => axis_cq_tvalid,    -- out STD_LOGIC;
    s_axis_cc_tdata => axis_cc_tdata,     -- in  STD_LOGIC_VECTOR ( 511 downto 0 );
    s_axis_cc_tkeep => axis_cc_tkeep,     -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_cc_tlast => axis_cc_tlast,     -- in  STD_LOGIC;
    s_axis_cc_tready => axis_cc_tready,    -- out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_cc_tuser => axis_cc_tuser,     -- in  STD_LOGIC_VECTOR ( 80 downto 0 );
    s_axis_cc_tvalid => axis_cc_tvalid,    -- in  STD_LOGIC;

    pcie_rq_seq_num0 => open,      -- out STD_LOGIC_VECTOR ( 5 downto 0 );
    pcie_rq_seq_num_vld0 => open,     -- out STD_LOGIC;
    pcie_rq_seq_num1 => open,      -- out STD_LOGIC_VECTOR ( 5 downto 0 );
    pcie_rq_seq_num_vld1 => open,     -- out STD_LOGIC;
    pcie_rq_tag0 => open,      -- out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_rq_tag1 => open,      -- out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_rq_tag_av => open,      -- out STD_LOGIC_VECTOR ( 3 downto 0 );
    pcie_rq_tag_vld0 => open,      -- out STD_LOGIC;
    pcie_rq_tag_vld1 => open,      -- out STD_LOGIC;
    pcie_tfc_nph_av => open,      -- out STD_LOGIC_VECTOR ( 3 downto 0 );
    pcie_tfc_npd_av => open,      -- out STD_LOGIC_VECTOR ( 3 downto 0 );
-- Jan 27, 2017    pcie_cq_np_req => (others => '0'),    -- in  STD_LOGIC_VECTOR ( 1 downto 0 );
    pcie_cq_np_req => two2,    -- in  STD_LOGIC_VECTOR ( 1 downto 0 );     -- Jan 27, 2017
    pcie_cq_np_req_count => open,     -- out STD_LOGIC_VECTOR ( 5 downto 0 );

    cfg_phy_link_down => open,     -- out STD_LOGIC;
    cfg_phy_link_status => open,     -- out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_negotiated_width => open,     -- out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_current_speed => open,     -- out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_max_payload => open,      -- out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_max_read_req => open,      -- out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_function_status => open,     -- out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_function_power_state => open,     -- out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_vf_status => open,      -- out STD_LOGIC_VECTOR ( 503 downto 0 );
    cfg_vf_power_state => open,     -- out STD_LOGIC_VECTOR ( 755 downto 0 );
    cfg_link_power_state => open,     -- out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_mgmt_addr => efes32(9 downto 0),--(others => '0'),     -- in  STD_LOGIC_VECTOR ( 9 downto 0 );
    cfg_mgmt_function_number => efes32(7 downto 0),--(others => '0'),   -- in  STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_mgmt_write =>  '0',      -- in  STD_LOGIC;
    cfg_mgmt_write_data => efes32,    --(others => '0'),    -- in  STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_mgmt_byte_enable => efes32(3 downto 0),    -- (others => '0'),    -- in  STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_mgmt_read => '0',      -- in  STD_LOGIC;
    cfg_mgmt_read_data => open,     -- out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_mgmt_read_write_done => open,     -- out STD_LOGIC;
    cfg_mgmt_debug_access => '0',     -- in  STD_LOGIC;
    cfg_err_cor_out => open,      -- out STD_LOGIC;
    cfg_err_nonfatal_out => open,     -- out STD_LOGIC;
    cfg_err_fatal_out => open,     -- out STD_LOGIC;
    cfg_local_error_valid => open,     -- out STD_LOGIC;
--     cfg_ltr_enable => open,     -- out STD_LOGIC;
    cfg_local_error_out => open,     -- out STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_ltssm_state => open,      -- out STD_LOGIC_VECTOR ( 5 downto 0 );
    cfg_rx_pm_state => open,      -- out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_tx_pm_state => open,      -- out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_rcb_status => open,       -- out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_obff_enable => open,       -- out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_pl_status_change => open,      -- out STD_LOGIC;
    cfg_tph_requester_enable => open,     -- out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_tph_st_mode => open,       -- out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_vf_tph_requester_enable => open,     -- out STD_LOGIC_VECTOR ( 251 downto 0 );
    cfg_vf_tph_st_mode => open,      -- out STD_LOGIC_VECTOR ( 755 downto 0 );
    cfg_msg_received => open,      -- out STD_LOGIC;
    cfg_msg_received_data => open,      -- out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_msg_received_type => open,      -- out STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_msg_transmit => '0',       -- in  STD_LOGIC;
    cfg_msg_transmit_type => efes32(2 downto 0),    -- (others => '0'),    -- in  STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_msg_transmit_data => efes32, --(others => '0'),    -- in  STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_msg_transmit_done => open,      -- out STD_LOGIC;
    cfg_fc_ph => xip_cfg_fc_ph_sig,      -- out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_fc_pd => xip_cfg_fc_pd_sig,      -- out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_fc_nph => xip_cfg_fc_np_sig,      -- out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_fc_npd => open,       -- out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_fc_cplh => open,       -- out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_fc_cpld => open,       -- out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_fc_sel => xip_cfg_fc_sel_sig,     -- in  STD_LOGIC_VECTOR ( 2 downto 0 );
--     cfg_dsn => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 63 downto 0 );
    cfg_dsn => cfg_dsn_sig,       -- in  STD_LOGIC_VECTOR ( 63 downto 0 );
    cfg_bus_number => open,       -- out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_power_state_change_ack => '0',     -- in  STD_LOGIC;
    cfg_power_state_change_interrupt => open,    -- out STD_LOGIC;
    cfg_err_cor_in => '0',       -- in  STD_LOGIC;
    cfg_err_uncor_in => '0',       -- in  STD_LOGIC;
    cfg_flr_in_process => open,      -- out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_flr_done => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_vf_flr_in_process => open,      -- out STD_LOGIC_VECTOR ( 251 downto 0 );
    cfg_vf_flr_func_num => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_vf_flr_done => (others => '0'),       -- in  STD_LOGIC_VECTOR ( 0 to 0 );
--     cfg_link_training_enable => '0',       -- in  STD_LOGIC;
    cfg_link_training_enable => '1',       -- in  STD_LOGIC;
    cfg_ext_read_received => cfg_ext_read_received,     -- out STD_LOGIC;
    cfg_ext_write_received => cfg_ext_write_received,   -- out STD_LOGIC;
    cfg_ext_register_number => cfg_ext_register_number, -- out STD_LOGIC_VECTOR ( 9 downto 0 );
    cfg_ext_function_number => cfg_ext_function_number,       -- out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_ext_write_data => cfg_ext_write_data,      -- out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_ext_write_byte_enable => cfg_ext_write_byte_enable,     -- out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_ext_read_data => cfg_ext_read_data,      -- in  STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_ext_read_data_valid => cfg_ext_read_data_valid,  -- in  STD_LOGIC;
    cfg_interrupt_int => efes32(3 downto 0),      -- in  STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_interrupt_pending => efes32(3 downto 0),    -- in  STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_interrupt_sent => open,        -- out STD_LOGIC;


    cfg_interrupt_msi_enable => open,       -- : out STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_interrupt_msi_mmenable => open,       -- : out STD_LOGIC_VECTOR ( 11 downto 0 );
    cfg_interrupt_msi_mask_update => open,       -- : out STD_LOGIC;
    cfg_interrupt_msi_data => open,         -- : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_interrupt_msi_select => (others => '0'),        -- : in STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_interrupt_msi_int => (others => '0'),        -- : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_interrupt_msi_pending_status => (others => '0'),       -- : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_interrupt_msi_pending_status_data_enable => '0',     -- : in STD_LOGIC;
    cfg_interrupt_msi_pending_status_function_num => (others => '0'),   -- : in STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_interrupt_msi_sent => open,         -- : out STD_LOGIC;
    cfg_interrupt_msi_fail => open,         -- : out STD_LOGIC;
    cfg_interrupt_msi_attr => (others => '0'),        -- : in STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_interrupt_msi_tph_present => '0',       -- : in STD_LOGIC;
    cfg_interrupt_msi_tph_type => (others => '0'),        -- : in STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_interrupt_msi_tph_st_tag => (others => '0'),       -- : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_interrupt_msi_function_number => (others => '0'),       -- : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_pm_aspm_l1_entry_reject => '0',       -- : in STD_LOGIC;
-- AM. Apr 8    cfg_pm_aspm_tx_l0s_entry_disable => '0',       -- : in STD_LOGIC;
    cfg_pm_aspm_tx_l0s_entry_disable => '1',       -- : in STD_LOGIC;
    cfg_hot_reset_out => open,         -- : out STD_LOGIC;
--     cfg_config_space_enable => '0',        -- : in STD_LOGIC;
    cfg_config_space_enable => '1',        -- : in STD_LOGIC;
    cfg_req_pm_transition_l23_ready => '0',       -- : in STD_LOGIC;
    cfg_hot_reset_in => '0',         -- : in STD_LOGIC;
    cfg_ds_port_number => (others => '0'),         -- : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_ds_bus_number => (others => '0'),         -- : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_ds_device_number => (others => '0'),        -- : in STD_LOGIC_VECTOR ( 4 downto 0 );

----    cfg_pm_aspm_l1_entry_reject => '0',       -- in  STD_LOGIC;
----    cfg_pm_aspm_tx_l0s_entry_disable => '0',      -- in  STD_LOGIC;
----    cfg_hot_reset_out => open,        -- out STD_LOGIC;
----    cfg_config_space_enable => '0',       -- in  STD_LOGIC;
----    cfg_req_pm_transition_l23_ready => '0',      -- in  STD_LOGIC;
----    cfg_hot_reset_in => '0',        -- in  STD_LOGIC;
----    cfg_ds_port_number => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 7 downto 0 );
----    cfg_ds_bus_number => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 7 downto 0 );
----    cfg_ds_device_number => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 4 downto 0 );
----    cfg_ds_function_number => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 2 downto 0 );
--    cfg_subsys_vend_id => (X"1014"),      -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_dev_id_pf0 => (X"0477"),       -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_dev_id_pf1 => (others => '0'),       -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_dev_id_pf2 => (others => '0'),       -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_dev_id_pf3 => (others => '0'),       -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_vend_id => (X"1014"),       -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
--    cfg_rev_id_pf0 => (X"02"),       -- in  STD_LOGIC_VECTOR ( 7 downto 0 );
----    cfg_rev_id_pf1 => (others => '0'),       -- in  STD_LOGIC_VECTOR ( 7 downto 0 );
----    cfg_rev_id_pf2 => (others => '0'),       -- in  STD_LOGIC_VECTOR ( 7 downto 0 );
----    cfg_rev_id_pf3 => (others => '0'),       -- in  STD_LOGIC_VECTOR ( 7 downto 0 );
--    cfg_subsys_id_pf0 => (X"060f"),      -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_subsys_id_pf1 => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_subsys_id_pf2 => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
----    cfg_subsys_id_pf3 => (others => '0'),      -- in  STD_LOGIC_VECTOR ( 15 downto 0 );
--
--     sys_clk => sys_clk_p,        -- in  STD_LOGIC;
    sys_clk => sys_clk,         -- in  STD_LOGIC;
    sys_clk_gt => sys_clk_gt,        -- in  STD_LOGIC;
--     sys_reset =>  PCIE_PERST_LS   -- sys_rst_n  -- in  STD_LOGIC
    sys_reset =>  sys_rst_n_c,  -- in  STD_LOGIC

    phy_rdy_out => open

    --int_qpll0lock_out  => open,
    --int_qpll0outrefclk_out  => open,
    --int_qpll0outclk_out  => open,
    --int_qpll1lock_out  => open,
    --int_qpll1outrefclk_out  => open,
    --int_qpll1outclk_out => open

  );

-- CAPI board infrastructure
capi_bis : capi_board_infrastructure
  PORT map (
    cfg_ext_read_received       => cfg_ext_read_received,
    cfg_ext_write_received      => cfg_ext_write_received,
    cfg_ext_register_number     => cfg_ext_register_number,
    cfg_ext_function_number     => cfg_ext_function_number,
    cfg_ext_write_data          => cfg_ext_write_data,
    cfg_ext_write_byte_enable   => cfg_ext_write_byte_enable,
    cfg_ext_read_data           => cfg_ext_read_data,
    cfg_ext_read_data_valid     => cfg_ext_read_data_valid,

   -- spi_miso_secondary          => spi_miso_secondary,
   -- spi_mosi_secondary          => spi_mosi_secondary,
   -- spi_cen_secondary           => spi_cen_secondary,

    pci_pi_nperst0              => sys_rst_n_c,
    pcihip0_psl_clk             => pcihip0_psl_clk,
    icap_clk                    => icap_clk,
    cpld_usergolden             => gold_factory,
    crc_error                   => crc_error
    );

-- Xilinx component which is required to generate correct clocks towards PCIHIP
refclk_ibuf : IBUFDS_GTE4
-- generic map (
-- REFCLK_EN_TX_PATH  => '0',  -- Refer to Transceiver User Guide
-- REFCLK_HROW_CK_SEL  => "00",  -- Refer to Transceiver User Guide
-- REFCLK_ICNTL_RX  => "00"  -- Refer to Transceiver User Guide
-- )
port map (
    O   => sys_clk_gt,   -- 1-bit output: Refer to Transceiver User Guide
    ODIV2  => sys_clk,   -- 1-bit output: Refer to Transceiver User Guide
    CEB  => '0',   -- 1'b0,   -- 1-bit input: Refer to Transceiver User Guide
    I   => sys_clk_p,   -- 1-bit input: Refer to Transceiver User Guide
    IB   => sys_clk_n   -- 1-bit input: Refer to Transceiver User Guide
);
-- End of IBUFDS_GTE4_inst instantiation


IBUF_inst : IBUF
port map (
O => sys_rst_n_c,  -- 1-bit output: Buffer output
I => sys_rst_n   -- 1-bit input: Buffer input
);
-- End of IBUF_inst instantiation


--        gate clock_lite until clocks are stable after link up
--        avoid glitches to sem core to prevent false errors or worse
--        also used to clock multiboot logic so keep enabled when link goes down
-- clock_lite_ce <= clock_gen_locked and not(user_reset);
dff_icap_clk_ce: capi_rise_dff PORT MAP (
     dout => icap_clk_ce,
     din => icap_clk_ce_d,
     clk   => pcihip0_psl_clk
);

icap_clk_ce_d <= icap_clk_ce or (clk_wiz_2_locked and not(pcihip0_psl_rst));
-- MMCM to generate PSL clock (100...250MHz)
pll0:         uscale_plus_clk_wiz
PORT MAP  (
    clk_in1  => pcihip0_psl_clk, -- Driven by PCIHIP
    clk_out1  => psl_clk,   -- Goes to PSL logic
    clk_out2    => psl_clk_div2, -- 125MHz out to psl_accel if required (went to PSL logic)
    clk_out3  => icap_clk,     -- Goes to SEM, multiboot
    clk_out3_ce => icap_clk_ce,     -- gate off while unstable to prevent SEM errors
    reset   => '0', -- Driven by PCIHIP
    locked   => clk_wiz_2_locked
  );




--Component capi_fpga_reset
capi_fpga_reset:CAPI_FPGA_RESET_GEN
 PORT MAP (
   PLL_LOCKED  => clk_wiz_2_locked,
   CLK   => psl_clk,
   RESET  => psl_reset_sig
   );

-- Component capi_stp_counter
csc:          CAPI_STP_COUNTER
 PORT MAP (
   CLK   => psl_clk,
   RESET  => psl_reset_sig,
   STP_COUNTER_1sec => stp_counter_1sec_sig,
   STP_COUNTER_MSB => stp_counter_msb_sig
   );


------ sys_clk_p_out: CAPI_STP_COUNTER
------  PORT MAP (
------    CLK   => sys_clk,
------    RESET  => pcihip0_psl_rst,
------    STP_COUNTER_1sec => sys_clk_counter_1sec_sig,
------    STP_COUNTER_MSB => open
------    );

user_clock:   CAPI_STP_COUNTER
 PORT MAP (
   CLK   => pcihip0_psl_clk,
   RESET  => pcihip0_psl_rst,
   STP_COUNTER_1sec => user_clock_sig,
   STP_COUNTER_MSB => open
   );


END capi_bsp;
