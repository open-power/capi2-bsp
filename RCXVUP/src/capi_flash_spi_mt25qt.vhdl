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

library ieee, UNISIM;
use UNISIM.vcomponents.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

ENTITY capi_flash_spi_mt25qt IS
  PORT(psl_clk: in std_logic;

       -- --------------- --
       spi_clk: out std_logic;
       spi_cen: out std_logic;
       spi_miso : in std_logic;
       spi_mosi : out std_logic;

       -- -------------- --
       f_program_req: in std_logic;                                         -- Level --
       f_num_blocks: in std_logic_vector(0 to 9);                           -- 128KB Block Size --
       f_start_blk: in std_logic_vector(0 to 9);
       f_program_data: in std_logic_vector(0 to 31);
       f_program_data_val: in std_logic;
       f_program_data_ack: out std_logic;
       f_ready: out std_logic;
       f_done: out std_logic;
       f_stat_erase: out std_logic;
       f_stat_program: out std_logic;
       f_stat_read: out std_logic;
       f_remainder: out std_logic_vector(0 to 9);

       -- Read Interface --
       f_read_req: in std_logic;
       f_num_words_m1: in std_logic_vector(0 to 9);                         -- N-1 words --
       f_read_start_addr: in std_logic_vector(0 to 25);
       f_read_data: out std_logic_vector(0 to 31);
       f_read_data_val: out std_logic;
       f_read_data_ack: in std_logic);

END capi_flash_spi_mt25qt;

ARCHITECTURE capi_flash_spi_mt25qt OF capi_flash_spi_mt25qt IS

Component capi_en_rise_vdff
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        en    : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_en_rise_vdff;

Component capi_rise_dff
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_rise_dff;

Component capi_rise_dff_init1
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_rise_dff_init1;

Component capi_en_rise_dff
  PORT (clk   : in std_logic;
        en    : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_en_rise_dff;

Component capi_rise_vdff
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_rise_vdff;

function gate_and (gate : std_logic; din : std_logic_vector) return std_logic_vector is
begin
  if (gate = '1') then
    return din;
  else
    return (0 to din'length-1 => '0');
  end if;
end gate_and;

Signal ONE_v17bit: std_logic_vector(0 to 16);  -- v17bit
Signal ONE_v9bit: std_logic_vector(0 to 8);  -- v9bit
Signal Z_v10bit: std_logic_vector(0 to 9);  -- v10bit
Signal Z_v17bit: std_logic_vector(0 to 16);  -- v17bit
Signal Z_v32bit: std_logic_vector(0 to 31);  -- v32bit
Signal Z_v9bit: std_logic_vector(0 to 8);  -- v9bit
Signal buf_dat: std_logic_vector(0 to 31);  -- v32bit
Signal buf_full: std_logic;  -- bool
Signal cnt_en: std_logic;  -- bool
Signal cycdly_d: std_logic_vector(0 to 15);  -- v6bit
Signal cycdly_m1: std_logic_vector(0 to 15);  -- v6bit
Signal cycdly_q: std_logic_vector(0 to 15);  -- v6bit
Signal datain_hien: std_logic;  -- bool
Signal datain_loen: std_logic;  -- bool
Signal dly_done: std_logic;  -- bool
Signal erase_addr: std_logic_vector(0 to 25);  -- v26bit
Signal erase_adr_sel: std_logic;  -- bool
Signal erase_ce: std_logic;  -- bool
Signal erase_complete: std_logic;  -- bool
Signal erase_dat_oe: std_logic;  -- bool
Signal erase_data_out: std_logic_vector(0 to 31);  -- v32bit
Signal erase_dly: std_logic_vector(0 to 5);  -- v6bit
Signal erase_oe: std_logic;  -- bool
Signal erase_sm: std_logic_vector(0 to 4);  -- v5bit
Signal erase_sm_nxt: std_logic_vector(0 to 4);  -- v5bit
Signal erase_sm_p1: std_logic_vector(0 to 4);  -- v5bit
Signal erase_sm_start_dly: std_logic;  -- bool
Signal erase_we: std_logic;  -- bool
Signal esm_adv: std_logic;  -- bool
Signal esm_blkadr_d: std_logic_vector(0 to 9);  -- v10bit
Signal esm_blkadr_p1: std_logic_vector(0 to 9);  -- v10bit
Signal esm_blkadr_q: std_logic_vector(0 to 9);  -- v10bit
Signal esm_blkcnt_d: std_logic_vector(0 to 9);  -- v10bit
Signal esm_blkcnt_m1: std_logic_vector(0 to 9);  -- v10bit
Signal esm_blkcnt_q: std_logic_vector(0 to 9);  -- v10bit
Signal esm_datain_en: std_logic;  -- bool
Signal esm_done: std_logic;  -- bool
Signal esm_no_dly_sel: std_logic;  -- bool
Signal esm_p1: std_logic;  -- bool
Signal esm_redo_rd: std_logic;  -- bool
Signal esm_rst: std_logic;  -- bool
Signal esm_sel_CEH_dly: std_logic;  -- bool
Signal esm_sel_FTD_dly: std_logic;  -- bool
Signal esm_sel_OEH_dly: std_logic;  -- bool
Signal esm_sel_OEL_dly: std_logic;  -- bool
Signal esm_sel_WEH_dly: std_logic;  -- bool
Signal esm_sel_WEL_dly: std_logic;  -- bool
Signal esm_sel_clrstat: std_logic;  -- bool
Signal esm_sel_erase: std_logic;  -- bool
Signal esm_sel_execute: std_logic;  -- bool
Signal esm_sel_unlock: std_logic;  -- bool
Signal esm_sel_zero: std_logic;  -- bool
Signal esm_update_blkadr: std_logic;  -- bool
Signal esm_update_blkcnt: std_logic;  -- bool
Signal faddr: std_logic_vector(0 to 25);  -- v26bit
Signal faddr_be: std_logic_vector(0 to 25);  -- v26bit
Signal fcen: std_logic_vector(0 to 1);  -- v2bit
Signal fcen_0: std_logic;  -- bool
Signal fcen_1: std_logic;  -- bool
Signal fdatain: std_logic_vector(0 to 31);  -- v32bit
Signal fdatain_hi: std_logic_vector(0 to 15);  -- v16bit
Signal fdatain_lo: std_logic_vector(0 to 15);  -- v16bit
Signal fdataout: std_logic_vector(0 to 15);  -- v16bit
Signal fdataout_be: std_logic_vector(0 to 31);  -- v32bit
Signal fdataout_be_d: std_logic_vector(0 to 15);  -- v16bit
Signal fdatoe: std_logic;  -- bool
Signal fintf_oe: std_logic;  -- bool
Signal flash_busy: std_logic;  -- bool
Signal flash_error: std_logic;  -- bool
Signal foen: std_logic;  -- bool
Signal frstn: std_logic;  -- bool
Signal fwen: std_logic;  -- bool
Signal init_buf_off: std_logic;  -- bool
Signal init_cnt_adr: std_logic;  -- bool
Signal main_dly: std_logic_vector(0 to 5);  -- v6bit
Signal main_sm_nxt_0: std_logic;  -- bool
Signal main_sm_nxt_1: std_logic;  -- bool
Signal main_sm_nxt_2: std_logic;  -- bool
Signal main_sm_nxt_3: std_logic;  -- bool
Signal main_sm_nxt_4: std_logic;  -- bool
Signal main_sm_nxt_5: std_logic;  -- bool
Signal main_sm_nxt_6: std_logic;  -- bool
Signal main_sm_nxt_7: std_logic;  -- bool
Signal main_sm_start_dly: std_logic;  -- bool
Signal msm_no_dly_sel: std_logic;  -- bool
Signal msm_rstp_dly_sel: std_logic;  -- bool
Signal msm_rstr_dly_sel: std_logic;  -- bool
Signal new_dly: std_logic_vector(0 to 15);  -- v6bit
Signal num_buffers: std_logic_vector(0 to 16);  -- v17bit
Signal pflreqn: std_logic;  -- bool
Signal pgm_addr: std_logic_vector(0 to 25);  -- v26bit
Signal pgm_adr_sel: std_logic;  -- bool
Signal pgm_ce: std_logic;  -- bool
Signal pgm_complete: std_logic;  -- bool
Signal pgm_dat_oe: std_logic;  -- bool
Signal pgm_data_out: std_logic_vector(0 to 31);  -- v32bit
Signal pgm_dly: std_logic_vector(0 to 5);  -- v6bit
Signal pgm_oe: std_logic;  -- bool
Signal pgm_rd_req: std_logic;  -- bool
Signal pgm_remainder: std_logic_vector(0 to 9);  -- v10bit
Signal pgm_sm: std_logic_vector(0 to 4);  -- v5bit
Signal pgm_sm_nxt: std_logic_vector(0 to 4);  -- v5bit
Signal pgm_sm_p1: std_logic_vector(0 to 4);  -- v5bit
Signal pgm_sm_start_dly: std_logic;  -- bool
Signal pgm_we: std_logic;  -- bool
Signal program_flash: std_logic;  -- bool
Signal psm_adv: std_logic;  -- bool
Signal psm_bufadr_d: std_logic_vector(0 to 16);  -- v17bit
Signal psm_bufadr_p1: std_logic_vector(0 to 16);  -- v17bit
Signal psm_bufadr_q: std_logic_vector(0 to 16);  -- v17bit
Signal psm_bufcnt_d: std_logic_vector(0 to 16);  -- v17bit
Signal psm_bufcnt_m1: std_logic_vector(0 to 16);  -- v17bit
Signal psm_bufcnt_q: std_logic_vector(0 to 16);  -- v17bit
Signal psm_bufoff_d: std_logic_vector(0 to 8);  -- v9bit
Signal psm_bufoff_p1: std_logic_vector(0 to 8);  -- v9bit
Signal psm_bufoff_q: std_logic_vector(0 to 8);  -- v9bit
Signal psm_datain_en: std_logic;  -- bool
Signal psm_done: std_logic;  -- bool
Signal psm_more_bufs: std_logic;  -- bool
Signal psm_no_dly_sel: std_logic;  -- bool
Signal psm_p1: std_logic;  -- bool
Signal psm_pgm_nxt_buf: std_logic;  -- bool
Signal psm_redo_bufavail_rd: std_logic;  -- bool
Signal psm_redo_bufdone_rd: std_logic;  -- bool
Signal psm_sel_CEH_dly: std_logic;  -- bool
Signal psm_sel_FTD_dly: std_logic;  -- bool
Signal psm_sel_OEH_dly: std_logic;  -- bool
Signal psm_sel_OEL_dly: std_logic;  -- bool
Signal psm_sel_WEH_dly: std_logic;  -- bool
Signal psm_sel_WEL_dly: std_logic;  -- bool
Signal psm_sel_bufcmd: std_logic;  -- bool
Signal psm_sel_bufdat: std_logic;  -- bool
Signal psm_sel_clrstat: std_logic;  -- bool
Signal psm_sel_execute: std_logic;  -- bool
Signal psm_sel_zero: std_logic;  -- bool
Signal psm_update_bufadr: std_logic;  -- bool
Signal psm_update_bufcnt: std_logic;  -- bool
Signal psm_update_bufoff: std_logic;  -- bool
Signal psm_update_wrdcnt: std_logic;  -- bool
Signal psm_wr_nxt_buf_dat: std_logic;  -- bool
Signal psm_wrcntdec_en_d: std_logic;  -- bool
Signal psm_wrcntdec_en_q: std_logic;  -- bool
Signal psm_wrdat_d: std_logic;  -- bool
Signal psm_wrdat_q: std_logic;  -- bool
Signal psm_wrdcnt_d: std_logic_vector(0 to 8);  -- v9bit
Signal psm_wrdcnt_m1: std_logic_vector(0 to 8);  -- v9bit
Signal psm_wrdcnt_q: std_logic_vector(0 to 8);  -- v9bit
Signal rd_start_addr: std_logic_vector(0 to 25);  -- v26bit
Signal read_addr: std_logic_vector(0 to 25);  -- v26bit
Signal read_adr_sel: std_logic;  -- bool
Signal read_ce: std_logic;  -- bool
Signal read_complete: std_logic;  -- bool
Signal read_dat_oe: std_logic;  -- bool
Signal read_data_out: std_logic_vector(0 to 31);  -- v32bit
Signal read_data_val_d: std_logic;  -- bool
Signal read_dly: std_logic_vector(0 to 5);  -- v6bit
Signal read_flash: std_logic;  -- bool
Signal read_oe: std_logic;  -- bool
Signal read_sm: std_logic_vector(0 to 4);  -- v5bit
Signal read_sm_nxt: std_logic_vector(0 to 4);  -- v5bit
Signal read_sm_p1: std_logic_vector(0 to 4);  -- v5bit
Signal read_sm_start_dly: std_logic;  -- bool
Signal read_we: std_logic;  -- bool
Signal rsm_adv: std_logic;  -- bool
Signal rsm_datain_en: std_logic;  -- bool
Signal rsm_done: std_logic;  -- bool
Signal rsm_more_dat: std_logic;  -- bool
Signal rsm_no_dly_sel: std_logic;  -- bool
Signal rsm_p1: std_logic;  -- bool
Signal rsm_rd_nxt_wrd: std_logic;  -- bool
Signal rsm_rst: std_logic;  -- bool
Signal rsm_sel_CEH_dly: std_logic;  -- bool
Signal rsm_sel_FTD_dly: std_logic;  -- bool
Signal rsm_sel_RCT_dly: std_logic;  -- bool
Signal rsm_sel_WEH_dly: std_logic;  -- bool
Signal rsm_sel_WEL_dly: std_logic;  -- bool
Signal rsm_sel_rdcmd: std_logic;  -- bool
Signal rsm_update_wrdadr: std_logic;  -- bool
Signal rsm_update_wrdcnt: std_logic;  -- bool
Signal rsm_wrdadr_d: std_logic_vector(0 to 25);  -- v26bit
Signal rsm_wrdadr_p1: std_logic_vector(0 to 25);  -- v26bit
Signal rsm_wrdadr_q: std_logic_vector(0 to 25);  -- v26bit
Signal rsm_wrdcnt_d: std_logic_vector(0 to 9);  -- v10bit
Signal rsm_wrdcnt_m1: std_logic_vector(0 to 9);  -- v10bit
Signal rsm_wrdcnt_q: std_logic_vector(0 to 9);  -- v10bit
Signal rst_pulse: std_logic_vector(0 to 5);  -- v6bit
Signal rst_recov: std_logic_vector(0 to 5);  -- v6bit
Signal start_buf: std_logic_vector(0 to 16);  -- v17bit
Signal start_dly: std_logic;  -- bool
--Signal version: std_logic_vector(0 to 31);  -- int
Signal f_read_data_valinternal: std_logic;  -- bool
Signal flash_dataout_d: std_logic_vector(0 to 15);
Signal flash_datain_d: std_logic_vector(0 to 15);
Signal flash_addr_d: std_logic_vector(0 to 25);
Signal flash_intf_oe_d: std_logic_vector(0 to 30);
Signal flash_dat_oe_d: std_logic_vector(0 to 15);
Signal flash_wen_d: std_logic;
Signal flash_oen_d: std_logic;
Signal flash_cen_d: std_logic_vector(0 to 1);
Signal flash_rstn_d: std_logic;
Signal flash_intf_oe_unrep_d: std_logic;
Signal flash_dat_oe_unrep_d: std_logic;
Signal spi_in: std_logic_vector(0 to 3);
Signal spi_cs: std_logic;
Signal msm_rst: std_logic;
Signal msm_p1: std_logic;
Signal msm_to_s0x0F: std_logic;
Signal msm_to_s0x11: std_logic;
Signal msm_to_s0x18: std_logic;
Signal msm_to_s0x31: std_logic;
Signal msm_to_s0x14: std_logic;
Signal msm_to_s0x2E: std_logic;
Signal msm_to_s0x3E: std_logic;
Signal msm_to_s0x2F: std_logic;
Signal msm_to_s0x1B: std_logic;
Signal msm_return: std_logic;
Signal main_sm_p1: std_logic_vector(0 to 5);
Signal main_sm_nxt: std_logic_vector(0 to 5);
Signal main_sm_adv: std_logic;
Signal main_sm: std_logic_vector(0 to 5);
Signal msm_return_p1: std_logic;
Signal msm_return_pgm: std_logic;
Signal msm_return_read: std_logic;
Signal msm_returnstate_update: std_logic;
Signal msm_returnstate: std_logic_vector(0 to 5);
Signal msm_returnstate_d: std_logic_vector(0 to 5);
Signal msm_s0x00: std_logic;  -- bool
Signal msm_s0x01: std_logic;  -- bool
Signal msm_s0x10: std_logic;  -- bool
Signal msm_s0x11: std_logic;  -- bool
Signal msm_s0x12: std_logic;  -- bool
Signal msm_s0x13: std_logic;  -- bool
Signal msm_s0x14: std_logic;  -- bool
Signal msm_s0x15: std_logic;  -- bool
Signal msm_s0x16: std_logic;  -- bool
Signal msm_s0x17: std_logic;  -- bool
Signal msm_s0x18: std_logic;  -- bool
Signal msm_s0x19: std_logic;  -- bool
Signal msm_s0x1A: std_logic;  -- bool
Signal msm_s0x1B: std_logic;  -- bool
Signal msm_s0x1C: std_logic;  -- bool
Signal msm_s0x1D: std_logic;  -- bool
Signal msm_s0x2E: std_logic;  -- bool
Signal msm_s0x2F: std_logic;  -- bool
Signal msm_s0x02: std_logic;  -- bool
Signal msm_s0x03: std_logic;  -- bool
Signal msm_s0x04: std_logic;  -- bool
Signal msm_s0x05: std_logic;  -- bool
Signal msm_s0x0F: std_logic;
Signal msm_s0x30: std_logic;  -- bool
Signal msm_s0x31: std_logic;  -- bool
Signal msm_s0x32: std_logic;  -- bool
Signal msm_s0x3E: std_logic;  -- bool
Signal qspi_rst_en: std_logic_vector(0 to 7);
Signal qspi_rst_mem: std_logic_vector(0 to 7);
Signal qspi_enter_4B_addr: std_logic_vector(0 to 7);--Command Only
Signal qspi_enter_quad_mode: std_logic_vector(0 to 7);--Command Only
Signal qspi_we: std_logic_vector(0 to 7);
Signal qspi_4B_read: std_logic_vector(0 to 7);--Com-Adr-Data--
Signal qspi_fstatus_read: std_logic_vector(0 to 7);--Command then Data--
Signal qspi_fstatus_clear: std_logic_vector(0 to 7);--Command Only
Signal qspi_4B_page_pgm: std_logic_vector(0 to 7);--Com-Adr-Data--
Signal qspi_sector_erase: std_logic_vector(0 to 7);--Command then Address
Signal quad_mode_update: std_logic;
Signal quad_mode_d: std_logic;
Signal quad_mode: std_logic;
Signal fourB_address_mode_update: std_logic;
Signal fourB_address_mode_d: std_logic;
Signal fourB_address_mode: std_logic;
Signal command_sent: std_logic;
Signal address_sent_update: std_logic;
Signal address_sent_d: std_logic;
Signal address_sent: std_logic;
Signal data_sent_update: std_logic;
Signal data_sent_d: std_logic;
Signal data_sent: std_logic;
Signal start_address_update: std_logic;
Signal start_address_d: std_logic_vector(0 to 31);
Signal start_address: std_logic_vector(0 to 31);
Signal start_sectors_d: std_logic_vector(0 to 9);
Signal start_sectors: std_logic_vector(0 to 9);
Signal start_sectors_update: std_logic;
Signal command_update: std_logic;
Signal command_d: std_logic_vector(0 to 7);
Signal command: std_logic_vector(0 to 7);
Signal read_speed_d: std_logic;
Signal read_speed_update: std_logic;
Signal read_speed: std_logic;
Signal msm_update_blkadr: std_logic;
Signal msm_update_blkadr_q: std_logic;
Signal esm_blkadr: std_logic_vector(0 to 31);
Signal msm_byteadr: std_logic_vector(0 to 31);
Signal msm_byteadr_p1: std_logic_vector(0 to 17);
Signal msm_byteadr_d: std_logic_vector(0 to 17);
Signal msm_update_byteadr: std_logic;
Signal msm_update_byteadr_q: std_logic;
Signal msm_byteadr_q: std_logic_vector(0 to 17);
Signal more2erase: std_logic;
Signal msm_bytecnt_m1: std_logic_vector(0 to 17);
Signal msm_bytecnt_d: std_logic_vector(0 to 17);
Signal msm_update_bytecnt:std_logic;
Signal msm_bytecnt_q: std_logic_vector(0 to 17);
Signal msm_bytecnt: std_logic_vector(0 to 17);
Signal more2pgm: std_logic;
Signal more2read: std_logic;
Signal spi_clk_tristate_n: std_logic;
Signal spi_clk_d: std_logic := '1';
Signal spi_clk_q: std_logic := '1';
Signal spi_clk_qq: std_logic := '1';
Signal spi_clk_int: std_logic := '1';
Signal spi_cs_d: std_logic;
Signal fifo_reset: std_logic;
Signal pgm_fifo_push: std_logic;
Signal pgm_data_mux_d: std_logic_vector(0 to 1);
Signal pgm_data_mux_en: std_logic;
Signal pgm_data_mux_q: std_logic_vector(0 to 1);
Signal pgm_fifo_wrdata: std_logic_vector(0 to 7);
Signal pgm_fifo_pull: std_logic;
Signal pgm_fifo_empty: std_logic;
Signal pgm_fifo_full: std_logic;
Signal pgm_fifo_rddata: std_logic_vector(0 to 7);
Signal pgm_fifo_cnt_d: std_logic_vector(0 to 9);
Signal pgm_fifo_cnt: std_logic_vector(0 to 9);
Signal txfifo_has_256B: std_logic;
Signal rd_fifo_push: std_logic;
Signal rd_fifo_wrdata: std_logic_vector(0 to 7);
Signal rd_fifo_pull: std_logic;
Signal rd_fifo_pull_q: std_logic;
Signal rd_fifo_empty: std_logic;
Signal rd_fifo_full: std_logic;
Signal rd_fifo_rddata: std_logic_vector(0 to 7);
Signal rd_fifo_cnt_d: std_logic_vector(0 to 9);
Signal rd_fifo_cnt: std_logic_vector(0 to 9);
Signal rxfifo_rec_256B: std_logic;
Signal f_read_data_d: std_logic_vector(0 to 31);
Signal f_read_data_q: std_logic_vector(0 to 31);
Signal f_read_data_val_d: std_logic;
Signal f_read_data_val_q: std_logic;
Signal update_frval: std_logic;
Signal flash_timeout: std_logic;
Signal dsm_rst: std_logic;
Signal dsm_p1: std_logic;
Signal dsm_m1: std_logic;
Signal dsm_to_s0x06: std_logic;
Signal dsm_to_s0x08: std_logic;
Signal drain_sm_p1: std_logic_vector(0 to 3);
Signal drain_sm_m1: std_logic_vector(0 to 3);
Signal drain_sm_nxt: std_logic_vector(0 to 3);
Signal drain_sm_adv: std_logic;
Signal drain_sm: std_logic_vector(0 to 3);
Signal dsm_s0x00: std_logic;
Signal dsm_s0x01: std_logic;
Signal dsm_s0x02: std_logic;
Signal dsm_s0x03: std_logic;
Signal dsm_s0x04: std_logic;
Signal dsm_s0x05: std_logic;
Signal dsm_s0x06: std_logic;
Signal dsm_s0x07: std_logic;
Signal dsm_s0x08: std_logic;
Signal byte_d: std_logic_vector(0 to 7);
Signal byte_update: std_logic;
Signal byte: std_logic_vector(0 to 7);
Signal address_bytepos_d: std_logic_vector(0 to 1);
Signal address_bytepos: std_logic_vector(0 to 1);
Signal bit_pointer_d: std_logic_vector(0 to 2);
Signal bit_pointer: std_logic_vector(0 to 2);
Signal spi_mosi_d: std_logic;
Signal spi_mosi_q: std_logic;
Signal run_spi_clk: std_logic;
Signal address: std_logic_vector(0 to 31);
Signal address_d: std_logic_vector(0 to 31);
Signal address_done: std_logic;
Signal byte_xfer_complete: std_logic;
Signal byte_rec_complete: std_logic;
Signal spi_cs_q: std_logic;
Signal data: std_logic_vector(0 to 7);
Signal data_done: std_logic;
Signal xfer_count: std_logic_vector(0 to 3);
Signal xfer_count_d: std_logic_vector(0 to 3);
Signal rec_count: std_logic_vector(0 to 3);
Signal rec_count_d: std_logic_vector(0 to 3);
Signal total_dbytes_d: std_logic_vector(0 to 7);
Signal total_dbytes: std_logic_vector(0 to 7);
Signal total_dbytes_update: std_logic;
Signal spi_miso_q: std_logic;
Signal in_byte_update: std_logic_vector(0 to 7);
Signal in_byte_d: std_logic_vector(0 to 7);
Signal in_byte: std_logic_vector(0 to 7);
Signal flag_status: std_logic_vector(0 to 7);
Signal flag_status_d: std_logic_vector(0 to 7);
Signal flag_status_update: std_logic;
Signal cs_counter_d: std_logic_vector(0 to 3);
Signal cs_counterdone: std_logic;
Signal cs_counter: std_logic_vector(0 to 3);
Signal f_stat_erase_d: std_logic;
Signal f_stat_erase_update: std_logic;
Signal f_stat_pgm_d: std_logic;
Signal f_stat_pgm_update: std_logic;
Signal f_stat_read_d: std_logic;
Signal f_stat_read_update: std_logic;
Signal rst_clk_pulses: std_logic;
Signal clk_pulses_d: std_logic_vector(0 to 3);
Signal clk_pulses: std_logic_vector(0 to 3);
Signal clk_exhausted: std_logic;
Signal clk_exhausted_q: std_logic;
Signal clk_exhausted_qq: std_logic;
Signal clk_exhausted_qqq: std_logic;
Signal clk_exhausted_qqqq: std_logic;

Signal spi_mosi_startup: std_logic;
Signal spi_clk_startup: std_logic;
Signal spi_cen_startup: std_logic;
--Signal spi_mosi: std_logic;
--Signal spi_clk: std_logic;
--Signal spi_cen: std_logic;
--Signal spi_miso: std_logic;
Signal clklogic: std_logic;
Signal spicen: STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         spiclk : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         spimosi : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         spimiso : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         mainstate : STD_LOGIC_VECTOR(5 DOWNTO 0);
Signal         drainstate : STD_LOGIC_VECTOR(3 DOWNTO 0);
Signal         fiforeset : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         txpush : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         txpull : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         txwdata : STD_LOGIC_VECTOR(7 DOWNTO 0);
Signal         txrdata : STD_LOGIC_VECTOR(7 DOWNTO 0);
Signal         txempty : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         txfull : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         rxpush : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         rxpull : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         rxwdata : STD_LOGIC_VECTOR(7 DOWNTO 0);
Signal         rxrdata : STD_LOGIC_VECTOR(7 DOWNTO 0);
Signal         rxempty : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         rxfull : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         frdval : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal         frdack : STD_LOGIC_VECTOR(0 DOWNTO 0);
Signal rxfifo_has_4B: std_logic;
Signal rd_pull4B: std_logic;
Signal rd_pull4B_q: std_logic;
Signal rd_pull4B_q2: std_logic;
Signal rd_pull4B_q3: std_logic;
Signal rd_pull4B_q4: std_logic;
Signal start_4B_xfer_d:std_logic;
Signal start_4B_xfer:std_logic;
Signal start_4B_xfer_en:std_logic;
Signal start_4B_xfer_q:std_logic;

begin

  Z_v9bit <= (others => '0');
  Z_v32bit <= (others => '0');
  Z_v17bit <= (others => '0');
  Z_v10bit <= (others => '0');

--    version <= "00000000000000000000000000001100" ;

clklogic <= psl_clk;
spicen(0) <= spi_cs_q;
spiclk(0) <= spi_clk_q;
spimosi(0) <= spi_mosi_q;
spimiso(0) <= spi_miso;
mainstate <= main_sm;
drainstate <= drain_sm;
fiforeset(0) <= fifo_reset;
txpush(0) <= pgm_fifo_push;
txpull(0) <= pgm_fifo_pull;
txempty(0) <= pgm_fifo_empty;
txfull(0) <= pgm_fifo_full;
txwdata <= pgm_fifo_wrdata;
txrdata <= pgm_fifo_rddata;
rxpush(0) <= rd_fifo_push;
rxpull(0) <= rd_fifo_pull;
rxempty(0) <= rd_fifo_empty;
rxfull(0) <= rd_fifo_full;
rxwdata <= rd_fifo_wrdata;
rxrdata <= rd_fifo_rddata;
frdval(0) <= f_read_data_val_q;
frdack(0) <= f_read_data_ack;

--============================================================================================
---- Misc. Logic
--==============================================================================================--

    flash_busy <= not(flag_status(0)) ;
    flash_error <= flag_status(0) and (flag_status(6) or flag_status(5) or flag_status(4) or flag_status(2) or flag_status(1)) ;
    flash_timeout <= '0';

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Outputs                             --
 -- ----------------------------------- --

    pgm_remainder <= psm_bufcnt_q(0 to 9) when erase_complete='1' else esm_blkcnt_q;

    f_remainder <= rsm_wrdcnt_q when f_read_req='1' else pgm_remainder;

 -- -- End Section -- --

--============================================================================================
---- Main State
--==============================================================================================--
    ---- Nxt State always 0 if neither f_program_req or f_read_req set
    ---- State 00  : IDLE                                           ----
    ----            Nxt State 1 if f_program_req or f_read_req                              ----
    ---- State 01  : Apply internal resets                                           ----
    ----            Nxt State 2
    ---- State 02  : Queue RESET ENABLE Command                    ----
    ----            Nxt State 0F
    ---- State 03  : Queue RESET MEMORY Command                                   ----
    ----            Nxt State 0F
    ---- State 04  : Queue ENTER 4B ADDRESS MODE Command                                        ----
    ----            Nxt State 0F
    ---- State 05  : Queue ENTER QUAD MODE Command                                           ----
    ----            Nxt State 0F
    ---- State 06  : Placeholder state for more commands            ----
    ---- State 07  : Placeholder state for more commands            ----
    ---- State 08  : Placeholder state for more commands            ----
    ---- State 09  : Placeholder state for more commands            ----
    ---- State 0A  : Placeholder state for more commands            ----
    ---- State 0B  : Placeholder state for more commands            ----
    ---- State 0C  : Placeholder state for more commands            ----
    ---- State 0D  : Placeholder state for more commands            ----
    ---- State 0E  : Placeholder state for more commands            ----
    ---- State 0F  : Drain Commands/Address/Data into Target SPI                                        ----
    ----            Nxt State return_state
    ---- State 10 : ERASE/PROGRAM phase begin sample job size and                                          ----
    ----            Nxt State 11
    ---- State 11 : Queue CLEAR FLAG STATUS REGISTER command          ----
    ----            Nxt State 0F
    ---- State 12 : Queue WRITE ENABLE Command                                          ----
    ----            Nxt State 0F
    ---- State 13 : Queue SECTOR ERASE Command                                           ----
    ----            Nxt State 0F
    ---- State 14 : Queue READ FLAG STATUS REGISTER Command                   ----
    ----            Nxt State 0F
    ---- State 15 : Analyze Current Status                                           ----
    ----            Nxt State 14 if flash_busy and no flash_timeout
    ----            Nxt State 2F if flash_error or flash_timeout
    ----            Nxt State 16 if not flash_busy and not flash_error
    ---- State 16 : Update Address and Remaining Job Size                   ----
    ----            Nxt State 11 if more2erase                               ----
    ----            Nxt State 17 if erase complete                               ----
    ---- State 17 : PROGRAM ROUTINE: Reset address, job size; Indicate Erase is complete                                           ----
    ----            Nxt State 18
    ---- State 18 : Queue CLEAR FLAG STATUS REGISTER Command
    ----            Nxt State 0F
    ---- State 19 : Queue WRITE ENABLE Command                                           ----
    ----            Nxt State 0F
    ---- State 1A : Queue 4B ADDRESS PAGE PROGRAM Command AND Wait for 256 bytes data in tx fifo                                           ----
    ----            Nxt State 0F
    ---- State 1B : Queue READ FLAGS STATUS REGISTER Command
    ----            Nxt State 0F
    ---- State 1C : Analyze Current Status                                           ----
    ----            Nxt State 1B if flash_busy and no flash_timeout
    ----            Nxt State 2F if flash_error or flash_timeout
    ----            Nxt State 1D if not flash_busy and not flash_error                                           ----
    ---- State 1D : Update Address and Remaining Job Size
    ----            Nxt State 18 if more2pgm
    ----            Nxt State 2E if not more2pgm
    ---- State 2E : Indicate Erase/Program finished w/o errors                                           ----
    ----            Nxt State 2E if f_program_req
    ----            Nxt State 00 if not f_program_req
    ---- State 2F : Indicate Erase/Program errored out
    ----            Nxt State 2F if f_program_req
    ----            Nxt State 00 if not f_program_req
    ---- State 30 : READ Routine: Sample Starting Address and Job size.
    ----            Nxt State 31
    ---- State 31 : Queue READ Command And Wait for 256 bytes free in read buffer                                 ----
    ----            Nxt State 0F
    ---- State 32 : Update address and job size left                                           ----
    ----            Nxt State 31 if more2read
    ----            Nxt State 3E if not more2read
    ---- State 3E : Indicate Read finished w/o errors                   ----
    ----            Nxt State 3E if f_read_req
    ----            Nxt State 00 if not f_read_req

 -- ----------------------------------- --
 -- Next State Equations and SM Latch   --
 -- ----------------------------------- --

    pgm_rd_req <= f_program_req  or  f_read_req ;

    ---- Next State Controls ----
    msm_rst <= not(pgm_rd_req) ;    -- Reset State Machine when program is complete --
    msm_to_s0x0F <= (msm_s0x02 or msm_s0x03 or msm_s0x04 or msm_s0x05  or msm_s0x11 or msm_s0x12 or msm_s0x13 or msm_s0x14 or msm_s0x18 or msm_s0x19 or msm_s0x1A or msm_s0x1B or msm_s0x31) and not(msm_rst);
    msm_p1 <= (msm_s0x00 or msm_s0x01 or msm_s0x10 or (msm_s0x16 and not(more2erase)) or (msm_s0x15 and not(flash_busy or flash_timeout or flash_error))  or (msm_s0x1C and not(flash_busy or flash_timeout or flash_error)) or msm_s0x17 or msm_s0x30) and not(msm_rst);
    msm_return <= (msm_s0x0F) and not(msm_rst);
    msm_to_s0x11 <= msm_s0x16 and more2erase and not(msm_rst);
    msm_to_s0x18 <= msm_s0x1D and more2pgm and not(msm_rst);
    msm_to_s0x31 <= msm_s0x32 and more2read and not(msm_rst);
    msm_to_s0x14 <= msm_s0x15 and flash_busy and not(flash_error or flash_timeout) and not(msm_rst);
    msm_to_s0x2E <= (msm_s0x1D and not(more2pgm)) and not(msm_rst);
    msm_to_s0x3E <= (msm_s0x32 and not(more2read)) and not(msm_rst);
    msm_to_s0x2F <= ((msm_s0x15 and (flash_error or flash_timeout)) or (msm_s0x1C and (flash_error or flash_timeout))) and not(msm_rst);
    msm_to_s0x1B <= msm_s0x1C and flash_busy and not(flash_error or flash_timeout) and not(msm_rst);

    -----------------------------

    ---- Next State ----
    main_sm_p1 <=  std_logic_vector(unsigned(main_sm) + 1) ;
    main_sm_nxt <= gate_and(msm_p1,main_sm_p1) or
                    gate_and(msm_to_s0x0F,"001111") or
                    gate_and(msm_to_s0x11,"010001") or
                    gate_and(msm_to_s0x14,"010100") or
                    gate_and(msm_to_s0x18,"011000") or
                    gate_and(msm_to_s0x1B,"011011") or
                    gate_and(msm_to_s0x2E,"101110") or
                    gate_and(msm_to_s0x3E,"111110") or
                    gate_and(msm_to_s0x2F,"101111") or
                    gate_and(msm_to_s0x31,"110001") or
                    gate_and(msm_return,msm_returnstate) or
                    gate_and(msm_rst,"000000");
    main_sm_adv <= (not(pgm_rd_req) or (msm_s0x00 and pgm_rd_req) or (msm_s0x0F and dsm_s0x08 and drain_sm_adv)  or (msm_s0x1A and txfifo_has_256B) or (msm_s0x31 and rxfifo_rec_256B)
                   or not(msm_s0x00 or msm_s0x0F or msm_s0x1A or msm_s0x2E or msm_s0x2F or msm_s0x31 or msm_s0x3E));

    dff_main_sm: capi_en_rise_vdff GENERIC MAP ( width => 6 ) PORT MAP (
         dout => main_sm,
         en => main_sm_adv,
         din => main_sm_nxt,
         clk   => psl_clk
    );

    msm_return_p1 <= msm_s0x02 or msm_s0x03 or msm_s0x11 or msm_s0x12 or msm_s0x13 or msm_s0x14 or msm_s0x18 or msm_s0x19 or msm_s0x1A or msm_s0x1B or msm_s0x31;
    msm_return_pgm <= msm_s0x04 and f_program_req and not(f_read_req);
    msm_return_read <= msm_s0x04 and f_read_req;
    msm_returnstate_update <= msm_s0x02 or msm_s0x03 or msm_s0x04 or msm_s0x05 or msm_s0x11 or msm_s0x12 or msm_s0x13 or msm_s0x14 or msm_s0x18 or msm_s0x19 or msm_s0x1A or msm_s0x1B or msm_s0x31;
    msm_returnstate_d <= gate_and(msm_return_p1,main_sm_p1) or
                       gate_and(msm_return_pgm,"010000") or
                       gate_and(msm_return_read,"110000");--Move on from state 4 and skip quad mode for now

    dff_msm_returnstate: capi_en_rise_vdff GENERIC MAP ( width => 6 ) PORT MAP (
         dout => msm_returnstate,
         en => msm_returnstate_update,
         din => msm_returnstate_d,
         clk   => psl_clk
    );
--Main State machine decodes
    msm_s0x00 <= '1' when (main_sm  =  "000000") else '0';     -- 0x00  --
    msm_s0x01 <= '1' when (main_sm  =  "000001") else '0';     -- 0x01  --
    msm_s0x02 <= '1' when (main_sm  =  "000010") else '0' ;     -- 0x02  --
    msm_s0x03 <= '1' when (main_sm  =  "000011") else '0' ;     -- 0x03  --
    msm_s0x04 <= '1' when (main_sm  =  "000100") else '0' ;     -- 0x04  --
    msm_s0x05 <= '1' when (main_sm  =  "000101") else '0' ;     -- 0x05  --
    msm_s0x0F <= '1' when (main_sm  =  "001111") else '0' ;     -- 0x0F  --
    msm_s0x10 <= '1' when (main_sm  =  "010000") else '0' ;     -- 0x10  --
    msm_s0x11 <= '1' when (main_sm  =  "010001") else '0' ;     -- 0x11  --
    msm_s0x12 <= '1' when (main_sm  =  "010010") else '0' ;     -- 0x12  --
    msm_s0x13 <= '1' when (main_sm  =  "010011") else '0' ;     -- 0x13  --
    msm_s0x14 <= '1' when (main_sm  =  "010100") else '0' ;     -- 0x14  --
    msm_s0x15 <= '1' when (main_sm  =  "010101") else '0' ;     -- 0x15  --
    msm_s0x16 <= '1' when (main_sm  =  "010110") else '0' ;     -- 0x16  --
    msm_s0x17 <= '1' when (main_sm  =  "010111") else '0' ;     -- 0x17  --
    msm_s0x18 <= '1' when (main_sm  =  "011000") else '0' ;     -- 0x18  --
    msm_s0x19 <= '1' when (main_sm  =  "011001") else '0' ;     -- 0x19  --
    msm_s0x1A <= '1' when (main_sm  =  "011010") else '0' ;     -- 0x1A  --
    msm_s0x1B <= '1' when (main_sm  =  "011011") else '0' ;     -- 0x1B  --
    msm_s0x1C <= '1' when (main_sm  =  "011100") else '0' ;     -- 0x1C  --
    msm_s0x1D <= '1' when (main_sm  =  "011101") else '0' ;     -- 0x1D  --
    msm_s0x2E <= '1' when (main_sm  =  "101110") else '0' ;     -- 0x2E  --
    msm_s0x2F <= '1' when (main_sm  =  "101111") else '0' ;     -- 0x2F  --
    msm_s0x30 <= '1' when (main_sm  =  "110000") else '0' ;     -- 0x30  --
    msm_s0x31 <= '1' when (main_sm  =  "110001") else '0' ;     -- 0x31  --
    msm_s0x32 <= '1' when (main_sm  =  "110010") else '0' ;     -- 0x32  --
    msm_s0x3E <= '1' when (main_sm  =  "111110") else '0' ;     -- 0x3E  --

   f_stat_erase_d <= '1' when ((msm_s0x00 = '1') and (f_program_req = '1')) else '0';
   f_stat_pgm_d <= '1' when ((msm_s0x00 = '1') and (f_program_req = '1')) else '0';
   f_stat_read_d <= '1' when ((msm_s0x00 = '1') and (f_read_req = '1')) else '0';
   f_stat_erase_update <= msm_s0x00 or msm_s0x17;
   f_stat_pgm_update <= msm_s0x00 or msm_s0x2E;
   f_stat_read_update <= msm_s0x00 or msm_s0x3E;
   dff_f_stat_erase: capi_en_rise_dff PORT MAP (
         dout => f_stat_erase,
         en => f_stat_erase_update,
         din => f_stat_erase_d,
         clk   => psl_clk
    );
   dff_f_stat_pgm: capi_en_rise_dff PORT MAP (
         dout => f_stat_program,
         en => f_stat_pgm_update,
         din => f_stat_pgm_d,
         clk   => psl_clk
    );
   dff_f_stat_read: capi_en_rise_dff PORT MAP (
         dout => f_stat_read,
         en => f_stat_read_update,
         din => f_stat_read_d,
         clk   => psl_clk
    );

 -- -- End Section -- --

 -- ----------------------------------- --
 -- Cycle Timer                         --
 -- ----------------------------------- --

    start_dly <= '1' when ((drain_sm_nxt = "0011") or (drain_sm_nxt = "0101") or (drain_sm_nxt = "0111")) else '0';
    new_dly <= "0000000000000000";
    cycdly_m1 <= std_logic_vector(unsigned(cycdly_q) + 1);

    cycdly_d <= new_dly when (start_dly ='1') else cycdly_m1;
    cnt_en <= '1' ;
    endff_cycdly_q: capi_en_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => cycdly_q,
         en => cnt_en,
         din => cycdly_d,
         clk   => psl_clk
    );

    dly_done <= '1' when (cycdly_q = "0000010000010100") else '0';

 -- -- End Section -- --

 -- ----------------------------------- --
 -- Command Constants                   --
 -- ----------------------------------- --

qspi_rst_en <= X"66";--Command only
qspi_rst_mem <= X"99";--Command only
qspi_enter_4B_addr <= X"B7";--Command Only
qspi_enter_quad_mode <= X"35";--Command Only
qspi_we <= X"06";--Command only
qspi_4B_read <= X"13";--Com-Adr-Data--
qspi_fstatus_read <= X"70";--Command then Data--
qspi_fstatus_clear <= X"50";--Command Only
qspi_4B_page_pgm <= X"12";--Com-Adr-Data--
qspi_sector_erase <= X"D8";--Command then Address


 -- ----------------------------------- --
 -- Main SM Outputs                     --
 -- ----------------------------------- --
    frstn <=  not (main_sm(2)  or  main_sm(5)) ;

    program_flash <= main_sm(4)  and  f_program_req ;
    read_flash <= main_sm(4)  and  f_read_req ;

    init_cnt_adr <= main_sm(0) ;

    f_ready <= msm_s0x00;
    f_done <= msm_s0x2E or msm_s0x2F or msm_s0x3E;
 -- -- End Section -- --

--============================================================================================
---- Settings per command or as a result of issuing certain commands
--==============================================================================================--

     --TODO: Support quad mode reads/writes?
     quad_mode_update <= msm_s0x01 or msm_s0x05;
     quad_mode_d <= '1' when (msm_s0x05 = '1') else '0';
     endff_quad_mode_q: capi_en_rise_dff PORT MAP (
         dout => quad_mode,
         en => quad_mode_update,
         din => quad_mode_d,
         clk   => psl_clk
    );

     fourB_address_mode_update <= msm_s0x01 or msm_s0x04;
     fourB_address_mode_d <= '1' when (msm_s0x04 = '1') else '0';
     endff_fourB_address_mode_q: capi_en_rise_dff PORT MAP (
         dout => fourB_address_mode,
         en => fourB_address_mode_update,
         din => fourB_address_mode_d,
         clk   => psl_clk
    );

     command_sent <= '1';

     address_sent_update <= msm_s0x02 or msm_s0x03 or msm_s0x04 or msm_s0x05 or msm_s0x11 or msm_s0x12 or msm_s0x13 or msm_s0x14 or msm_s0x18 or msm_s0x19 or msm_s0x1A or msm_s0x1B or msm_s0x31;
     address_sent_d <= '1' when ((msm_s0x13 = '1') or (msm_s0x1A = '1') or (msm_s0x31 = '1')) else '0';
     endff_address_sent_q: capi_en_rise_dff PORT MAP (
         dout =>address_sent,
         en => address_sent_update,
         din => address_sent_d,
         clk   => psl_clk
    );

     data_sent_update <= msm_s0x02 or msm_s0x03 or msm_s0x04 or msm_s0x05 or msm_s0x11 or msm_s0x12 or msm_s0x13 or msm_s0x14 or msm_s0x18 or msm_s0x19 or msm_s0x1A or msm_s0x1B or msm_s0x31;
     data_sent_d <= '1' when ((msm_s0x14 = '1') or (msm_s0x1A = '1') or (msm_s0x1B = '1') or (msm_s0x31 = '1')) else '0';
     endff_data_sent_q: capi_en_rise_dff PORT MAP (
         dout =>data_sent,
         en => data_sent_update,
         din => data_sent_d,
         clk   => psl_clk
    );

    start_address_update <= msm_s0x01;
    start_address_d <= f_read_start_addr & "000000";
    endff_start_address_q: capi_en_rise_vdff GENERIC MAP ( width => 32 ) PORT MAP (
         dout => start_address,
         en => start_address_update,
         din => start_address_d,
         clk   => psl_clk
    );

    start_sectors_update <= msm_s0x01;
    start_sectors_d <= f_num_blocks; --Size in 64KB sectors
    endff_start_size_q: capi_en_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => start_sectors,
         en => start_sectors_update,
         din => start_sectors_d,
         clk   => psl_clk
    );

    command_update <= msm_to_s0x0F;
    command_d <= gate_and(msm_s0x02, qspi_rst_en) or
                 gate_and(msm_s0x03, qspi_rst_mem) or
                 gate_and(msm_s0x04, qspi_enter_4B_addr) or
                 gate_and(msm_s0x05, qspi_enter_quad_mode) or
                 gate_and(msm_s0x11 or msm_s0x18, qspi_fstatus_clear) or
                 gate_and(msm_s0x12 or msm_s0x19, qspi_we) or
                 gate_and(msm_s0x14 or msm_s0x1B, qspi_fstatus_read) or
                 gate_and(msm_s0x31, qspi_4B_read) or
                 gate_and(msm_s0x1A, qspi_4B_page_pgm) or
                 gate_and(msm_s0x13, qspi_sector_erase);
    endff_command_q: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => command,
         en => command_update,
         din => command_d,
         clk   => psl_clk
    );

    read_speed_d <= '1' when ((msm_s0x14 = '1') or (msm_s0x1B = '1') or (msm_s0x31 = '1')) else '0';
    read_speed_update <= msm_to_s0x0F;
    endff_read_speed_q: capi_en_rise_dff PORT MAP (
         dout => read_speed,
         en => read_speed_update,
         din => read_speed_d,
         clk   => psl_clk
    );

--============================================================================================
---- Address and Job size tracking
--==============================================================================================--

 -- ----------------------------------- --
 -- Block Address                       --
 -- ----------------------------------- --

    esm_blkadr_p1 <= std_logic_vector(unsigned(esm_blkadr_q) + 1) ;

    esm_blkadr_d <= start_address(0 to 9) when msm_s0x10='1' else esm_blkadr_p1;

    --bool esm_update_blkadr = (init_cnt_adr | esm_s0x11);--
    msm_update_blkadr <= (msm_s0x10 or msm_s0x16) ;

    endff_esm_blkadr_q: capi_en_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => esm_blkadr_q,
         en => msm_update_blkadr,
         din => esm_blkadr_d,
         clk   => psl_clk
    );
    endff_msm_update_blkadr_q: capi_rise_dff PORT MAP (
         dout => msm_update_blkadr_q,
         din => msm_update_blkadr,
         clk   => psl_clk
    );

    esm_blkadr <= "000000" & esm_blkadr_q & "0000000000000000";
 -- -- End Section -- --

 -- ----------------------------------- --
 -- 256B Write/Read Address                       --
 -- ----------------------------------- --

    msm_byteadr_p1 <=std_logic_vector(unsigned(msm_byteadr_q) + 1) ;

    msm_byteadr_d <= (start_address(0 to 17)) when ((msm_s0x30='1') or (msm_s0x17='1')) else msm_byteadr_p1;

    --bool esm_update_blkadr = (init_cnt_adr | esm_s0x11);--
    msm_update_byteadr <= (msm_s0x17 or msm_s0x1D or msm_s0x30 or msm_s0x32) ;

    endff_msm_byteadr_q: capi_en_rise_vdff GENERIC MAP ( width => 18 ) PORT MAP (
         dout => msm_byteadr_q,
         en => msm_update_byteadr,
         din => msm_byteadr_d,
         clk   => psl_clk
    );
    endff_msm_update_byteadr_q: capi_rise_dff PORT MAP (
         dout => msm_update_byteadr_q,
         din => msm_update_byteadr,
         clk   => psl_clk
    );

    msm_byteadr <= "000000" & msm_byteadr_q & "00000000";

    address_d <= esm_blkadr when (msm_update_blkadr_q = '1') else
               msm_byteadr when (msm_update_byteadr_q = '1') else
               address;
    dff_address_q: capi_rise_vdff GENERIC MAP ( width => 32 ) PORT MAP (
         dout => address,
         din => address_d,
         clk   => psl_clk
    );

 -- ----------------------------------- --
 -- Count of Blocks to Erase            --
 -- ----------------------------------- --
    esm_blkcnt_m1 <= std_logic_vector(unsigned(esm_blkcnt_q) - 1) ;

    esm_blkcnt_d <= start_sectors when msm_s0x10='1' else esm_blkcnt_m1;


    esm_update_blkcnt <= msm_s0x10 or msm_s0x16 ;

    endff_esm_blkcnt_q: capi_en_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => esm_blkcnt_q,
         en => esm_update_blkcnt,
         din => esm_blkcnt_d,
         clk   => psl_clk
    );

    more2erase <= or_reduce(esm_blkcnt_q);

 -- ----------------------------------- --
 -- Count of 256B Writes/Reads            --
 -- ----------------------------------- --
    msm_bytecnt_m1 <= std_logic_vector(unsigned(msm_bytecnt_q) - 1) ;
    --msm_bytecnt_m1 <= msm_bytecnt_q - msm_bytecnt_q; --SIMONLY!! for lab use above line

    msm_bytecnt_d <= (start_sectors & "00000000")  when ((msm_s0x17='1') or (msm_s0x30='1')) else msm_bytecnt_m1;


    msm_update_bytecnt <= msm_s0x17 or msm_s0x1D or msm_s0x30 or msm_s0x32;

    endff_msm_bytecnt_q: capi_en_rise_vdff GENERIC MAP ( width => 18 ) PORT MAP (
         dout => msm_bytecnt_q,
         en => msm_update_bytecnt,
         din => msm_bytecnt_d,
         clk   => psl_clk
    );
    msm_bytecnt <= msm_bytecnt_q;

    more2pgm <= or_reduce(msm_bytecnt_q);
    more2read <= or_reduce(msm_bytecnt_q);

 -- -- End Section -- --

 -- ----------------------------------- --
 -- State 0x0F -- Com/Adr/Data Flush    --
 -- ----------------------------------- --

--============================================================================================
---- Command/Address/Data Drain State
--==============================================================================================--
    ---- Nxt State always 0 if neither f_program_req or f_read_req set
    ---- State 00  : IDLE                                           ----
    ----            Nxt State 1                              ----
    ---- State 01  : Target Command Byte                                           ----
    ----            Nxt State 2
    ---- State 02  : Pulse Chip Select to active                    ----
    ----            Nxt State 3
    ---- State 03  : Drain Command Byte at appropriate clock speed                                   ----
    ----            Nxt State 4 if address to be sent
    ----            Nxt State 6 if no address but data to send
    ----            Nxt State 8 if no address or data to send
    ---- State 04  : Target Address Byte                                        ----
    ----            Nxt State 5
    ---- State 05  : Drain Address Byte                                           ----
    ----            Nxt State 4 if more address bytes
    ----            Nxt State 6 if no more address and data to send
    ----            Nxt State 8 if no more address and no data to send
    ---- State 06  : Target Data Byte            ----
    ----            Nxt State 7
    ---- State 07  : Drain Data Byte            ----
    ----            Nxt State 6 if more data bytes
    ----            Nxt State 8 if no more data to send
    ---- State 08  : Deactivate chip select. indicate xfer complete            ----

 -- ----------------------------------- --
 -- Next State Equations and SM Latch   --
 -- ----------------------------------- --

    ---- Next State Controls ----
    dsm_rst <= not(msm_s0x0F) ;    -- Reset State Machine when program is complete --
    dsm_p1 <= (dsm_s0x00 or dsm_s0x01 or dsm_s0x02 or (dsm_s0x03 and address_sent) or dsm_s0x04  or (dsm_s0x05 and data_sent and address_done) or dsm_s0x06  or (dsm_s0x07 and data_done)) and not(dsm_rst);
    dsm_m1 <= ((dsm_s0x05 and not(address_done)) or (dsm_s0x07 and not(data_done))) and not(dsm_rst);
    dsm_to_s0x06 <= (dsm_s0x03 and not(address_sent) and data_sent) and not(dsm_rst);
    dsm_to_s0x08 <= ((dsm_s0x03 and not(address_sent) and not(data_sent)) or (dsm_s0x05 and address_done and not(data_sent))) and not(dsm_rst);
    -----------------------------

    ---- Next State ----
    drain_sm_p1 <= std_logic_vector(unsigned(drain_sm) + 1) ;
    drain_sm_m1 <= std_logic_vector(unsigned(drain_sm) - 1) ;
    drain_sm_nxt <= gate_and(dsm_p1,drain_sm_p1) or
                    gate_and(dsm_m1,drain_sm_m1) or
                    gate_and(dsm_to_s0x06,"0110") or
                    gate_and(dsm_to_s0x08,"1000") or
                    gate_and(dsm_rst,"0000");
    drain_sm_adv <= (not(dsm_s0x03) and not(dsm_s0x05) and not(dsm_s0x07) and not(dsm_s0x02) and not(dsm_s0x08))  or (clk_exhausted_qqq and clk_exhausted and clk_exhausted_q and clk_exhausted_qq and (dsm_s0x03 or dsm_s0x05 or dsm_s0x07)) or ((dsm_s0x02 or dsm_s0x08) and cs_counterdone);

    dff_drain_sm: capi_en_rise_vdff GENERIC MAP ( width => 4 ) PORT MAP (
         dout => drain_sm,
         en => drain_sm_adv,
         din => drain_sm_nxt,
         clk   => psl_clk
    );

--Drain State machine decodes
    dsm_s0x00 <= '1' when (drain_sm  =  "0000") else '0';     -- 0x00  --
    dsm_s0x01 <= '1' when (drain_sm  =  "0001") else '0';     -- 0x01  --
    dsm_s0x02 <= '1' when (drain_sm  =  "0010") else '0';     -- 0x02  --
    dsm_s0x03 <= '1' when (drain_sm  =  "0011") else '0';     -- 0x03  --
    dsm_s0x04 <= '1' when (drain_sm  =  "0100") else '0';     -- 0x04  --
    dsm_s0x05 <= '1' when (drain_sm  =  "0101") else '0';     -- 0x05  --
    dsm_s0x06 <= '1' when (drain_sm  =  "0110") else '0';     -- 0x06  --
    dsm_s0x07 <= '1' when (drain_sm  =  "0111") else '0';     -- 0x07  --
    dsm_s0x08 <= '1' when (drain_sm  =  "1000") else '0';     -- 0x08  --


    cs_counter_d <= "0000" when ((dsm_s0x02 = '0') and (dsm_s0x08 = '0')) else std_logic_vector(unsigned(cs_counter) + 1);
    dff_cs_counter: capi_rise_vdff GENERIC MAP ( width => 4 ) PORT MAP (
         dout => cs_counter,
         din => cs_counter_d,
         clk   => psl_clk
    );
    cs_counterdone <= '1' when (cs_counter = "1111") else '0';

    --Flash memory flag status register
    flag_status_update <= '1' when ((dsm_s0x08 = '1') and (drain_sm_adv = '1') and (command = qspi_fstatus_read)) else '0';
    flag_status_d <= in_byte;
    dff_flag_status: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => flag_status,
         en => flag_status_update,
         din => flag_status_d,
         clk   => psl_clk
    );

 -- ----------------------------------- --
 -- Byte Select                 --
 -- ----------------------------------- --

byte_d <= command when (dsm_s0x01 = '1') else
          address(0 to 7) when ((dsm_s0x04 = '1') and (address_bytepos = "00")) else
          address(8 to 15) when ((dsm_s0x04 = '1') and (address_bytepos = "01")) else
          address(16 to 23) when ((dsm_s0x04 = '1') and (address_bytepos = "10")) else
          address(24 to 31) when ((dsm_s0x04 = '1') and (address_bytepos = "11")) else
          data;
byte_update <= dsm_s0x01 or dsm_s0x04 or dsm_s0x06;

    dff_byte: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => byte,
         en => byte_update,
         din => byte_d,
         clk   => psl_clk
    );

address_bytepos_d <= "00" when (msm_to_s0x0F = '1') and (fourB_address_mode = '1') else
                     "01" when (msm_to_s0x0F = '1') and (fourB_address_mode = '0') else
                     std_logic_vector(unsigned(address_bytepos) + 1) when ((dsm_s0x05 = '1') and (drain_sm_adv = '1')) else
                     address_bytepos;

    dff_address_bytepos: capi_rise_vdff GENERIC MAP ( width => 2 ) PORT MAP (
         dout => address_bytepos,
         din => address_bytepos_d,
         clk   => psl_clk
    );

address_done <= '1' when (dsm_s0x05 = '1' and (address_bytepos = "11")) else
                '0';

    total_dbytes_d <= "11111111" when ((msm_s0x1A = '1') or (msm_s0x31 = '1')) else
                      std_logic_vector(unsigned(total_dbytes) - 1) when (dsm_s0x07 = '1') else
                     "00000000";
    total_dbytes_update <= msm_s0x1A or msm_s0x31 or msm_s0x14 or msm_s0x1B or (dsm_s0x07 and drain_sm_adv);
    endff_total_dbytes_q: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => total_dbytes,
         en => total_dbytes_update,
         din => total_dbytes_d,
         clk   => psl_clk
    );

data_done <= not(or_reduce(total_dbytes));
 -- ----------------------------------- --
 -- Bit(s) Select and data out                --
 -- ----------------------------------- --
-- TODO: Add quad mode support.

bit_pointer_d <= "111" when (dsm_s0x00 = '1') else
                 std_logic_vector(unsigned(bit_pointer) + 1) when ((spi_clk_d = '0') and (spi_clk_q = '1')) else
                 bit_pointer;
    dff_bit_pointer: capi_rise_vdff GENERIC MAP ( width => 3 ) PORT MAP (
         dout => bit_pointer,
         din => bit_pointer_d,
         clk   => psl_clk
    );

spi_mosi_d <= byte(0) when (bit_pointer_d = "000") else
              byte(1) when (bit_pointer_d = "001") else
              byte(2) when (bit_pointer_d = "010") else
              byte(3) when (bit_pointer_d = "011") else
              byte(4) when (bit_pointer_d = "100") else
              byte(5) when (bit_pointer_d = "101") else
              byte(6) when (bit_pointer_d = "110") else
              byte(7);

    dff_spi_mosi_q: capi_rise_dff PORT MAP (
         dout => spi_mosi_q,
         din => spi_mosi_d,
         clk   => psl_clk
    );

    dff_spi_mosi: capi_rise_dff PORT MAP (
         dout => spi_mosi,
         din => spi_mosi_q,
         clk   => psl_clk
    );

   xfer_count_d <= "0000" when ((dsm_s0x03 = '0') and (dsm_s0x05 = '0') and (dsm_s0x07 = '0')) else
                   std_logic_vector(unsigned(xfer_count) + 1) when ((spi_clk_d = '1') and (spi_clk_q = '0')) else
                   xfer_count;
    dff_xfer_count: capi_rise_vdff GENERIC MAP ( width => 4 ) PORT MAP (
         dout => xfer_count,
         din => xfer_count_d,
         clk   => psl_clk
    );

   byte_xfer_complete <= '1' when (xfer_count = "1000") else
                         '0';

    dff_spi_miso: capi_rise_dff PORT MAP (
         dout => spi_miso_q,
         din => spi_miso,
         clk   => psl_clk
    );

in_byte_d <= spi_miso & spi_miso & spi_miso & spi_miso & spi_miso & spi_miso & spi_miso & spi_miso;
in_byte_update(0) <= '1' when ((spi_clk_qq = '0') and (spi_clk_int = '1') and (dsm_s0x07 = '1') and (bit_pointer = "000")) else '0';
in_byte_update(1) <= '1' when ((spi_clk_qq = '0') and (spi_clk_int = '1') and (dsm_s0x07 = '1') and bit_pointer = "001") else '0';
in_byte_update(2) <= '1' when ((spi_clk_qq = '0') and (spi_clk_int = '1') and (dsm_s0x07 = '1') and bit_pointer = "010") else '0';
in_byte_update(3) <= '1' when ((spi_clk_qq = '0') and (spi_clk_int = '1') and (dsm_s0x07 = '1') and bit_pointer = "011") else '0';
in_byte_update(4) <= '1' when ((spi_clk_qq = '0') and (spi_clk_int = '1') and (dsm_s0x07 = '1') and bit_pointer = "100") else '0';
in_byte_update(5) <= '1' when ((spi_clk_qq = '0') and (spi_clk_int = '1') and (dsm_s0x07 = '1') and bit_pointer = "101") else '0';
in_byte_update(6) <= '1' when ((spi_clk_qq = '0') and (spi_clk_int = '1') and (dsm_s0x07 = '1') and bit_pointer = "110") else '0';
in_byte_update(7) <= '1' when ((spi_clk_qq = '0') and (spi_clk_int = '1') and ((dsm_s0x07 = '1') or (dsm_s0x06 = '1') or (dsm_s0x08 = '1')) and bit_pointer = "111") else '0';

    dff_in_byte_0: capi_en_rise_dff PORT MAP (
         dout => in_byte(0),
         en => in_byte_update(0),
         din => in_byte_d(0),
         clk   => psl_clk
    );
    dff_in_byte_1: capi_en_rise_dff PORT MAP (
         dout => in_byte(1),
         en => in_byte_update(1),
         din => in_byte_d(1),
         clk   => psl_clk
    );
    dff_in_byte_2: capi_en_rise_dff PORT MAP (
         dout => in_byte(2),
         en => in_byte_update(2),
         din => in_byte_d(2),
         clk   => psl_clk
    );
    dff_in_byte_3: capi_en_rise_dff PORT MAP (
         dout => in_byte(3),
         en => in_byte_update(3),
         din => in_byte_d(3),
         clk   => psl_clk
    );
    dff_in_byte_4: capi_en_rise_dff PORT MAP (
         dout => in_byte(4),
         en => in_byte_update(4),
         din => in_byte_d(4),
         clk   => psl_clk
    );
    dff_in_byte_5: capi_en_rise_dff PORT MAP (
         dout => in_byte(5),
         en => in_byte_update(5),
         din => in_byte_d(5),
         clk   => psl_clk
    );
    dff_in_byte_6: capi_en_rise_dff PORT MAP (
         dout => in_byte(6),
         en => in_byte_update(6),
         din => in_byte_d(6),
         clk   => psl_clk
    );
    dff_in_byte_7: capi_en_rise_dff PORT MAP (
         dout => in_byte(7),
         en => in_byte_update(7),
         din => in_byte_d(7),
         clk   => psl_clk
    );
 -- ----------------------------------- --
 -- Drive Outputs                 --
 -- ----------------------------------- --

    --Must Generate SPI Clock with proper phase to data, polarity, and frequency
    --PSL Clock is 250 MHz. STR write commands can be 133MHz, do a div 2 125MHz clock will work for writes
    -- STR reads max freq is 66MHz, so a div 4 62.5MHz clock will work for reads
    -- For polarity, clock should init to 1
    -- For phase, the qspi samples on rising edge, so data should be supplied on falling edge
    rst_clk_pulses <= '1' when (((drain_sm_nxt = "0011") or (drain_sm_nxt = "0101") or (drain_sm_nxt = "0111")) and (drain_sm_adv = '1')) else '0';
    clk_pulses_d <= "1000" when (rst_clk_pulses = '1') else
                    std_logic_vector(unsigned(clk_pulses) - 1) when ((spi_clk_d = '1') and (spi_clk_q = '0')) else
                    clk_pulses;
    dff_clk_pulses: capi_rise_vdff GENERIC MAP ( width => 4 ) PORT MAP (
         dout => clk_pulses,
         din => clk_pulses_d,
         clk   => psl_clk
    );

    clk_exhausted <= not(or_reduce(clk_pulses));
    dff_clk_exhausted_q: capi_rise_dff PORT MAP (
         dout => clk_exhausted_q,
         din => clk_exhausted,
         clk   => psl_clk
    );
    dff_clk_exhausted_qq: capi_rise_dff PORT MAP (
         dout => clk_exhausted_qq,
         din => clk_exhausted_q,
         clk   => psl_clk
    );
    dff_clk_exhausted_qqq: capi_rise_dff PORT MAP (
         dout => clk_exhausted_qqq,
         din => clk_exhausted_qq,
         clk   => psl_clk
    );
    dff_clk_exhausted_qqqq: capi_rise_dff PORT MAP (
         dout => clk_exhausted_qqqq,
         din => clk_exhausted_qqq,
         clk   => psl_clk
    );

    run_spi_clk <= dsm_s0x03 or dsm_s0x05 or dsm_s0x07;
    spi_clk_tristate_n <= '0';
    spi_clk_d <= '1' when (run_spi_clk = '0') else
                  not(spi_clk_q) when ((read_speed = '0') and (cycdly_q(15) = '0') and (clk_exhausted = '0')) else
                  not(spi_clk_q) when ((read_speed = '1') and (cycdly_q(14) = '0') and (cycdly_q(15) = '0') and  (clk_exhausted = '0')) else
                  spi_clk_q;
    dff_spi_clk_q: capi_rise_dff_init1 PORT MAP (
         dout => spi_clk_q,
         din => spi_clk_d,
         clk   => psl_clk
    );

    dff_spi_clk: capi_rise_dff_init1 PORT MAP (
         dout => spi_clk_int,
         din => spi_clk_q,
         clk   => psl_clk
    );
    dff_spi_clk_qq: capi_rise_dff_init1 PORT MAP (
         dout => spi_clk_qq,
         din => spi_clk_int,
         clk   => psl_clk
    );
    spi_clk <= spi_clk_int;

    --Chip Select
    spi_cs_d <= '0' when ((dsm_s0x02 = '1') or (dsm_s0x03 = '1') or (dsm_s0x04 = '1') or
                    (dsm_s0x05 = '1') or (dsm_s0x06 = '1') or (dsm_s0x07 = '1')) else
                '1';

    dff_spi_cs_q: capi_rise_dff_init1 PORT MAP (
         dout => spi_cs_q,
         din => spi_cs_d,
         clk   => psl_clk
    );

    dff_spi_cs: capi_rise_dff_init1 PORT MAP (
         dout => spi_cen,
         din => spi_cs_q,
         clk   => psl_clk
    );

 -- -- End Section -- --

 -- ----------------------------------- --
 -- Write FIFO                  --
 -- ----------------------------------- --

    fifo_reset <= msm_s0x00;
    --Fifo write Side
    pgm_fifo_push <= (not(pgm_fifo_full) and f_program_data_val);
    pgm_data_mux_d <= "00" when (msm_s0x01 = '1') else (std_logic_vector(unsigned(pgm_data_mux_q) + 1));
    pgm_data_mux_en <= pgm_fifo_push or msm_s0x01;
    dff_program_data_mux: capi_en_rise_vdff GENERIC MAP ( width => 2 ) PORT MAP (
         dout => pgm_data_mux_q,
         en =>  pgm_data_mux_en,
         din => pgm_data_mux_d,
         clk   => psl_clk
    );
    pgm_fifo_wrdata <= f_program_data(24 to 31) when (pgm_data_mux_q = "00") else
                       f_program_data(16 to 23) when (pgm_data_mux_q = "01") else
                       f_program_data(8 to 15) when (pgm_data_mux_q = "10") else
                       f_program_data(0 to 7);

    f_program_data_ack <= '1' when ((pgm_fifo_push = '1') and (pgm_data_mux_q = "11")) else '0';
    pgm_data_fifo: ENTITY work.capi_fifo
      GENERIC MAP (DATA_WIDTH => 8,
                   ADDR_WIDTH => 9
      )
      PORT MAP (
        clk => psl_clk,
        reset => fifo_reset,
        push => pgm_fifo_push,
        wrdata => pgm_fifo_wrdata,
        pull => pgm_fifo_pull,
        rddata => pgm_fifo_rddata,
        empty => pgm_fifo_empty,
        full => pgm_fifo_full
      );

    --Entry Count
    pgm_fifo_cnt_d <= "0000000000" when (msm_s0x00 = '1') else
                     std_logic_vector(unsigned(pgm_fifo_cnt) + 1) when ((pgm_fifo_push = '1') and (pgm_fifo_pull = '0')) else
                     std_logic_vector(unsigned(pgm_fifo_cnt) - 1) when ((pgm_fifo_push = '0') and (pgm_fifo_pull = '1')) else
                     pgm_fifo_cnt;
    dff_pgm_fifo_cnt: capi_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => pgm_fifo_cnt,
         din => pgm_fifo_cnt_d,
         clk   => psl_clk
    );
    txfifo_has_256B <= or_reduce(pgm_fifo_cnt(0 to 1));

      --Fifo read side

     pgm_fifo_pull <= dsm_s0x06 and not(read_speed) and not(pgm_fifo_empty);
     data <= pgm_fifo_rddata;
 -- ----------------------------------- --
 -- Read FIFO                  --
 -- ----------------------------------- --

   --Fifo write side
   rd_fifo_push <= '1' when ((clk_exhausted = '1') and (clk_exhausted_q = '1') and (clk_exhausted_qq = '1') and (clk_exhausted_qqq = '1') and (dsm_s0x07 = '1') and (command = qspi_4B_read) and (rd_fifo_full = '0')) else '0';
   rd_fifo_wrdata <= in_byte;

  read_data_fifo: ENTITY work.capi_fifo
    GENERIC MAP (DATA_WIDTH => 8,
                 ADDR_WIDTH => 9
    )
    PORT MAP (
      clk => psl_clk,
      reset => fifo_reset,
      push => rd_fifo_push,
      wrdata => rd_fifo_wrdata,
      pull => rd_fifo_pull,
      rddata => rd_fifo_rddata,
      empty => rd_fifo_empty,
      full => rd_fifo_full
    );

    --Entry Count
    rd_fifo_cnt_d <= "0000000000" when (msm_s0x00 = '1') else
                     std_logic_vector(unsigned(rd_fifo_cnt) + 1) when ((rd_fifo_push = '1') and (rd_fifo_pull = '0')) else
                     std_logic_vector(unsigned(rd_fifo_cnt) - 1) when ((rd_fifo_push = '0') and (rd_fifo_pull = '1')) else
                     rd_fifo_cnt;
    dff_rd_fifo_cnt: capi_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => rd_fifo_cnt,
         din =>  rd_fifo_cnt_d,
         clk   => psl_clk
    );
    rxfifo_rec_256B <= not(or_reduce(rd_fifo_cnt(0 to 1)));
    rxfifo_has_4B <= or_reduce(rd_fifo_cnt(0 to 7));

    --Fifo read side

    start_4B_xfer_d <= '0' when (f_read_data_ack = '1') else '1';
    start_4B_xfer_en <= (rxfifo_has_4B and not(f_read_data_val_q) and not(rd_fifo_pull)) or f_read_data_ack;
    dff_start_4B_xfer: capi_en_rise_dff PORT MAP (
         dout => start_4B_xfer,
         en  => start_4B_xfer_en,
         din =>  start_4B_xfer_d,
         clk   => psl_clk
    );

    dff_start_4B_xfer_q: capi_rise_dff PORT MAP (
         dout => start_4B_xfer_q,
         din =>  start_4B_xfer,
         clk   => psl_clk
    );

    rd_pull4B <= start_4B_xfer and not (start_4B_xfer_q);
    dff_rd_pull4B_q: capi_rise_dff PORT MAP (
         dout => rd_pull4B_q,
         din =>  rd_pull4B,
         clk   => psl_clk
    );
    dff_rd_pull4B_q2: capi_rise_dff PORT MAP (
         dout => rd_pull4B_q2,
         din =>  rd_pull4B_q,
         clk   => psl_clk
    );
    dff_rd_pull4B_q3: capi_rise_dff PORT MAP (
         dout => rd_pull4B_q3,
         din =>  rd_pull4B_q2,
         clk   => psl_clk
    );
    dff_rd_pull4B_q4: capi_rise_dff PORT MAP (
         dout => rd_pull4B_q4,
         din =>  rd_pull4B_q3,
         clk   => psl_clk
    );
    rd_fifo_pull <= (not(rd_fifo_empty) and (rd_pull4B or rd_pull4B_q or rd_pull4B_q2 or rd_pull4B_q3));
    dff_rd_fifo_pull: capi_rise_dff PORT MAP (
         dout => rd_fifo_pull_q,
         din =>  rd_fifo_pull,
         clk   => psl_clk
    );
    f_read_data_d(0 to 7) <= rd_fifo_rddata when (rd_pull4B_q4 = '1') else f_read_data_q(0 to 7);
    f_read_data_d(8 to 15) <= rd_fifo_rddata when (rd_pull4B_q3 = '1') else f_read_data_q(8 to 15);
    f_read_data_d(16 to 23) <= rd_fifo_rddata when (rd_pull4B_q2 = '1') else f_read_data_q(16 to 23);
    f_read_data_d(24 to 31) <= rd_fifo_rddata when (rd_pull4B_q = '1') else f_read_data_q(24 to 31);
    dff_f_read_data: capi_en_rise_vdff GENERIC MAP ( width => 32 ) PORT MAP (
         dout => f_read_data_q,
         en =>  rd_fifo_pull_q,
         din => f_read_data_d,
         clk   => psl_clk
    );
    f_read_data_val_d <= '0' when ((f_read_data_ack = '1') or (msm_s0x00 = '1')) else '1';
    update_frval <= f_read_data_ack or msm_s0x00 or (rd_pull4B_q4);
    dff_f_read_data_val_q: capi_en_rise_dff PORT MAP (
         dout => f_read_data_val_q,
         en =>  update_frval,
         din => f_read_data_val_d,
         clk   => psl_clk
    );
    f_read_data <= f_read_data_q;
    f_read_data_val <= f_read_data_val_q;

END capi_flash_spi_mt25qt;
