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
use ieee.numeric_std.all;

ENTITY capi_flash IS
  PORT(psl_clk: in std_logic;

       -- --------------- --
       flash_clk: out std_logic;
       flash_rstn: out std_logic;
       flash_addr: out std_logic_vector(25 downto 0);
       flash_dataout: out std_logic_vector(15 downto 0);
       flash_dat_oe: out std_logic;  -- 0: dq output enabled 1: tristate
       flash_datain: in std_logic_vector(15 downto 0);
       flash_cen: out std_logic_vector(0 to 1);
       flash_oen: out std_logic;
       flash_wen: out std_logic;
       flash_wpn: out std_logic;
       flash_advn: out std_logic;
       flash_intf_oe: out std_logic;  -- 0: addr/rst/cen/oen/wen/wpn/advn drive enabled  1: tristate

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
       f_states: out std_logic_vector(0 to 31);
       f_memstat: out std_logic_vector(0 to 15);
       f_memstat_past: out std_logic_vector(0 to 15);

       -- Read Interface --
       f_read_req: in std_logic;
       f_num_words_m1: in std_logic_vector(0 to 9);                         -- N-1 words --
       f_read_start_addr: in std_logic_vector(0 to 25);
       f_read_data: out std_logic_vector(0 to 31);
       f_read_data_val: out std_logic;
       f_read_data_ack: in std_logic);

END capi_flash;



ARCHITECTURE capi_flash OF capi_flash IS

Component capi_en_rise_vdff
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        en    : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_en_rise_vdff;
Component capi_en_rise_dff
  PORT (clk   : in std_logic;
        en    : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_en_rise_dff;

Component capi_rise_dff
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_rise_dff;

Component capi_rise_vdff
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_rise_vdff;

Component capi_rise_dff_init1
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_rise_dff_init1;

Component capi_rise_vdff_init1
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_rise_vdff_init1;

Component capi_reversebus16
  PORT(dest: out std_logic_vector(0 to 15);
       din: in std_logic_vector(0 to 15));
End Component capi_reversebus16;



function gate_and (gate : std_logic; din : std_logic_vector) return std_logic_vector is
begin
  if (gate = '1') then
    return din;
  else
    return (0 to din'length-1 => '0');
  end if;
end gate_and;

Signal Z_v10bit: std_logic_vector(0 to 9);  -- v10bit
Signal Z_v17bit: std_logic_vector(0 to 16);  -- v17bit
Signal Z_v32bit: std_logic_vector(0 to 31);  -- v32bit
Signal Z_v9bit: std_logic_vector(0 to 8);  -- v9bit
Signal buf_dat: std_logic_vector(0 to 31);  -- v32bit
Signal buf_full: std_logic;  -- bool
Signal cnt_en: std_logic;  -- bool
Signal cycdly_d: std_logic_vector(0 to 7);  -- v6bit
Signal cycdly_m1: std_logic_vector(0 to 7);  -- v6bit
Signal cycdly_q: std_logic_vector(0 to 7);  -- v6bit
Signal datain_hien: std_logic;  -- bool
Signal datain_loen: std_logic;  -- bool
Signal dly_done: std_logic;  -- bool

Signal erase_addr: std_logic_vector(0 to 25);  -- v26bit
Signal erase_adr_sel: std_logic;  -- bool
Signal erase_ce: std_logic;  -- bool
Signal erase_complete: std_logic;  -- bool
Signal erase_dat_oe: std_logic;  -- bool
Signal erase_data_out: std_logic_vector(0 to 31);  -- v32bit
Signal erase_dly: std_logic_vector(0 to 7);  -- v6bit
Signal erase_oe: std_logic;  -- bool
Signal erase_sm: std_logic_vector(0 to 5);  -- v5bit
Signal erase_sm_nxt: std_logic_vector(0 to 5);  -- v5bit
Signal erase_sm_p1: std_logic_vector(0 to 5);  -- v5bit
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

Signal esm_s00: std_logic;
Signal esm_s01: std_logic;
Signal esm_s02: std_logic;
Signal esm_s03: std_logic;
Signal esm_s04: std_logic;
Signal esm_s05: std_logic;
Signal esm_s06: std_logic;
Signal esm_s07: std_logic;
Signal esm_s08: std_logic;
Signal esm_s09: std_logic;
Signal esm_s10: std_logic;
Signal esm_s11: std_logic;
Signal esm_s12: std_logic;
Signal esm_s13: std_logic;
Signal esm_s14: std_logic;
Signal esm_s15: std_logic;
Signal esm_s16: std_logic;
Signal esm_s17: std_logic;
Signal esm_s18: std_logic;
Signal esm_s19: std_logic;
Signal esm_s20: std_logic;
Signal esm_s21: std_logic;
Signal esm_s22: std_logic;
Signal esm_s23: std_logic;
Signal esm_s24: std_logic;
Signal esm_s25: std_logic;

Signal esm_nxt_s00: std_logic;
Signal esm_nxt_s01: std_logic;
Signal esm_nxt_s02: std_logic;
Signal esm_nxt_s03: std_logic;
Signal esm_nxt_s04: std_logic;
Signal esm_nxt_s05: std_logic;
Signal esm_nxt_s06: std_logic;
Signal esm_nxt_s07: std_logic;
Signal esm_nxt_s08: std_logic;
Signal esm_nxt_s09: std_logic;
Signal esm_nxt_s10: std_logic;
Signal esm_nxt_s11: std_logic;
Signal esm_nxt_s12: std_logic;
Signal esm_nxt_s13: std_logic;
Signal esm_nxt_s14: std_logic;
Signal esm_nxt_s15: std_logic;
Signal esm_nxt_s16: std_logic;
Signal esm_nxt_s17: std_logic;
Signal esm_nxt_s18: std_logic;
Signal esm_nxt_s19: std_logic;
Signal esm_nxt_s20: std_logic;
Signal esm_nxt_s21: std_logic;
Signal esm_nxt_s22: std_logic;
Signal esm_nxt_s23: std_logic;
Signal esm_nxt_s24: std_logic;
Signal esm_nxt_s25: std_logic;

Signal esm_sel_CEH_dly: std_logic;  -- bool
Signal esm_sel_FTD_dly: std_logic;  -- bool
Signal esm_sel_OEH_dly: std_logic;  -- bool
Signal esm_sel_OEL_dly: std_logic;  -- bool
Signal esm_sel_WEH_dly: std_logic;  -- bool
Signal esm_sel_WEL_dly: std_logic;  -- bool
Signal esm_update_blkadr: std_logic;  -- bool
Signal esm_update_blkcnt: std_logic;  -- bool

Signal faddr: std_logic_vector(25 downto 0);  -- v26bit
Signal faddr_be: std_logic_vector(0 to 25);  -- v26bit
Signal fcen: std_logic_vector(0 to 1);  -- v2bit
Signal fcen_0: std_logic;  -- bool
Signal fcen_1: std_logic;  -- bool
Signal fdatain: std_logic_vector(31 downto 0);  -- v32bit
Signal fdatain_hi: std_logic_vector(15 downto 0);  -- v16bit
Signal fdatain_lo: std_logic_vector(15 downto 0);  -- v16bit
Signal fdataout: std_logic_vector(15 downto 0);  -- v16bit
Signal fdataout_be: std_logic_vector(0 to 31);  -- v32bit
Signal fdataout_be_d: std_logic_vector(0 to 15);  -- v16bit
Signal fdatoe: std_logic;  -- bool
Signal fdatoe_n: std_logic;  -- bool
Signal fgrant_l: std_logic;  -- bool
Signal fgrant_ll: std_logic;  -- bool
Signal fgrant_lll: std_logic;  -- bool
Signal fintf_oe: std_logic;  -- bool
Signal fintf_oe_n: std_logic;  -- bool
Signal flash_busy: std_logic;  -- bool
Signal flash_error: std_logic;  -- bool
Signal foen: std_logic;  -- bool
Signal frstn: std_logic;  -- bool
Signal fwen: std_logic;  -- bool
Signal init_buf_off: std_logic;  -- bool
Signal init_cnt_adr: std_logic;  -- bool
Signal main_dly: std_logic_vector(0 to 7);  -- v6bit
Signal main_sm: std_logic_vector(0 to 7);  -- v8bit
Signal main_sm_nxt: std_logic_vector(0 to 7);  -- v8bit
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
Signal new_dly: std_logic_vector(0 to 7);  -- v6bit
Signal num_buffers: std_logic_vector(0 to 16);  -- v17bit
Signal pflreqn: std_logic;  -- bool
Signal pgm_addr: std_logic_vector(0 to 25);  -- v26bit
Signal pgm_adr_sel: std_logic;  -- bool
Signal pgm_ce: std_logic;  -- bool
Signal pgm_complete: std_logic;  -- bool
Signal pgm_dat_oe: std_logic;  -- bool
Signal pgm_data_out: std_logic_vector(0 to 31);  -- v32bit
Signal pgm_dly: std_logic_vector(0 to 7);  -- v6bit
Signal pgm_oe: std_logic;  -- bool
Signal pgm_rd_req: std_logic;  -- bool
Signal pgm_remainder: std_logic_vector(0 to 9);  -- v10bit
Signal pgm_sm: std_logic_vector(0 to 5);  -- v5bit
Signal pgm_sm_prev: std_logic_vector(0 to 5);  -- v5bit
Signal pgm_sm_nxt: std_logic_vector(0 to 5);  -- v5bit
Signal pgm_sm_p1: std_logic_vector(0 to 5);  -- v5bit
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
Signal psm_rst: std_logic;  -- bool
signal psm_status_dq7_q : std_logic;

Signal psm_s00: std_logic;
Signal psm_s01: std_logic;
Signal psm_s02: std_logic;
Signal psm_s03: std_logic;
Signal psm_s04: std_logic;
Signal psm_s05: std_logic;
Signal psm_s06: std_logic;
Signal psm_s07: std_logic;
Signal psm_s08: std_logic;
Signal psm_s09: std_logic;
Signal psm_s10: std_logic;
Signal psm_s11: std_logic;
Signal psm_s12: std_logic;
Signal psm_s13: std_logic;
Signal psm_s14: std_logic;
Signal psm_s15: std_logic;
Signal psm_s16: std_logic;
Signal psm_s17: std_logic;
Signal psm_s18: std_logic;
Signal psm_s19: std_logic;
Signal psm_s20: std_logic;
Signal psm_s21: std_logic;
Signal psm_s22: std_logic;
Signal psm_s23: std_logic;
Signal psm_s24: std_logic;
Signal psm_s25: std_logic;
Signal psm_s26: std_logic;
Signal psm_s27: std_logic;
Signal psm_s28: std_logic;
Signal psm_s29: std_logic;
Signal psm_s30: std_logic;
Signal psm_s31: std_logic;
Signal psm_s32: std_logic;


Signal psm_nxt_s00: std_logic;
Signal psm_nxt_s01: std_logic;
Signal psm_nxt_s02: std_logic;
Signal psm_nxt_s03: std_logic;
Signal psm_nxt_s04: std_logic;
Signal psm_nxt_s05: std_logic;
Signal psm_nxt_s06: std_logic;
Signal psm_nxt_s07: std_logic;
Signal psm_nxt_s08: std_logic;
Signal psm_nxt_s09: std_logic;
Signal psm_nxt_s10: std_logic;
Signal psm_nxt_s11: std_logic;
Signal psm_nxt_s12: std_logic;
Signal psm_nxt_s13: std_logic;
Signal psm_nxt_s14: std_logic;
Signal psm_nxt_s15: std_logic;
Signal psm_nxt_s16: std_logic;
Signal psm_nxt_s17: std_logic;
Signal psm_nxt_s18: std_logic;
Signal psm_nxt_s19: std_logic;
Signal psm_nxt_s20: std_logic;
Signal psm_nxt_s21: std_logic;
Signal psm_nxt_s22: std_logic;
Signal psm_nxt_s23: std_logic;
Signal psm_nxt_s24: std_logic;
Signal psm_nxt_s25: std_logic;
Signal psm_nxt_s26: std_logic;
Signal psm_nxt_s27: std_logic;
Signal psm_nxt_s28: std_logic;
Signal psm_nxt_s29: std_logic;
Signal psm_nxt_s30: std_logic;
Signal psm_nxt_s31: std_logic;
Signal psm_nxt_s32: std_logic;


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
Signal read_dly: std_logic_vector(0 to 7);  -- v6bit
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

Signal rsm_s00: std_logic;  -- bool
Signal rsm_s01: std_logic;  -- bool
Signal rsm_s02: std_logic;  -- bool
Signal rsm_s03: std_logic;  -- bool
Signal rsm_s04: std_logic;  -- bool
Signal rsm_s05: std_logic;  -- bool
Signal rsm_s06: std_logic;  -- bool
Signal rsm_s07: std_logic;  -- bool
Signal rsm_s08: std_logic;  -- bool
Signal rsm_s09: std_logic;  -- bool
Signal rsm_s10: std_logic;  -- bool
Signal rsm_s11: std_logic;  -- bool
Signal rsm_s12: std_logic;  -- bool
Signal rsm_s13: std_logic;  -- bool
Signal rsm_s14: std_logic;  -- bool
Signal rsm_s15: std_logic;  -- bool

Signal rsm_nxt_s00: std_logic;  -- bool
Signal rsm_nxt_s01: std_logic;  -- bool
Signal rsm_nxt_s02: std_logic;  -- bool
Signal rsm_nxt_s03: std_logic;  -- bool
Signal rsm_nxt_s04: std_logic;  -- bool
Signal rsm_nxt_s05: std_logic;  -- bool
Signal rsm_nxt_s06: std_logic;  -- bool
Signal rsm_nxt_s07: std_logic;  -- bool
Signal rsm_nxt_s08: std_logic;  -- bool
Signal rsm_nxt_s09: std_logic;  -- bool
Signal rsm_nxt_s10: std_logic;  -- bool
Signal rsm_nxt_s11: std_logic;  -- bool
Signal rsm_nxt_s12: std_logic;  -- bool
Signal rsm_nxt_s13: std_logic;  -- bool
Signal rsm_nxt_s14: std_logic;  -- bool
Signal rsm_nxt_s15: std_logic;  -- bool

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
Signal rst_pulse: std_logic_vector(0 to 7);  -- v6bit
Signal rst_recov: std_logic_vector(0 to 7);  -- v6bit
Signal start_buf: std_logic_vector(0 to 16);  -- v17bit
Signal start_dly: std_logic;  -- bool
--Signal version: std_logic_vector(0 to 31);  -- int
Signal f_read_data_valinternal: std_logic;  -- bool
Signal flash_dataout_d: std_logic_vector(15 downto 0);
Signal flash_datain_d: std_logic_vector(15 downto 0);
Signal flash_addr_d: std_logic_vector(25 downto 0);
Signal flash_intf_oe_d: std_logic;
Signal flash_dat_oe_d: std_logic;
Signal flash_wen_d: std_logic;
Signal flash_oen_d: std_logic;
Signal flash_cen_d: std_logic_vector(0 to 1);
Signal flash_rstn_d: std_logic;
Signal flash_intf_oe_unrep_d: std_logic;
Signal flash_dat_oe_unrep_d: std_logic;
Signal capture_status_reg: std_logic;
Signal f_memstat_int: std_logic_vector(0 to 15);
Signal f_memstat_int2: std_logic_vector(0 to 15);

Signal pfl_flash_grant: std_logic;  -- bool
Signal pfl_flash_reqn: std_logic;  -- bool


begin

  Z_v9bit <= (others => '0');
  Z_v32bit <= (others => '0');
  Z_v17bit <= (others => '0');
  Z_v10bit <= (others => '0');

--    version <= "00000000000000000000000000001100" ;

------------------------------------------------------------------------------------------------------------------------------------------
---- Basic Cycle Timing for Flash
----               _____________________________________________________________________________________________________________________
----  Reset _32c__/
----              |40c|
----      ____________ _________________________________________________________________ _______________________________________________
----  Addr////////////X_________________________________________________________________X///////////////////////////////////////////////
----                  |
----     _____________                                                                                                   ____6c____
----  CE#             _________________________________________________________________________________________________/          ____
----                  |1c|
----     ________________             ____6c_____             ____6c_____             __________________________________________________
----  WE#                ____14c____/           ____14c____/           ____14c____/
----                  |              |1c|        |           |1c|        |           |1c|
----                   _________________ _______________________ _______________________
----  Data------------X_______D0________X__________D1___________X__________D2___________X-----------------------------------------------
----                  |                                                                 |   6c   |
----     ________________________________________________________________________________________                 ______________________
----  OE#             |                                                                 |        ______10c______/   6c
----                  |                                                                 |                        |  5c   |
----                  |                                                                 |         _________ _____________
----  Rd_Data------------------------------------------------------------------------------------X/////////X_____________X--------------
----                  |                                                                 |        |    7c   |
----                  |- - - - - - - -                      28c                             - - - - - - - -|
----                   _________________________________________________________________
----  fdat_oe_________/                                                                 _______________________________________________
----
----                  0  1           2  3        4           5  6        7           8  9        A               B         C       D
----                                              Repeated                                      13              14        15      16
----------------------------------------------------------------------------------------------------------------------------------------------

--============================================================================================
---- Misc. Logic
--==============================================================================================--
 -- ----------------------------------- --
 -- Input latches                       --
 -- ----------------------------------- --

    dff_fdatain_first: capi_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => flash_datain_d,
         din => flash_datain,
         clk   => psl_clk
    );

    datain_hien <= esm_datain_en  or  psm_datain_en  or  (rsm_datain_en  and  faddr_be(25)) ;
    datain_loen <= esm_datain_en  or  psm_datain_en  or  (rsm_datain_en  and   not faddr_be(25)) ;
    endff_fdatain_hi: capi_en_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => fdatain_hi,
         en => datain_hien,
         din => flash_datain_d,
         clk   => psl_clk
    );

    endff_fdatain_lo: capi_en_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => fdatain_lo,
         en => datain_loen,
         din => flash_datain_d,
         clk   => psl_clk
    );

    fdatain <= ( fdatain_hi & fdatain_lo );


    flash_busy <=  not (fdatain(7)  and  fdatain(23)) ;

    flash_error <= ( fdatain(7)   and  ( fdatain(0)   or  fdatain(1)   or  fdatain(2)   or  fdatain(3)   or
                                          fdatain(4)   or  fdatain(4)   or  fdatain(6)                   ) )  or
                       ( fdatain(23)  and  ( fdatain(16)  or  fdatain(17)  or  fdatain(18)  or  fdatain(19)  or
                                          fdatain(20)  or  fdatain(21)  or  fdatain(22)                  ) ) ;

    f_read_data <= fdatain;

    dff_fgrant_ll: capi_rise_dff PORT MAP (
         dout => fgrant_ll,
         din => fgrant_l,
         clk   => psl_clk
    );

    dff_fgrant_lll: capi_rise_dff PORT MAP (
         dout => fgrant_lll,
         din => fgrant_ll,
         clk   => psl_clk
    );


 -- ----------------------------------- --
 -- Output latches                      --
 -- ----------------------------------- --
    flash_clk <= '1' ;
    flash_advn <= '1' ;
    flash_wpn <= '1' ;

    fcen_0 <=  '0' ;
    fcen_1 <=  '0' ;
    fcen <= ( fcen_0 & fcen_1 );


    fwen <=  not (erase_we  or  pgm_we  or  read_we) ;
    foen <=  not (erase_oe  or  pgm_oe  or  read_oe) ;
    --bool fwpn = 0b0;

    fdatoe <= (erase_dat_oe  or  pgm_dat_oe  or  read_dat_oe) ;
    pfl_flash_grant <=  not pfl_flash_reqn ;


    dff_fgrant_l: capi_rise_dff PORT MAP (
         dout => fgrant_l,
         din => pfl_flash_grant,
         clk   => psl_clk
    );

   dff_pfl_flash_reqn: capi_rise_dff PORT MAP (
          dout => pfl_flash_reqn,
          din => pflreqn,
          clk   => psl_clk
     );


  -- Main SM controlled --
    dff_flash_rstn: capi_rise_dff PORT MAP (
         dout => flash_rstn_d,
         din => frstn,
         clk   => psl_clk
    );
    -- Main SM controlled --
    fintf_oe_n <= not fintf_oe;
    dff_flash_intf_oe: capi_rise_dff_init1 PORT MAP (
         dout => flash_intf_oe_unrep_d,
         din => fintf_oe_n,
         clk   => psl_clk
    );
    -- Main SM controlled --
    dff_flash_cen: capi_rise_vdff GENERIC MAP ( width => 2 ) PORT MAP (
         dout => flash_cen_d,
         din => fcen,
         clk   => psl_clk
    );

    dff_flash_oen: capi_rise_dff PORT MAP (
         dout => flash_oen_d,
         din => foen,
         clk   => psl_clk
    );

    dff_flash_wen: capi_rise_dff PORT MAP (
         dout => flash_wen_d,
         din => fwen,
         clk   => psl_clk
    );

    --dff(type=bool) (flash_wpn, fwpn);
    fdatoe_n <= not fdatoe;
    dff_flash_dat_oe: capi_rise_dff_init1 PORT MAP (
         dout => flash_dat_oe_unrep_d,
         din => fdatoe_n,
         clk   => psl_clk
    );


    -- -- Address Output Latch -- --
    erase_adr_sel <= program_flash  and   not erase_complete ;
    pgm_adr_sel <= program_flash  and  erase_complete ;
    read_adr_sel <= read_flash ;

    faddr_be <= gate_and(erase_adr_sel,erase_addr) or
                gate_and(pgm_adr_sel,pgm_addr) or
                gate_and(read_adr_sel,read_addr);

    faddr <= faddr_be;

    --v26bit faddr = faddr_be;

    dff_flash_addr: capi_rise_vdff GENERIC MAP ( width => 26 ) PORT MAP (
         dout => flash_addr_d,
         din => faddr,
         clk   => psl_clk
    );


    -- -- Data Output Latch -- --
    fdataout_be <= erase_data_out  or  pgm_data_out  or  read_data_out ;

    --v32bit fdataout = fdataout_be;

    fdataout_be_d <= fdataout_be(0 to 15) when faddr(0)='1' else fdataout_be(16 to 31);

    fdataout <= fdataout_be_d;

    dff_flash_dataout: capi_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => flash_dataout_d,
         din => fdataout,
         clk   => psl_clk
    );

    dff_flash_rstn2: capi_rise_dff PORT MAP (
         dout => flash_rstn,
         din => flash_rstn_d,
         clk   => psl_clk
    );
        -- Main SM controlled --
    flash_intf_oe_d <= flash_intf_oe_unrep_d;
    dff_flash_intf_oe2: capi_rise_dff_init1 PORT MAP (
         dout => flash_intf_oe,
         din => flash_intf_oe_d,
         clk   => psl_clk
    );
        -- Main SM controlled --

    dff_flash_cen2: capi_rise_vdff GENERIC MAP ( width => 2 ) PORT MAP (
         dout => flash_cen,
         din => flash_cen_d,
         clk   => psl_clk
    );

    dff_flash_oen2: capi_rise_dff PORT MAP (
         dout => flash_oen,
         din => flash_oen_d,
         clk   => psl_clk
    );

    dff_flash_wen2: capi_rise_dff PORT MAP (
         dout => flash_wen,
         din => flash_wen_d,
         clk   => psl_clk
    );

    flash_dat_oe_d <= flash_dat_oe_unrep_d;
    dff_flash_dat_oe2: capi_rise_dff_init1 PORT MAP (
         dout => flash_dat_oe,
         din => flash_dat_oe_d,
         clk   => psl_clk
    );

    dff_flash_addr2: capi_rise_vdff GENERIC MAP ( width => 26 ) PORT MAP (
         dout => flash_addr,
         din => flash_addr_d,
         clk   => psl_clk
    );

    dff_flash_dataout2: capi_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => flash_dataout,
         din => flash_dataout_d,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Outputs                             --
 -- ----------------------------------- --
    f_stat_erase <= f_program_req  and   not erase_complete ;
    f_stat_program <= f_program_req  and   not pgm_complete ;
    f_stat_read <= read_flash     and   not read_complete ;

    pgm_remainder <= psm_bufcnt_q(0 to 9) when erase_complete='1' else esm_blkcnt_q;

    f_remainder <= rsm_wrdcnt_q when f_read_req='1' else pgm_remainder;

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Cycle Timer                         --
 -- ----------------------------------- --

    start_dly <= main_sm_start_dly  or  erase_sm_start_dly  or  pgm_sm_start_dly  or  read_sm_start_dly ;
    new_dly <= main_dly  or  erase_dly  or  pgm_dly  or  read_dly ;
    cycdly_m1 <= std_logic_vector(unsigned(cycdly_q) - 1) ;

    cycdly_d <= new_dly when start_dly='1' else cycdly_m1;

    cnt_en <= start_dly  or   not dly_done ;
    endff_cycdly_q: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => cycdly_q,
         en => cnt_en,
         din => cycdly_d,
         clk   => psl_clk
    );


    dly_done <= '1' when (cycdly_q  =  "00000000") else '0';
 -- -- End Section -- --

--============================================================================================
---- Main State
--==============================================================================================--
 -- ----------------------------------- --
 -- Next State Equations and SM Latch   --
 -- ----------------------------------- --

    pgm_rd_req <= f_program_req  or  f_read_req ;

    main_sm_nxt_0 <= pgm_rd_req when (main_sm  =  "00000000") else '0';     -- Program or Read Request --
    main_sm_nxt_1 <= ( main_sm(0)  or                                    -- Request Access to Flash --
                              ( not fgrant_lll         and  main_sm(1))   ) ;
    main_sm_nxt_2 <= ( (fgrant_lll          and  main_sm(1))  or             -- Reset Flash --
                              ( not dly_done           and  main_sm(2))   ) ;
    main_sm_nxt_3 <= ( (dly_done            and  main_sm(2))  or             -- Wait for reset recovery --
                              ( not dly_done           and  main_sm(3))   ) ;
    main_sm_nxt_4 <= ( (dly_done            and  main_sm(3))  or             -- Programming or Reading the device --
                              ( not pgm_complete   and  f_program_req
                                                   and  main_sm(4))  or
                              ( not read_complete  and  f_read_req
                                                   and  main_sm(4))   ) ;
    main_sm_nxt_5 <= ( (pgm_complete    and  f_program_req                 -- Reset Flash --
                                                   and  main_sm(4))  or
                              (read_complete   and  f_read_req
                                                   and  main_sm(4))  or
                              ( not dly_done           and  main_sm(5))   ) ;
    main_sm_nxt_6 <= ( (dly_done            and  main_sm(5))  or             -- Wait for reset recovery --
                              ( not dly_done           and  main_sm(6))   ) ;
    main_sm_nxt_7 <= ( (dly_done            and  main_sm(6))  or             -- Finish -- Issue Reset to Flash --
                              ( not dly_done           and  main_sm(7))  or
                              (fgrant_lll          and  main_sm(7))  or
                              (pgm_rd_req          and  main_sm(7))   ) ;

    main_sm_nxt <= ( main_sm_nxt_0 & main_sm_nxt_1 & main_sm_nxt_2 & main_sm_nxt_3 & main_sm_nxt_4 & main_sm_nxt_5 & main_sm_nxt_6 & main_sm_nxt_7 );

    dff_main_sm: capi_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => main_sm,
         din => main_sm_nxt,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Main SM Outputs                     --
 -- ----------------------------------- --
    pflreqn <=  not (main_sm(1)  or  main_sm(2)  or  main_sm(3)  or  main_sm(4)  or  main_sm(5)  or
                     main_sm(6)) ;
    frstn <=  not (main_sm(2)  or  main_sm(5)) ;
    fintf_oe <= main_sm(2)  or  main_sm(3)  or  main_sm(4)  or  main_sm(5)  or  main_sm(6) ;

    program_flash <= main_sm(4)  and  f_program_req ;
    read_flash <= main_sm(4)  and  f_read_req ;

    init_cnt_adr <= main_sm(0) ;

    f_ready <=  not (main_sm(0)  or  main_sm(1)  or  main_sm(2)  or  main_sm(3)  or  main_sm(4)  or
                     main_sm(5)  or  main_sm(6)  or  main_sm(7)) ;

    f_done <= main_sm(7) ;
 -- -- End Section -- --
 -- ----------------------------------- --
 -- Cycle Delay Control                 --
 -- ----------------------------------- --
    rst_pulse <= "00011010" ; --0x1A;--  -- 104nsec or 26 cycles -- spec 100nsec--
    rst_recov <= "00110000" ; --0x27;--  -- 156nsec or 39 cycles -- spec 150nsec--

    msm_rstp_dly_sel <= (main_sm(1)  or  (main_sm(4)  and  (pgm_complete  or  read_complete))) ;
    msm_rstr_dly_sel <= (main_sm(2)  or  main_sm(5)) ;
    msm_no_dly_sel <=  not (msm_rstp_dly_sel  or  msm_rstr_dly_sel) ;

    main_dly <= gate_and(msm_rstp_dly_sel,rst_pulse) or
                gate_and(msm_rstr_dly_sel,rst_recov) or
                gate_and(msm_no_dly_sel,"00000000");


    main_sm_start_dly <= (main_sm_nxt_2  and   not main_sm(2))  or  (main_sm_nxt_3  and   not main_sm(3))  or
                             (main_sm_nxt_5  and   not main_sm(5))  or  (main_sm_nxt_6  and   not main_sm(6)) ;
 -- -- End Section -- --

--============================================================================================
---- Erase Blocks
--==============================================================================================--
 -- ----------------------------------- --
 -- Next State Equations and SM Latch   --
 -- ----------------------------------- --

    ---- States 00-20 : Block Erase
    ---- State 00  : Activate CE Drive Data & Addr       addr 0000555 data 00aa
    ---- State 01  : Activate WE (Delay 14 clocks)
    ---- State 02  : Deactivate WE

    ---- State 03  : Activate CE Drive Data & Addr       addr 00002aa data 0055
    ---- State 04  : Activate WE (Delay 14 clocks)
    ---- State 05  : Deactivate WE

    ---- State 06  : Activate CE Drive Data & Addr       addr 0000555 data 0080
    ---- State 07  : Activate WE (Delay 14 clocks)
    ---- State 08  : Deactivate WE

    ---- State 09  : Activate CE Drive Data & Addr       addr 0000555 data 00aa
    ---- State 10  : Activate WE (Delay 14 clocks)
    ---- State 11  : Deactivate WE

    ---- State 12  : Activate CE Drive Data & Addr       addr 00002aa data 0055
    ---- State 13  : Activate WE (Delay 14 clocks)
    ---- State 14  : Deactivate WE

    ---- State 15  : Activate CE Drive Data & Addr       addr <block>0 data 0030
    ---- State 16  : Activate WE (Delay 14 clocks)
    ---- State 17  : Deactivate WE

    ---- State 18  : Activate CE Drive Data & Addr       addr <block>1 data 0030
    ---- State 19  : Activate WE (Delay 14 clocks)
    ---- State 20  : Deactivate WE

    ---- State 21 : Tristate Data (Delay 6 clocks)          addr <block>1                   ----
    ---- State 22 : Activate OE (Delay 14 clocks)                                           ----
    ---- State 23 : Deactivate OE (Delay 6 clocks)         <- Read Status                   ----
    ----            Nxt State 22 if flash is busy             - Flash Busy                  ----
    ----            Nxt State 00 if more blocks to erase      - Erase next block            ----
    ----            Nxt State 24 if erase complete            - Erase complete              ----
    ----            *** Check for Error ***                                                 ----
    ---- State 24 : Delay 6 clocks for min CE High         <- No more blocks to erase       ----
    ---- State 25 : Erase Complete - Wait for done         <- Erase Complete                ----
    ----                             Kick off programming of device                         ----
    ----            Nxt State 00 if programming sequence is done (~program_flash)           ----

    ---- Next State Controls ----
    esm_rst <= ( ( not esm_done  and  esm_s23  and  fdatain(7) )  or   -- Continue with next block erase --
                       esm_s25  or   not program_flash         ) ;     -- Reset State Machine when program is complete --

    esm_redo_rd <= ( esm_s23  and  not(fdatain(7))  and  program_flash) ;  -- Re-read status register until erase block is complete --

    esm_p1 <=  not (esm_rst  or  esm_redo_rd)  and  program_flash ;   -- Increment to next state --
    -----------------------------

    ---- Next State ----
    erase_sm_p1 <= std_logic_vector(unsigned(erase_sm) + 1);
    erase_sm_nxt <= gate_and(esm_p1,erase_sm_p1) or
                    gate_and(esm_redo_rd,"010110") or  -- s22
                    gate_and(esm_rst,"000000");


    --------------------

    -- Next State Latch and advance control --
    esm_adv <= (dly_done  and   not esm_s25  and  program_flash)  or  -- Advance State Machine when delay is done and erase is not complete --
                                              not program_flash;      -- Advance State Machine when program is complete or terminated

    --mux(type=v5bit) (erase_sm_nxt, esm_adv, erase_sm_adv, erase_sm);--
    endff_erase_sm: capi_en_rise_vdff GENERIC MAP ( width => 6 ) PORT MAP (
         dout => erase_sm,
         en => esm_adv,
         din => erase_sm_nxt,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Block Address                       --
 -- ----------------------------------- --
    esm_blkadr_p1 <= std_logic_vector(unsigned(esm_blkadr_q) + 1);

    esm_blkadr_d <= f_start_blk when esm_s00='1' else esm_blkadr_p1;


    --bool esm_update_blkadr = (init_cnt_adr | esm_s0x11);--
    esm_update_blkadr <= (init_cnt_adr  or  (esm_s23  and  esm_adv  and  esm_nxt_s00) ) ;

    endff_esm_blkadr_q: capi_en_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => esm_blkadr_q,
         en => esm_update_blkadr,
         din => esm_blkadr_d,
         clk   => psl_clk
    );


 -- -- End Section -- --
 -- ----------------------------------- --
 -- Count of Blocks to Erase            --
 -- ----------------------------------- --
    esm_blkcnt_m1 <= std_logic_vector(unsigned(esm_blkcnt_q) - 1);

    esm_blkcnt_d <= f_num_blocks when esm_s00='1' else esm_blkcnt_m1;


    esm_update_blkcnt <= (init_cnt_adr  or  (esm_s20  and  dly_done)) ;

    endff_esm_blkcnt_q: capi_en_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => esm_blkcnt_q,
         en => esm_update_blkcnt,
         din => esm_blkcnt_d,
         clk   => psl_clk
    );


 -- -- End Section -- --
 -- ----------------------------------- --
 -- Erase SM Outputs                    --
 -- ----------------------------------- --
    -- -- erase address -- --
    erase_addr(10 to 25) <=
                      gate_and(esm_s00,x"0555") or
                      gate_and(esm_s01,x"0555") or
                      gate_and(esm_s02,x"0555") or
                      gate_and(esm_s03,x"02aa") or
                      gate_and(esm_s04,x"02aa") or
                      gate_and(esm_s05,x"02aa") or
                      gate_and(esm_s06,x"0555") or
                      gate_and(esm_s07,x"0555") or
                      gate_and(esm_s08,x"0555") or
                      gate_and(esm_s09,x"0555") or
                      gate_and(esm_s10,x"0555") or
                      gate_and(esm_s11,x"0555") or
                      gate_and(esm_s12,x"02aa") or
                      gate_and(esm_s13,x"02aa") or
                      gate_and(esm_s14,x"02aa");

    -- s36-s41 - upper address is 128KB block address
    --           erase two blocks at a time since vsec interface uses 256KB blocks
    -- s42-44 - use address in the block being erased when reading status register
    erase_addr(0 to 9) <=
                      gate_and(esm_s15,esm_blkadr_q(1 to 9) & "0") or
                      gate_and(esm_s16,esm_blkadr_q(1 to 9) & "0") or
                      gate_and(esm_s17,esm_blkadr_q(1 to 9) & "0") or
                      gate_and(esm_s18,esm_blkadr_q(1 to 9) & "1") or
                      gate_and(esm_s19,esm_blkadr_q(1 to 9) & "1") or
                      gate_and(esm_s20,esm_blkadr_q(1 to 9) & "1") or
                      gate_and(esm_s21,esm_blkadr_q(1 to 9) & "1") or
                      gate_and(esm_s22,esm_blkadr_q(1 to 9) & "1") or
                      gate_and(esm_s23,esm_blkadr_q(1 to 9) & "1");




    -- -- latch input data ----
    esm_datain_en <= esm_s22 ;

    -- -- output data ----
    erase_data_out(16 to 31) <=
                      gate_and((esm_s00 and not esm_rst),x"00aa") or
                      gate_and(esm_s01,x"00aa") or
                      gate_and(esm_s02,x"00aa") or
                      gate_and(esm_s03,x"0055") or
                      gate_and(esm_s04,x"0055") or
                      gate_and(esm_s05,x"0055") or
                      gate_and(esm_s06,x"0080") or
                      gate_and(esm_s07,x"0080") or
                      gate_and(esm_s08,x"0080") or
                      gate_and(esm_s09,x"00aa") or
                      gate_and(esm_s10,x"00aa") or
                      gate_and(esm_s11,x"00aa") or
                      gate_and(esm_s12,x"0055") or
                      gate_and(esm_s13,x"0055") or
                      gate_and(esm_s14,x"0055") or
                      gate_and(esm_s15,x"0030") or
                      gate_and(esm_s16,x"0030") or
                      gate_and(esm_s17,x"0030") or
                      gate_and(esm_s18,x"0030") or
                      gate_and(esm_s19,x"0030") or
                      gate_and(esm_s20,x"0030");
    erase_data_out(0 to 15) <= erase_data_out(16 to 31);


    -- -------------------

    esm_done <= '1' when (esm_blkcnt_q  =  Z_v10bit) else '0';

    erase_complete <= esm_s25 ;

    erase_ce <= (program_flash  and   not (esm_s24  or  esm_s25)) ;

    erase_we <= ( esm_s01   or  esm_s04   or  esm_s07  or esm_s10   or  esm_s13   or  esm_s16 or esm_s19  ) ;

    erase_oe <= esm_s22 ;

    erase_dat_oe <= program_flash  and   not (esm_s21  or  esm_s22  or  esm_s23  or  esm_s24 or esm_s25  ) ;

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Cycle Delay Control                 --
 -- ----------------------------------- --
    esm_sel_WEL_dly <= ( esm_nxt_s01   or  esm_nxt_s04   or  esm_nxt_s07  or esm_nxt_s10   or  esm_nxt_s13   or  esm_nxt_s16 or esm_nxt_s19  )  and  program_flash ;

    esm_sel_WEH_dly <= ( esm_nxt_s02   or  esm_nxt_s05   or  esm_nxt_s08  or esm_nxt_s11   or  esm_nxt_s14   or  esm_nxt_s17 or esm_nxt_s20  )  and  program_flash ;

    esm_sel_FTD_dly <=  esm_nxt_s21   and  program_flash ;

    esm_sel_OEH_dly <=  esm_nxt_s23   and  program_flash ;

    esm_sel_CEH_dly <=  esm_nxt_s24   and  program_flash ;

    esm_sel_OEL_dly <=  esm_nxt_s22   and  program_flash ;

    esm_no_dly_sel <=  not (esm_sel_WEL_dly  or  esm_sel_WEH_dly  or  esm_sel_FTD_dly  or  esm_sel_OEH_dly  or  esm_sel_CEH_dly  or  esm_sel_OEL_dly)  or
                           not program_flash ;

    -- Value for delay is n-1, 0 is no delay or 1 cycle --
    erase_dly <= gate_and(esm_sel_WEL_dly,"00111111") or
                 gate_and(esm_sel_WEH_dly,"00111111") or
                 gate_and(esm_sel_FTD_dly,"00111111") or
                 gate_and(esm_sel_OEH_dly,"00111111") or
                 gate_and(esm_sel_CEH_dly,"00111111") or
                 gate_and(esm_sel_OEL_dly,"00111111") or
                 gate_and(esm_no_dly_sel,"00111111");

  -- 0x0 --

    erase_sm_start_dly <= (  not esm_nxt_s00  and  dly_done ) ;
 -- -- End Section -- --
 -- ----------------------------------- --
 -- Erase SM Decodes                    --
 -- ----------------------------------- --


 esm_s00 <= '1' when (erase_sm  =  "000000") else '0';
 esm_s01 <= '1' when (erase_sm  =  "000001") else '0';
 esm_s02 <= '1' when (erase_sm  =  "000010") else '0';
 esm_s03 <= '1' when (erase_sm  =  "000011") else '0';
 esm_s04 <= '1' when (erase_sm  =  "000100") else '0';
 esm_s05 <= '1' when (erase_sm  =  "000101") else '0';
 esm_s06 <= '1' when (erase_sm  =  "000110") else '0';
 esm_s07 <= '1' when (erase_sm  =  "000111") else '0';
 esm_s08 <= '1' when (erase_sm  =  "001000") else '0';
 esm_s09 <= '1' when (erase_sm  =  "001001") else '0';
 esm_s10 <= '1' when (erase_sm  =  "001010") else '0';
 esm_s11 <= '1' when (erase_sm  =  "001011") else '0';
 esm_s12 <= '1' when (erase_sm  =  "001100") else '0';
 esm_s13 <= '1' when (erase_sm  =  "001101") else '0';
 esm_s14 <= '1' when (erase_sm  =  "001110") else '0';
 esm_s15 <= '1' when (erase_sm  =  "001111") else '0';
 esm_s16 <= '1' when (erase_sm  =  "010000") else '0';
 esm_s17 <= '1' when (erase_sm  =  "010001") else '0';
 esm_s18 <= '1' when (erase_sm  =  "010010") else '0';
 esm_s19 <= '1' when (erase_sm  =  "010011") else '0';
 esm_s20 <= '1' when (erase_sm  =  "010100") else '0';
 esm_s21 <= '1' when (erase_sm  =  "010101") else '0';
 esm_s22 <= '1' when (erase_sm  =  "010110") else '0';
 esm_s23 <= '1' when (erase_sm  =  "010111") else '0';
 esm_s24 <= '1' when (erase_sm  =  "011000") else '0';
 esm_s25 <= '1' when (erase_sm  =  "011001") else '0';

 esm_nxt_s00 <= '1' when (erase_sm_nxt  =  "000000") else  '0';
 esm_nxt_s01 <= '1' when (erase_sm_nxt  =  "000001") else  '0';
 esm_nxt_s02 <= '1' when (erase_sm_nxt  =  "000010") else  '0';
 esm_nxt_s03 <= '1' when (erase_sm_nxt  =  "000011") else  '0';
 esm_nxt_s04 <= '1' when (erase_sm_nxt  =  "000100") else  '0';
 esm_nxt_s05 <= '1' when (erase_sm_nxt  =  "000101") else  '0';
 esm_nxt_s06 <= '1' when (erase_sm_nxt  =  "000110") else  '0';
 esm_nxt_s07 <= '1' when (erase_sm_nxt  =  "000111") else  '0';
 esm_nxt_s08 <= '1' when (erase_sm_nxt  =  "001000") else  '0';
 esm_nxt_s09 <= '1' when (erase_sm_nxt  =  "001001") else  '0';
 esm_nxt_s10 <= '1' when (erase_sm_nxt  =  "001010") else  '0';
 esm_nxt_s11 <= '1' when (erase_sm_nxt  =  "001011") else  '0';
 esm_nxt_s12 <= '1' when (erase_sm_nxt  =  "001100") else  '0';
 esm_nxt_s13 <= '1' when (erase_sm_nxt  =  "001101") else  '0';
 esm_nxt_s14 <= '1' when (erase_sm_nxt  =  "001110") else  '0';
 esm_nxt_s15 <= '1' when (erase_sm_nxt  =  "001111") else  '0';
 esm_nxt_s16 <= '1' when (erase_sm_nxt  =  "010000") else  '0';
 esm_nxt_s17 <= '1' when (erase_sm_nxt  =  "010001") else  '0';
 esm_nxt_s18 <= '1' when (erase_sm_nxt  =  "010010") else  '0';
 esm_nxt_s19 <= '1' when (erase_sm_nxt  =  "010011") else  '0';
 esm_nxt_s20 <= '1' when (erase_sm_nxt  =  "010100") else  '0';
 esm_nxt_s21 <= '1' when (erase_sm_nxt  =  "010101") else  '0';
 esm_nxt_s22 <= '1' when (erase_sm_nxt  =  "010110") else  '0';
 esm_nxt_s23 <= '1' when (erase_sm_nxt  =  "010111") else  '0';
 esm_nxt_s24 <= '1' when (erase_sm_nxt  =  "011000") else  '0';
 esm_nxt_s25 <= '1' when (erase_sm_nxt  =  "011001") else  '0';


 -- -- End Section -- --
--============================================================================================
---- Program Blocks
--==============================================================================================--
 -- ----------------------------------- --
 -- Next State Equations and SM Latch   --
 -- ----------------------------------- --
    ---- States 0-8  : Unlock Bypass
    ---- State 0  : Activate CE Drive Data & Addr       addr 0000555 data 00aa
    ---- State 1  : Activate WE (Delay 14 clocks)
    ---- State 2  : Deactivate WE

    ---- State 3  : Activate CE Drive Data & Addr       addr 00002aa data 0055
    ---- State 4  : Activate WE (Delay 14 clocks)
    ---- State 5  : Deactivate WE

    ---- State 6  : Activate CE Drive Data & Addr       addr 0000555 data 0020
    ---- State 7  : Activate WE (Delay 14 clocks)
    ---- State 8  : Deactivate WE

    ----              Unlock bypass write to buffer program
    ---- State 09  : Activate CE Drive Data & Addr       addr <addr> data 0025
    ---- State 10  : Activate WE (Delay 14 clocks)
    ---- State 11  : Deactivate WE

    ---- State 12  : Activate CE Drive Data & Addr       addr <addr> data 01ff
    ---- State 13  : Activate WE (Delay 14 clocks)
    ---- State 14  : Deactivate WE
    ----             Nxt State 14 if data not available

    ---- State 15  : Activate CE Drive Data & Addr       addr <curaddr> data <data>
    ---- State 16  : Activate WE (Delay 14 clocks)
    ---- State 17  : Deactivate WE

    ---- State 18  : Drive Next Data (Delay 5 clocks)
    ----            Nxt State 18 if data not available &       - Data not available to write
    ----                            more data to write
    ----            Nxt State 16 if more data to write         - More data to write
    ----            Nxt State 19 if ready to pgm buffer        - No more data to write

    --               confirm
    ---- State 19  : Activate CE Drive Data & Addr       addr <addr> data 0029
    ---- State 20  : Activate WE (Delay 14 clocks)
    ---- State 21  : Deactivate WE

    ---- State 22 : Tristate Data (Delay 6 clocks)        addr = <last addr>                ----
    ---- State 23 : Activate OE (Delay 14 clocks)                                           ----
    ---- State 24 : Deactivate OE (Delay 6 clocks)         <- Read Status                   ----
    ----            Nxt State 23 if read DQ7 != programmed DQ7 of last word                 ----
    ----            Nxt State 09 if more data to program      - Program next buffer         ----
    ----            Nxt State 25 if program complete          - Programming done            ----
    ----            *** Check for Error ***                                                 ----

    --              Unlock Bypass
    ---- State 25 : Activate CE Drive Data & Addr       addr 0000555 data 0090
    ---- State 26 : Activate WE (Delay 14 clocks)
    ---- State 27 : Deactivate WE

    ---- State 28 : Activate CE Drive Data & Addr       addr 00002aa data 0000
    ---- State 29 : Activate WE (Delay 14 clocks)
    ---- State 30 : Deactivate WE

    ---- State 31 : Delay 6 clocks for min CE High         <- No more buffers to program    ----
    ---- State 32 : Program Complete - Wait for done       <- Programming Complete          ----
    ----            Nxt State 00 if programming sequence is done (~program_flash)           ----



    ---- Next State Controls ----
    psm_rst <= not program_flash ;

    psm_wr_nxt_buf_dat <= (psm_s18   and   not buf_full  and  program_flash) ;                   -- Continue writing buffer data until buffer is full     --
    psm_redo_bufdone_rd <= (psm_s24  and  (fdatain(7) xor psm_status_dq7_q)   and  program_flash) ;    -- Re-read status register program of buffer is complete --
    psm_pgm_nxt_buf <= (psm_s24  and   (fdatain(7) xnor psm_status_dq7_q)  and  psm_more_bufs  and  program_flash) ; -- Continue to program next buffer              --

    psm_p1 <=  not ((psm_rst  or  psm_wr_nxt_buf_dat  or                  -- Increment to next state                               --
                     psm_redo_bufdone_rd  or  psm_pgm_nxt_buf))  and  program_flash ;

    -----------------------------

    ---- Next State ----
    pgm_sm_p1 <= std_logic_vector(unsigned(pgm_sm) + 1);
    pgm_sm_nxt <= gate_and(psm_p1,pgm_sm_p1) or
                  gate_and(psm_wr_nxt_buf_dat, "010000") or  -- s16
                  gate_and(psm_redo_bufdone_rd,"010111") or  -- s23
                  gate_and(psm_pgm_nxt_buf,    "001001") or  -- s09
                  gate_and(psm_rst,            "000000");

    --------------------

    -- Next State Latch and advance control --
    psm_adv <= ( psm_rst or
                 (dly_done  and   not psm_s32  and  erase_complete)  or                       -- Advance State Machine when delay is done and erase is complete --
                 (dly_done  and   psm_s32  and   not program_flash ) )  and                    -- Advance State Machine when program is complete                 --
                     not (psm_s14   and   not f_program_data_val and program_flash) and            -- wait for first data to be valid
                     not (psm_s18   and   not f_program_data_val  and  not buf_full  and  program_flash) ;  -- Do not advance if buffer data is not valid for write

    endff_pgm_sm: capi_en_rise_vdff GENERIC MAP ( width => 6 ) PORT MAP (
         dout => pgm_sm,
         en => psm_adv,
         din => pgm_sm_nxt,
         clk   => psl_clk
    );

    dff_pgm_sm_q: capi_rise_vdff GENERIC MAP ( width => 6 ) PORT MAP (
         dout => pgm_sm_prev,
         din => pgm_sm,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Programming Address                 --
 -- ----------------------------------- --
    psm_bufadr_p1 <= std_logic_vector(unsigned(psm_bufadr_q) + 1);

    start_buf <= ( f_start_blk(1 to 9) & "00000000" );

    psm_bufadr_d <= start_buf when psm_s00='1' else psm_bufadr_p1;

    psm_update_bufadr <= (init_cnt_adr  or  (psm_s24  and  psm_nxt_s09 and psm_adv)) ;

    endff_psm_bufadr_q: capi_en_rise_vdff GENERIC MAP ( width => 17 ) PORT MAP (
         dout => psm_bufadr_q,
         en => psm_update_bufadr,
         din => psm_bufadr_d,
         clk   => psl_clk
    );


 -- -- End Section -- --
 -- ----------------------------------- --
 -- Programming Buffer Offset           --
 -- ----------------------------------- --
    psm_bufoff_p1 <= std_logic_vector(unsigned(psm_bufoff_q) + 1);

    init_buf_off <= psm_s00  or  (psm_s24 and psm_nxt_s09) ;
    psm_bufoff_d <= "000000000" when init_buf_off='1' else psm_bufoff_p1;

    psm_update_bufoff <= (init_buf_off  or  (psm_s17  and (psm_adv))) ;

    endff_psm_bufoff_q: capi_en_rise_vdff GENERIC MAP ( width => 9 ) PORT MAP (
         dout => psm_bufoff_q,
         en => psm_update_bufoff,
         din => psm_bufoff_d,
         clk   => psl_clk
    );


 -- -- End Section -- --
 -- ----------------------------------- --
 -- Count of Buffers to Program         --
 -- ----------------------------------- --
    psm_bufcnt_m1 <= std_logic_vector(unsigned(psm_bufcnt_q) - 1);

    num_buffers <= ( f_num_blocks(1 to 9) & "00000000" );

    psm_bufcnt_d <= num_buffers when psm_s00='1' else psm_bufcnt_m1;

    psm_update_bufcnt <= (init_cnt_adr  or  (psm_s21 and psm_adv)) ;

    endff_psm_bufcnt_q: capi_en_rise_vdff GENERIC MAP ( width => 17 ) PORT MAP (
         dout => psm_bufcnt_q,
         en => psm_update_bufcnt,
         din => psm_bufcnt_d,
         clk   => psl_clk
    );


 -- -- End Section -- --
 -- ----------------------------------- --
 -- Count of Words to write             --
 -- ----------------------------------- --
    psm_wrdcnt_m1 <= std_logic_vector(unsigned(psm_wrdcnt_q) - 1);

    psm_wrdcnt_d <= "111111111" when psm_s15='1' else psm_wrdcnt_m1;

    psm_update_wrdcnt <= ( psm_s15  or  (psm_s18  and (psm_adv)) ) ;

    endff_psm_wrdcnt_q: capi_en_rise_vdff GENERIC MAP ( width => 9 ) PORT MAP (
         dout => psm_wrdcnt_q,
         en => psm_update_wrdcnt,
         din => psm_wrdcnt_d,
         clk   => psl_clk
    );


 -- -- End Section -- --
-- ----------------------------------- --
 -- Program SM Outputs                  --
 -- ----------------------------------- --
    -- -- program address -- --

    pgm_addr(0 to 25) <=
                      gate_and(psm_s00,"00" & x"000555") or
                      gate_and(psm_s01,"00" & x"000555") or
                      gate_and(psm_s02,"00" & x"000555") or
                      gate_and(psm_s03,"00" & x"0002aa") or
                      gate_and(psm_s04,"00" & x"0002aa") or
                      gate_and(psm_s05,"00" & x"0002aa") or
                      gate_and(psm_s06,"00" & x"000555") or
                      gate_and(psm_s07,"00" & x"000555") or
                      gate_and(psm_s08,"00" & x"000555") or

                      -- starting address
                      gate_and(psm_s09,psm_bufadr_q & "000000000") or
                      gate_and(psm_s10,psm_bufadr_q & "000000000") or
                      gate_and(psm_s11,psm_bufadr_q & "000000000") or
                      gate_and(psm_s12,psm_bufadr_q & "000000000") or
                      gate_and(psm_s13,psm_bufadr_q & "000000000") or
                      gate_and(psm_s14,psm_bufadr_q & "000000000") or
                      -- current address
                      gate_and(psm_s15,psm_bufadr_q & psm_bufoff_q) or
                      gate_and(psm_s16,psm_bufadr_q & psm_bufoff_q) or
                      gate_and(psm_s17,psm_bufadr_q & psm_bufoff_q) or
                      gate_and(psm_s18,psm_bufadr_q & psm_bufoff_q) or
                      -- starting address - confirm
                      gate_and(psm_s19,psm_bufadr_q & "000000000") or
                      gate_and(psm_s20,psm_bufadr_q & "000000000") or
                      gate_and(psm_s21,psm_bufadr_q & "000000000") or
                      -- ending address - polling
                      gate_and(psm_s22,psm_bufadr_q & "111111111") or
                      gate_and(psm_s23,psm_bufadr_q & "111111111") or
                      gate_and(psm_s24,psm_bufadr_q & "111111111") or
                      gate_and(psm_s25,"00" & x"000555") or
                      gate_and(psm_s26,"00" & x"000555") or
                      gate_and(psm_s27,"00" & x"000555") or
                      gate_and(psm_s28,"00" & x"0002aa") or
                      gate_and(psm_s29,"00" & x"0002aa") or
                      gate_and(psm_s30,"00" & x"0002aa");


    -- -- latch input data ----
    psm_datain_en <=   psm_s23 ;

    -- -- output data ----
    pgm_data_out(0 to 31) <=
                      gate_and((psm_s00 and erase_complete) ,x"00aa00aa") or
                      gate_and(psm_s01,x"00aa00aa") or
                      gate_and(psm_s02,x"00aa00aa") or
                      gate_and(psm_s03,x"00550055") or
                      gate_and(psm_s04,x"00550055") or
                      gate_and(psm_s05,x"00550055") or
                      gate_and(psm_s06,x"00200020") or
                      gate_and(psm_s07,x"00200020") or
                      gate_and(psm_s08,x"00200020") or
                      gate_and(psm_s09,x"00250025") or
                      gate_and(psm_s10,x"00250025") or
                      gate_and(psm_s11,x"00250025") or
                      gate_and(psm_s12,x"01ff01ff") or
                      gate_and(psm_s13,x"01ff01ff") or
                      gate_and(psm_s14,x"01ff01ff") or
                      gate_and(psm_s15,f_program_data) or
                      gate_and(psm_s16,f_program_data) or
                      gate_and(psm_s17,f_program_data) or
                      gate_and(psm_s18,f_program_data) or
                      gate_and(psm_s19,x"00290029") or
                      gate_and(psm_s20,x"00290029") or
                      gate_and(psm_s21,x"00290029") or
                      gate_and(psm_s25,x"00900090") or
                      gate_and(psm_s26,x"00900090") or
                      gate_and(psm_s27,x"00900090") or
                      gate_and(psm_s28,x"00000000") or
                      gate_and(psm_s29,x"00000000") or
                      gate_and(psm_s30,x"00000000");



     -- save expected value of dq7 for status checking
     dff_psm_status_dq7_q: capi_en_rise_dff PORT MAP (
         dout => psm_status_dq7_q,
         en => psm_s17,
         din => fdataout(7),
         clk   => psl_clk
    );

    -- -------------------

    psm_done <= '1' when (psm_bufcnt_q  =  Z_v17bit) else '0';

    psm_more_bufs <=  '0' when (psm_bufcnt_q  =  Z_v17bit) else '1';

    buf_full <= '1' when (psm_wrdcnt_q  =  Z_v9bit) else '0';

    pgm_complete <= psm_s32 ;

    f_program_data_ack <= psm_s17  and (psm_adv) and  pgm_addr(25) ;

    pgm_ce <= (erase_complete  and   not (psm_s31  or  psm_s32)) ;

    pgm_we <= ( psm_s01   or  psm_s04   or  psm_s07  or psm_s10   or  psm_s13   or  psm_s16 or
                psm_s20   or  psm_s26   or  psm_s29   ) ;

    pgm_oe <=  psm_s23 ;

    pgm_dat_oe <= erase_complete  and   not ( psm_s22  or  psm_s23  or  psm_s24 ) ;
 -- -- End Section -- --
 -- ----------------------------------- --
 -- Cycle Delay Control                 --
 -- ----------------------------------- --

    psm_sel_WEL_dly <= (  psm_nxt_s01   or  psm_nxt_s04   or  psm_nxt_s07  or psm_nxt_s10   or  psm_nxt_s13   or  psm_nxt_s16 or
                         psm_nxt_s20   or  psm_nxt_s26   or  psm_nxt_s29   )  and  erase_complete ;

    psm_sel_WEH_dly <= ( psm_nxt_s02   or  psm_nxt_s05   or  psm_nxt_s08  or psm_nxt_s11   or  psm_nxt_s14   or  psm_nxt_s17 or
                         psm_nxt_s21   or  psm_nxt_s27   or  psm_nxt_s30   )  and  erase_complete ;

    psm_sel_FTD_dly <= ( psm_nxt_s22         )  and  erase_complete ;

    psm_sel_OEH_dly <= ( psm_nxt_s24         )  and  erase_complete ;

    psm_sel_CEH_dly <= ( psm_nxt_s31         )  and  erase_complete ;

    psm_sel_OEL_dly <= ( psm_nxt_s23         )  and  erase_complete ;

    psm_no_dly_sel <=  not (psm_sel_WEL_dly  or  psm_sel_WEH_dly  or  psm_sel_FTD_dly  or  psm_sel_OEH_dly  or  psm_sel_CEH_dly  or  psm_sel_OEL_dly)  or
                           not erase_complete ;

    -- Value for delay is n-1, 0 is no delay or 1 cycle --
    pgm_dly <= gate_and(psm_sel_WEL_dly,"00111111") or
               gate_and(psm_sel_WEH_dly,"00111111") or
               gate_and(psm_sel_FTD_dly,"00111111") or
               gate_and(psm_sel_OEH_dly,"00111111") or
               gate_and(psm_sel_CEH_dly,"00111111") or
               gate_and(psm_sel_OEL_dly,"00111111") or
               gate_and(psm_no_dly_sel,"00111111");

  -- No Delay. 1 cycle state transistion. --

    pgm_sm_start_dly <= not psm_nxt_s00  and  dly_done;
 -- -- End Section -- --
 -- ----------------------------------- --
 -- Program SM Decodes                  --
 -- ----------------------------------- --

 psm_s00 <= '1' when (pgm_sm  =  "000000") else '0';
 psm_s01 <= '1' when (pgm_sm  =  "000001") else '0';
 psm_s02 <= '1' when (pgm_sm  =  "000010") else '0';
 psm_s03 <= '1' when (pgm_sm  =  "000011") else '0';
 psm_s04 <= '1' when (pgm_sm  =  "000100") else '0';
 psm_s05 <= '1' when (pgm_sm  =  "000101") else '0';
 psm_s06 <= '1' when (pgm_sm  =  "000110") else '0';
 psm_s07 <= '1' when (pgm_sm  =  "000111") else '0';
 psm_s08 <= '1' when (pgm_sm  =  "001000") else '0';
 psm_s09 <= '1' when (pgm_sm  =  "001001") else '0';
 psm_s10 <= '1' when (pgm_sm  =  "001010") else '0';
 psm_s11 <= '1' when (pgm_sm  =  "001011") else '0';
 psm_s12 <= '1' when (pgm_sm  =  "001100") else '0';
 psm_s13 <= '1' when (pgm_sm  =  "001101") else '0';
 psm_s14 <= '1' when (pgm_sm  =  "001110") else '0';
 psm_s15 <= '1' when (pgm_sm  =  "001111") else '0';
 psm_s16 <= '1' when (pgm_sm  =  "010000") else '0';
 psm_s17 <= '1' when (pgm_sm  =  "010001") else '0';
 psm_s18 <= '1' when (pgm_sm  =  "010010") else '0';
 psm_s19 <= '1' when (pgm_sm  =  "010011") else '0';
 psm_s20 <= '1' when (pgm_sm  =  "010100") else '0';
 psm_s21 <= '1' when (pgm_sm  =  "010101") else '0';
 psm_s22 <= '1' when (pgm_sm  =  "010110") else '0';
 psm_s23 <= '1' when (pgm_sm  =  "010111") else '0';
 psm_s24 <= '1' when (pgm_sm  =  "011000") else '0';
 psm_s25 <= '1' when (pgm_sm  =  "011001") else '0';
 psm_s26 <= '1' when (pgm_sm  =  "011010") else '0';
 psm_s27 <= '1' when (pgm_sm  =  "011011") else '0';
 psm_s28 <= '1' when (pgm_sm  =  "011100") else '0';
 psm_s29 <= '1' when (pgm_sm  =  "011101") else '0';
 psm_s30 <= '1' when (pgm_sm  =  "011110") else '0';
 psm_s31 <= '1' when (pgm_sm  =  "011111") else '0';
 psm_s32 <= '1' when (pgm_sm  =  "100000") else '0';


 psm_nxt_s00 <= '1' when (pgm_sm_nxt  =  "000000") else '0';
 psm_nxt_s01 <= '1' when (pgm_sm_nxt  =  "000001") else '0';
 psm_nxt_s02 <= '1' when (pgm_sm_nxt  =  "000010") else '0';
 psm_nxt_s03 <= '1' when (pgm_sm_nxt  =  "000011") else '0';
 psm_nxt_s04 <= '1' when (pgm_sm_nxt  =  "000100") else '0';
 psm_nxt_s05 <= '1' when (pgm_sm_nxt  =  "000101") else '0';
 psm_nxt_s06 <= '1' when (pgm_sm_nxt  =  "000110") else '0';
 psm_nxt_s07 <= '1' when (pgm_sm_nxt  =  "000111") else '0';
 psm_nxt_s08 <= '1' when (pgm_sm_nxt  =  "001000") else '0';
 psm_nxt_s09 <= '1' when (pgm_sm_nxt  =  "001001") else '0';
 psm_nxt_s10 <= '1' when (pgm_sm_nxt  =  "001010") else '0';
 psm_nxt_s11 <= '1' when (pgm_sm_nxt  =  "001011") else '0';
 psm_nxt_s12 <= '1' when (pgm_sm_nxt  =  "001100") else '0';
 psm_nxt_s13 <= '1' when (pgm_sm_nxt  =  "001101") else '0';
 psm_nxt_s14 <= '1' when (pgm_sm_nxt  =  "001110") else '0';
 psm_nxt_s15 <= '1' when (pgm_sm_nxt  =  "001111") else '0';
 psm_nxt_s16 <= '1' when (pgm_sm_nxt  =  "010000") else '0';
 psm_nxt_s17 <= '1' when (pgm_sm_nxt  =  "010001") else '0';
 psm_nxt_s18 <= '1' when (pgm_sm_nxt  =  "010010") else '0';
 psm_nxt_s19 <= '1' when (pgm_sm_nxt  =  "010011") else '0';
 psm_nxt_s20 <= '1' when (pgm_sm_nxt  =  "010100") else '0';
 psm_nxt_s21 <= '1' when (pgm_sm_nxt  =  "010101") else '0';
 psm_nxt_s22 <= '1' when (pgm_sm_nxt  =  "010110") else '0';
 psm_nxt_s23 <= '1' when (pgm_sm_nxt  =  "010111") else '0';
 psm_nxt_s24 <= '1' when (pgm_sm_nxt  =  "011000") else '0';
 psm_nxt_s25 <= '1' when (pgm_sm_nxt  =  "011001") else '0';
 psm_nxt_s26 <= '1' when (pgm_sm_nxt  =  "011010") else '0';
 psm_nxt_s27 <= '1' when (pgm_sm_nxt  =  "011011") else '0';
 psm_nxt_s28 <= '1' when (pgm_sm_nxt  =  "011100") else '0';
 psm_nxt_s29 <= '1' when (pgm_sm_nxt  =  "011101") else '0';
 psm_nxt_s30 <= '1' when (pgm_sm_nxt  =  "011110") else '0';
 psm_nxt_s31 <= '1' when (pgm_sm_nxt  =  "011111") else '0';
 psm_nxt_s32 <= '1' when (pgm_sm_nxt  =  "100000") else '0';


 -- -- End Section -- --
--============================================================================================
---- Read Flash
--==============================================================================================--
 -- ----------------------------------- --
 -- Next State Equations and SM Latch   --
 -- ----------------------------------- --
    ---- States 0-8  : Read/Reset Command
    ---- State 0  : Activate CE Drive Data & Addr       addr 0000555 data 00aa
    ---- State 1  : Activate WE (Delay 14 clocks)
    ---- State 2  : Deactivate WE

    ---- State 3  : Activate CE Drive Data & Addr       addr 00002aa data 0055
    ---- State 4  : Activate WE (Delay 14 clocks)
    ---- State 5  : Deactivate WE

    ---- State 6  : Activate CE Drive Data & Addr       addr 0000000 data 00f0
    ---- State 7  : Activate WE (Delay 14 clocks)
    ---- State 8  : Deactivate WE

    ---- State 9  : Drive Next Data (Delay 5 clocks)                                        ----
    ---- State 10 : Tristate Data (Delay 6 clocks)                                          ----
    ---- State 11 : Activate OE (Delay 35 clocks)                                           ----
    ----            Nxt State 11 Access time not met                                         ----
    ----            Nxt State 12 Access time met                                             ----
    ---- State 12 : Latch Data                             <- Read Data & Vext Address      ----
    ----            Nxt State 11 if more data to read          - Read next data              ----
    ----            Nxt State 13 if complete                   - Buffer Available            ----
    ---- State 13 : Deactivate OE                                                           ----
    ---- State 14 : Delay 6 clocks for min CE High         <- No more buffers to program    ----
    ---- State 15 : Read Complete - Wait for done          <- Read is Complete              ----
    ----            Nxt State 00 if read sequence is done (~read_flash)                     ----


    ---- Next State Controls ----
    rsm_rst <= rsm_s15  or   not read_flash ;

    -- add read_flash to this expression to force rsm to good state on error
    rsm_rd_nxt_wrd <= (read_flash and rsm_s12   and   not rsm_done) ;                      -- Continue reading data until complete                  --

    rsm_p1 <=  not (rsm_rst  or  rsm_rd_nxt_wrd) ;                                          -- Increment to next state                               --
    -----------------------------

    ---- Next State ----
    read_sm_p1 <= std_logic_vector(unsigned(read_sm) + 1);
    read_sm_nxt <= gate_and(rsm_p1,read_sm_p1) or
                   gate_and(rsm_rd_nxt_wrd,"01011") or
                   gate_and(rsm_rst,"00000");


    --------------------

    -- Next State Latch and advance control --
    rsm_adv <= ( (dly_done  and   not rsm_s15 )  or                                         -- Advance State Machine when delay is done                       --
                 (dly_done  and   rsm_s15  and   not read_flash  ) )  and                   -- Advance State Machine when read is complete                    --
               not (dly_done  and   rsm_s11  and  f_read_data_valinternal and read_flash) ; -- Do not advance if interface is not ready to receive data       --

    endff_read_sm: capi_en_rise_vdff GENERIC MAP ( width => 5 ) PORT MAP (
         dout => read_sm,
         en => rsm_adv,
         din => read_sm_nxt,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Read Address                        --
 -- ----------------------------------- --
    rsm_wrdadr_p1 <= std_logic_vector(unsigned(rsm_wrdadr_q) + 1);

    rd_start_addr <= ( f_read_start_addr(1 to 25) & '0' );

    rsm_wrdadr_d <= rd_start_addr when rsm_s02='1' else rsm_wrdadr_p1;

    rsm_update_wrdadr <= ( (rsm_s02  or  rsm_s12) and rsm_adv ) ;

    endff_rsm_wrdadr_q: capi_en_rise_vdff GENERIC MAP ( width => 26 ) PORT MAP (
         dout => rsm_wrdadr_q,
         en => rsm_update_wrdadr,
         din => rsm_wrdadr_d,
         clk   => psl_clk
    );


 -- -- End Section -- --
 -- ----------------------------------- --
 -- Count of Words to read              --
 -- ----------------------------------- --
    rsm_wrdcnt_m1 <= std_logic_vector(unsigned(rsm_wrdcnt_q) - 1);

    rsm_wrdcnt_d <= f_num_words_m1 when rsm_s02='1' else rsm_wrdcnt_m1;

    rsm_update_wrdcnt <= ( rsm_s02  or  (f_read_data_valinternal  and  f_read_data_ack  and   not rsm_done) ) ;

    endff_rsm_wrdcnt_q: capi_en_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => rsm_wrdcnt_q,
         en => rsm_update_wrdcnt,
         din => rsm_wrdcnt_d,
         clk   => psl_clk
    );


 -- -- End Section -- --
 -- ----------------------------------- --
 -- Read SM Outputs                     --
 -- ----------------------------------- --
    -- -- read address -- --
    read_addr(0 to 25) <=
                      gate_and(rsm_s00,"00" & x"000555") or
                      gate_and(rsm_s01,"00" & x"000555") or
                      gate_and(rsm_s02,"00" & x"000555") or
                      gate_and(rsm_s03,"00" & x"0002aa") or
                      gate_and(rsm_s04,"00" & x"0002aa") or
                      gate_and(rsm_s05,"00" & x"0002aa") or
                      gate_and(rsm_s06,"00" & x"000555") or
                      gate_and(rsm_s07,"00" & x"000555") or
                      gate_and(rsm_s08,"00" & x"000555") or
                      gate_and(rsm_s09, rsm_wrdadr_q) or
                      gate_and(rsm_s10, rsm_wrdadr_q) or
                      gate_and(rsm_s11, rsm_wrdadr_q) or
                      gate_and(rsm_s12, rsm_wrdadr_q) or
                      gate_and(rsm_s13, rsm_wrdadr_q);


    -- -- latch input data ----
    rsm_datain_en <= rsm_s12 ;

    -- -- output data ----
    read_data_out(0 to 31) <=
                      gate_and((rsm_s00 and read_flash) ,x"00aa00aa") or
                      gate_and(rsm_s01,x"00aa00aa") or
                      gate_and(rsm_s02,x"00aa00aa") or
                      gate_and(rsm_s03,x"00550055") or
                      gate_and(rsm_s04,x"00550055") or
                      gate_and(rsm_s05,x"00550055") or
                      gate_and(rsm_s06,x"00f000f0") or
                      gate_and(rsm_s07,x"00f000f0") or
                      gate_and(rsm_s08,x"00f000f0");

    -- -------------------

    rsm_done <= read_addr(25) when (rsm_wrdcnt_q  =  Z_v10bit) else '0';

    rsm_more_dat <=  '0' when (rsm_wrdcnt_q  =  Z_v10bit) else '1';

    read_complete <= rsm_s15  and   not f_read_data_valinternal ;

    read_ce <= (read_flash  and   not (rsm_s14  or  rsm_s15)) ;

    read_we <= rsm_s01 or rsm_s04 or rsm_s07;

    read_oe <= rsm_s11   or  rsm_s12 ;

    read_dat_oe <= read_flash  and   not (rsm_s10   or  rsm_s11   or  rsm_s12   or
                                      rsm_s13   or  rsm_s14   or  rsm_s15  ) ;

    -- -- Read Data Valid -- --
    read_data_val_d <= (rsm_s12 and rsm_adv  and  read_addr(25))  or  (f_read_data_valinternal  and   not f_read_data_ack and read_flash) ;

    dff_f_read_data_val: capi_rise_dff PORT MAP (
         dout => f_read_data_valinternal,
         din => read_data_val_d,
         clk   => psl_clk
    );

    -- --------------------- --
 -- -- End Section -- --
 -- ----------------------------------- --
 -- Cycle Delay Control                 --
 -- ----------------------------------- --
    rsm_sel_WEL_dly <= ( rsm_nxt_s01 or rsm_nxt_s04 or rsm_nxt_s07 )  and  read_flash ;

    rsm_sel_WEH_dly <= ( rsm_nxt_s02 or rsm_nxt_s05 or rsm_nxt_s08 )  and  read_flash ;

    rsm_sel_FTD_dly <= ( rsm_nxt_s10 )  and  read_flash ;

    rsm_sel_CEH_dly <= ( rsm_nxt_s14 )  and  read_flash ;

    rsm_sel_RCT_dly <= ( rsm_nxt_s11 )  and  read_flash ;

    rsm_no_dly_sel <=  not (rsm_sel_WEL_dly  or  rsm_sel_WEH_dly  or  rsm_sel_FTD_dly  or  rsm_sel_CEH_dly  or  rsm_sel_RCT_dly)  or
                           not read_flash ;

    -- Value for delay is n-1, 0 is no delay or 1 cycle --
    read_dly <= gate_and(rsm_sel_WEL_dly,"00111111") or
                gate_and(rsm_sel_WEH_dly,"00111111") or
                gate_and(rsm_sel_FTD_dly,"00111111") or
                gate_and(rsm_sel_CEH_dly,"00111111") or
                gate_and(rsm_sel_RCT_dly,"00111111") or
                gate_and(rsm_no_dly_sel,"00111111");

    -- No Delay. 1 cycle state transistion. --

    read_sm_start_dly <= (  not rsm_nxt_s00  and  dly_done ) ;
 -- ----------------------------------- --
 -- Program SM Decodes                  --
 -- ----------------------------------- --

 rsm_s00 <= '1' when (read_sm  =  "00000") else '0';
 rsm_s01 <= '1' when (read_sm  =  "00001") else '0';
 rsm_s02 <= '1' when (read_sm  =  "00010") else '0';
 rsm_s03 <= '1' when (read_sm  =  "00011") else '0';
 rsm_s04 <= '1' when (read_sm  =  "00100") else '0';
 rsm_s05 <= '1' when (read_sm  =  "00101") else '0';
 rsm_s06 <= '1' when (read_sm  =  "00110") else '0';
 rsm_s07 <= '1' when (read_sm  =  "00111") else '0';
 rsm_s08 <= '1' when (read_sm  =  "01000") else '0';
 rsm_s09 <= '1' when (read_sm  =  "01001") else '0';
 rsm_s10 <= '1' when (read_sm  =  "01010") else '0';
 rsm_s11 <= '1' when (read_sm  =  "01011") else '0';
 rsm_s12 <= '1' when (read_sm  =  "01100") else '0';
 rsm_s13 <= '1' when (read_sm  =  "01101") else '0';
 rsm_s14 <= '1' when (read_sm  =  "01110") else '0';
 rsm_s15 <= '1' when (read_sm  =  "01111") else '0';

 rsm_nxt_s00 <= '1' when (read_sm_nxt  =  "00000") else '0';
 rsm_nxt_s01 <= '1' when (read_sm_nxt  =  "00001") else '0';
 rsm_nxt_s02 <= '1' when (read_sm_nxt  =  "00010") else '0';
 rsm_nxt_s03 <= '1' when (read_sm_nxt  =  "00011") else '0';
 rsm_nxt_s04 <= '1' when (read_sm_nxt  =  "00100") else '0';
 rsm_nxt_s05 <= '1' when (read_sm_nxt  =  "00101") else '0';
 rsm_nxt_s06 <= '1' when (read_sm_nxt  =  "00110") else '0';
 rsm_nxt_s07 <= '1' when (read_sm_nxt  =  "00111") else '0';
 rsm_nxt_s08 <= '1' when (read_sm_nxt  =  "01000") else '0';
 rsm_nxt_s09 <= '1' when (read_sm_nxt  =  "01001") else '0';
 rsm_nxt_s10 <= '1' when (read_sm_nxt  =  "01010") else '0';
 rsm_nxt_s11 <= '1' when (read_sm_nxt  =  "01011") else '0';
 rsm_nxt_s12 <= '1' when (read_sm_nxt  =  "01100") else '0';
 rsm_nxt_s13 <= '1' when (read_sm_nxt  =  "01101") else '0';
 rsm_nxt_s14 <= '1' when (read_sm_nxt  =  "01110") else '0';
 rsm_nxt_s15 <= '1' when (read_sm_nxt  =  "01111") else '0';

  f_read_data_val <= f_read_data_valinternal;

--Extra debug info to vsec
    f_states <= main_sm & erase_sm & "00" & pgm_sm & "00" & read_sm & "000";

    capture_status_reg <= (esm_s23 and esm_adv) or ((psm_s24) and psm_adv);

    endff_memstat_int: capi_en_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => f_memstat_int,
         en => capture_status_reg,
         din => flash_datain_d,
         clk   => psl_clk
    );

    reversebus_f_memstat_int2: capi_reversebus16
      PORT MAP (
         dest => f_memstat_int2,
         din => f_memstat_int
    );
    f_memstat <= f_memstat_int2;

    endff_memstat_past: capi_en_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => f_memstat_past,
         en => capture_status_reg,
         din => f_memstat_int2,
         clk   => psl_clk
    );


END capi_flash;
