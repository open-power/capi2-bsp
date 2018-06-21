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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use UNISIM.vcomponents.all;

ENTITY capi_ptmon IS
  PORT(psl_clk: in std_logic;

       -- -------------- --
       mon_power: out std_logic_vector(0 to 15);
       mon_temperature: out std_logic_vector(0 to 15);
       mon_enable: in std_logic;
       aptm_req: in std_logic;
       ptma_grant: out std_logic);

END capi_ptmon;



ARCHITECTURE capi_ptmon OF capi_ptmon IS

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


Signal ONE_v20bit: std_logic_vector(0 to 19);  -- v20bit
Signal ONE_v2bit: std_logic_vector(0 to 1);  -- v2bit
Signal addr: std_logic_vector(0 to 6);  -- v7bit
Signal adv_sm: std_logic;  -- bool
Signal blk_op: std_logic;  -- bool
Signal bytecnt: std_logic_vector(0 to 7);  -- v8bit
Signal cmd: std_logic_vector(0 to 7);  -- v8bit
Signal cmdval: std_logic;  -- bool
Signal cntlrsel: std_logic_vector(0 to 2);  -- v3bit
Signal current12v: std_logic_vector(0 to 15);  -- v16bit
Signal current12v_q: std_logic_vector(0 to 10);  -- v11bit
Signal current12v_q_sr1: std_logic_vector(0 to 26);  -- v27bit
Signal current12v_q_unshifted: std_logic_vector(0 to 26);  -- v27bit
Signal current12v_shift_total: std_logic_vector(0 to 7);  -- v8bit
Signal current12v_use: std_logic_vector(0 to 26);  -- v27bit
Signal current12v_use_q2: std_logic_vector(0 to 26);  -- v27bit
Signal current3_3v: std_logic_vector(0 to 15);  -- v16bit
Signal current3_3v_q: std_logic_vector(0 to 10);  -- v11bit
Signal current3_3v_q_sr1: std_logic_vector(0 to 26);  -- v27bit
Signal current3_3v_q_unshifted: std_logic_vector(0 to 26);  -- v27bit
Signal current3_3v_shift_total: std_logic_vector(0 to 7);  -- v8bit
Signal current3_3v_use: std_logic_vector(0 to 26);  -- v27bit
Signal current3_3v_use_q2: std_logic_vector(0 to 26);  -- v27bit
Signal datavalmuxed: std_logic;  -- bool
Signal done_last_rail: std_logic;  -- bool
Signal err_detect: std_logic;  -- bool
Signal error: std_logic;  -- bool
Signal ha_req: std_logic;  -- bool
Signal ha_req_d: std_logic;  -- bool
Signal host_error: std_logic;  -- bool
Signal host_ready: std_logic;  -- bool
Signal host_wrdatack: std_logic;  -- bool
Signal hosti2c_dataval: std_logic;  -- bool
Signal i2chost_dataval: std_logic;  -- bool
Signal iout_hi12v: std_logic_vector(0 to 7);  -- v8bit
Signal iout_hi12v_en: std_logic;  -- bool
Signal iout_hi3_3v: std_logic_vector(0 to 7);  -- v8bit
Signal iout_hi3_3v_en: std_logic;  -- bool
Signal iout_lo12v: std_logic_vector(0 to 7);  -- v8bit
Signal iout_lo12v_en: std_logic;  -- bool
Signal iout_lo3_3v: std_logic_vector(0 to 7);  -- v8bit
Signal iout_lo3_3v_en: std_logic;  -- bool
Signal last_rail: std_logic;  -- bool
Signal mi2c_datain_d: std_logic_vector(0 to 7);  -- v8bit
Signal mi2c_rd_in: std_logic;  -- bool
Signal nxt_state: std_logic_vector(0 to 14);  -- v15bit
Signal poll_datain: std_logic_vector(0 to 7);  -- v8bit
Signal poll_one_byte: std_logic;  -- bool
Signal poll_read: std_logic;  -- bool
Signal poll_two_byte: std_logic;  -- bool
Signal polli2c_dataval: std_logic;  -- bool
Signal power12v: std_logic_vector(0 to 31);  -- v32bit
Signal power12v_q3: std_logic_vector(0 to 31);  -- v32bit
Signal power12v_q3_add: std_logic_vector(0 to 32);  -- v33bit
Signal power3_3v: std_logic_vector(0 to 31);  -- v32bit
Signal power3_3v_q3: std_logic_vector(0 to 31);  -- v32bit
Signal power3_3v_q3_add: std_logic_vector(0 to 32);  -- v33bit
Signal ptm_s0x0: std_logic;  -- bool
Signal ptm_s0x1: std_logic;  -- bool
Signal ptm_s0x2: std_logic;  -- bool
Signal ptm_s0x3: std_logic;  -- bool
Signal ptm_s0x4: std_logic;  -- bool
Signal ptm_s0x5: std_logic;  -- bool
Signal ptm_s0x6: std_logic;  -- bool
Signal ptm_s0x7: std_logic;  -- bool
Signal ptm_s0x8: std_logic;  -- bool
Signal ptm_s0x9: std_logic;  -- bool
Signal ptm_s0xA: std_logic;  -- bool
Signal ptm_s0xB: std_logic;  -- bool
Signal ptm_s0xC: std_logic;  -- bool
Signal ptm_s0xD: std_logic;  -- bool
Signal ptm_s0xE: std_logic;  -- bool
Signal ptm_s0xF: std_logic;  -- bool
Signal ptm_sm: std_logic_vector(0 to 14);  -- v15bit
Signal ptm_sm_nxt: std_logic_vector(0 to 14);  -- v15bit
Signal rail_select: std_logic_vector(0 to 1);  -- v2bit
Signal rail_select_d: std_logic_vector(0 to 1);  -- v2bit
Signal rail_select_p1: std_logic_vector(0 to 1);  -- v2bit
Signal rd_op: std_logic;  -- bool
Signal read_iout_cmd: std_logic_vector(0 to 7);  -- v8bit
Signal read_vmode_cmd: std_logic_vector(0 to 7);  -- v8bit
Signal read_vout_cmd: std_logic_vector(0 to 7);  -- v8bit
Signal s9_dataval: std_logic;  -- bool
Signal s9_got_data: std_logic;  -- bool
Signal s9_got_data_d: std_logic;  -- bool
Signal sel_diag_nxt: std_logic;  -- bool
Signal sel_host: std_logic;  -- bool
Signal sel_host_nxt: std_logic;  -- bool
Signal sel_next_rail: std_logic;  -- bool
Signal sel_nxt_state: std_logic;  -- bool
Signal sel_poll_nxt: std_logic;  -- bool
Signal sel_rail0: std_logic;  -- bool
Signal sel_rail1: std_logic;  -- bool
Signal sel_railA: std_logic;  -- bool
Signal sel_ucd_iout: std_logic;  -- bool
Signal sel_ucd_page: std_logic;  -- bool
Signal sel_ucd_vmode: std_logic;  -- bool
Signal sel_ucd_vout: std_logic;  -- bool
Signal sel_wait_nxt: std_logic;  -- bool
Signal send_page0_high: std_logic_vector(0 to 7);  -- v8bit
Signal shr_mag: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_i12v: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_i12v_q: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_i3_3v: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_i3_3v_q: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_q: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_v12v: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_v12v_q: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_v3_3v: std_logic_vector(0 to 4);  -- v5bit
Signal shr_mag_v3_3v_q: std_logic_vector(0 to 4);  -- v5bit
Signal sr1: std_logic_vector(0 to 27);  -- v28bit
Signal sr1_i12v: std_logic_vector(0 to 26);  -- v27bit
Signal sr1_i12v_shift2: std_logic_vector(0 to 26);  -- v27bit
Signal sr1_i3_3v: std_logic_vector(0 to 26);  -- v27bit
Signal sr1_i3_3v_shift2: std_logic_vector(0 to 26);  -- v27bit
Signal sr1_shift2: std_logic_vector(0 to 27);  -- v28bit
Signal sr1_v12v: std_logic_vector(0 to 31);  -- v32bit
Signal sr1_v12v_shift2: std_logic_vector(0 to 31);  -- v32bit
Signal sr1_v3_3v: std_logic_vector(0 to 31);  -- v32bit
Signal sr1_v3_3v_shift2: std_logic_vector(0 to 31);  -- v32bit
Signal sr2: std_logic_vector(0 to 27);  -- v28bit
Signal sr2_i12v: std_logic_vector(0 to 26);  -- v27bit
Signal sr2_i12v_shift4: std_logic_vector(0 to 26);  -- v27bit
Signal sr2_i3_3v: std_logic_vector(0 to 26);  -- v27bit
Signal sr2_i3_3v_shift4: std_logic_vector(0 to 26);  -- v27bit
Signal sr2_shift4: std_logic_vector(0 to 27);  -- v28bit
Signal sr2_v12v: std_logic_vector(0 to 31);  -- v32bit
Signal sr2_v12v_shift4: std_logic_vector(0 to 31);  -- v32bit
Signal sr2_v3_3v: std_logic_vector(0 to 31);  -- v32bit
Signal sr2_v3_3v_shift4: std_logic_vector(0 to 31);  -- v32bit
Signal sr3: std_logic_vector(0 to 27);  -- v28bit
Signal sr3_i12v: std_logic_vector(0 to 26);  -- v27bit
Signal sr3_i12v_shift8: std_logic_vector(0 to 26);  -- v27bit
Signal sr3_i3_3v: std_logic_vector(0 to 26);  -- v27bit
Signal sr3_i3_3v_shift8: std_logic_vector(0 to 26);  -- v27bit
Signal sr3_shift8: std_logic_vector(0 to 27);  -- v28bit
Signal sr3_v12v: std_logic_vector(0 to 31);  -- v32bit
Signal sr3_v12v_shift8: std_logic_vector(0 to 31);  -- v32bit
Signal sr3_v3_3v: std_logic_vector(0 to 31);  -- v32bit
Signal sr3_v3_3v_shift8: std_logic_vector(0 to 31);  -- v32bit
Signal sr4: std_logic_vector(0 to 27);  -- v28bit
Signal sr4_i12v: std_logic_vector(0 to 26);  -- v27bit
Signal sr4_i12v_shift16: std_logic_vector(0 to 26);  -- v27bit
Signal sr4_i3_3v: std_logic_vector(0 to 26);  -- v27bit
Signal sr4_i3_3v_shift16: std_logic_vector(0 to 26);  -- v27bit
Signal sr4_shift16: std_logic_vector(0 to 27);  -- v28bit
Signal sr4_v12v: std_logic_vector(0 to 31);  -- v32bit
Signal sr4_v12v_shift16: std_logic_vector(0 to 31);  -- v32bit
Signal sr4_v3_3v: std_logic_vector(0 to 31);  -- v32bit
Signal sr4_v3_3v_shift16: std_logic_vector(0 to 31);  -- v32bit
Signal temp_mant: std_logic_vector(0 to 15);  -- v16bit
Signal temperature: std_logic_vector(0 to 27);  -- v28bit
Signal tmp_hi: std_logic_vector(0 to 7);  -- v8bit
Signal tmp_hi_en: std_logic;  -- bool
Signal tmp_lo: std_logic_vector(0 to 7);  -- v8bit
Signal tmp_lo_en: std_logic;  -- bool
Signal tmp_mode: std_logic_vector(0 to 7);  -- v8bit
Signal tmp_mode_en: std_logic;  -- bool
Signal tmp_scaled: std_logic_vector(0 to 19);  -- v20bit
Signal tmp_scaled_q: std_logic_vector(0 to 19);  -- v20bit
Signal tmp_scaled_q_sr1: std_logic_vector(0 to 27);  -- v28bit
Signal tmp_scaled_q_unshifted: std_logic_vector(0 to 27);  -- v28bit
Signal tmp_shift_total: std_logic_vector(0 to 7);  -- v8bit
Signal total_power: std_logic_vector(0 to 32);  -- v33bit
Signal ucd90120a_adr: std_logic_vector(0 to 6);  -- v7bit
Signal update_power12v: std_logic;  -- bool
Signal update_power12v_q: std_logic;  -- bool
Signal update_power12v_q2: std_logic;  -- bool
Signal update_power12v_q3: std_logic;  -- bool
Signal update_power3_3v: std_logic;  -- bool
Signal update_power3_3v_q: std_logic;  -- bool
Signal update_power3_3v_q2: std_logic;  -- bool
Signal update_power3_3v_q3: std_logic;  -- bool
Signal update_rail: std_logic;  -- bool
Signal update_s9_got_data: std_logic;  -- bool
Signal update_temp: std_logic;  -- bool
Signal update_temp_q: std_logic;  -- bool
--Signal version: std_logic_vector(0 to 31);  -- int
Signal vmode12v: std_logic_vector(0 to 7);  -- v8bit
Signal vmode12v_en: std_logic;  -- bool
Signal vmode3_3v: std_logic_vector(0 to 7);  -- v8bit
Signal vmode3_3v_en: std_logic;  -- bool
Signal voltage12v: std_logic_vector(0 to 15);  -- v16bit
Signal voltage12v_q: std_logic_vector(0 to 15);  -- v16bit
Signal voltage12v_q_sr1: std_logic_vector(0 to 31);  -- v32bit
Signal voltage12v_q_unshifted: std_logic_vector(0 to 31);  -- v32bit
Signal voltage12v_use: std_logic_vector(0 to 31);  -- v32bit
Signal voltage12v_use_q2: std_logic_vector(0 to 31);  -- v32bit
Signal voltage3_3v: std_logic_vector(0 to 15);  -- v16bit
Signal voltage3_3v_q: std_logic_vector(0 to 15);  -- v16bit
Signal voltage3_3v_q_sr1: std_logic_vector(0 to 31);  -- v32bit
Signal voltage3_3v_q_unshifted: std_logic_vector(0 to 31);  -- v32bit
Signal voltage3_3v_use: std_logic_vector(0 to 31);  -- v32bit
Signal voltage3_3v_use_q2: std_logic_vector(0 to 31);  -- v32bit
Signal vout12v_shift_total: std_logic_vector(0 to 7);  -- v8bit
Signal vout3_3v_shift_total: std_logic_vector(0 to 7);  -- v8bit
Signal vout_hi12v: std_logic_vector(0 to 7);  -- v8bit
Signal vout_hi12v_en: std_logic;  -- bool
Signal vout_hi3_3v: std_logic_vector(0 to 7);  -- v8bit
Signal vout_hi3_3v_en: std_logic;  -- bool
Signal vout_lo12v: std_logic_vector(0 to 7);  -- v8bit
Signal vout_lo12v_en: std_logic;  -- bool
Signal vout_lo3_3v: std_logic_vector(0 to 7);  -- v8bit
Signal vout_lo3_3v_en: std_logic;  -- bool
Signal wait_done: std_logic;  -- bool
Signal waitcnt: std_logic_vector(0 to 19);  -- v20bit
Signal waitcnt_d: std_logic_vector(0 to 19);  -- v20bit
Signal waitcnt_en: std_logic;  -- bool
Signal waitcnt_nxt: std_logic_vector(0 to 19);  -- v20bit

Signal DO: std_logic_vector(0 to 15);
Signal DRDY: std_logic;
Signal DADDR: std_logic_vector(0 to 7);
Signal DCLK: std_logic;
Signal DEN: std_logic;
Signal DWE: std_logic;
Signal DI: std_logic_vector(0 to 15);

Signal drp_en: std_logic;
Signal drp_ready: std_logic;
Signal drp_ready_q1: std_logic;
Signal drp_ready_q2: std_logic;
Signal drp_dout: std_logic_vector(0 to 15);
Signal op_pending_d: std_logic;
Signal op_pending: std_logic;
Signal temp_data_d: std_logic_vector(0 to 9);
Signal temp_data: std_logic_vector(0 to 9);
Signal xfer_factor: std_logic_vector(0 to 17);
Signal temp_kelvin: std_logic_vector(0 to 35);
Signal temp_kelvin_q1: std_logic_vector(0 to 35);
Signal temp_celsius: std_logic_vector(0 to 36);
Signal temp_current: std_logic_vector(0 to 15);

begin


--    version <= "00000000000000000000000000000111" ;

--Xilinx system monitor
SYSMONE1_inst : SYSMONE1
generic map(
        INIT_40 => X"0000", -- config reg 0
        INIT_41 => X"318F", -- config reg 1
        INIT_42 => X"3100", -- config reg 2
        INIT_43 => X"200F", -- config reg 3
        INIT_45 => X"DEDC", -- Analog Bus Register
        INIT_46 => X"0000", -- Sequencer Channel selection (Vuser0-3)
        INIT_47 => X"0000", -- Sequencer Average selection (Vuser0-3)
        INIT_48 => X"0100", -- Sequencer channel selection
        INIT_49 => X"0000", -- Sequencer channel selection
        INIT_4A => X"0000", -- Sequencer Average selection
        INIT_4B => X"0000", -- Sequencer Average selection
        INIT_4C => X"0000", -- Sequencer Bipolar selection
        INIT_4D => X"0000", -- Sequencer Bipolar selection
        INIT_4E => X"0000", -- Sequencer Acq time selection
        INIT_4F => X"0000", -- Sequencer Acq time selection
        INIT_50 => X"B723", -- Temp alarm trigger
        INIT_51 => X"4E81", -- Vccint upper alarm limit
        INIT_52 => X"A147", -- Vccaux upper alarm limit
        INIT_53 => X"CA33", -- Temp alarm OT upper
        INIT_54 => X"AA5F", -- Temp alarm reset
        INIT_55 => X"4963", -- Vccint lower alarm limit
        INIT_56 => X"9555", -- Vccaux lower alarm limit
        INIT_57 => X"AE4E", -- Temp alarm OT reset
        INIT_58 => X"4E81", -- Vccbram upper alarm limit
        INIT_5C => X"4963", -- Vbccram lower alarm limit
        INIT_60 => X"9A74", -- Vuser0 upper alarm limit
        INIT_61 => X"4DA6", -- Vuser1 upper alarm limit
        INIT_62 => X"9A74", -- Vuser2 upper alarm limit
        INIT_63 => X"4D39", -- Vuser3 upper alarm limit
        INIT_68 => X"98BF", -- Vuser0 lower alarm limit
        INIT_69 => X"4BF2", -- Vuser1 lower alarm limit
        INIT_6A => X"98BF", -- Vuser2 lower alarm limit
        INIT_6B => X"4C5E", -- Vuser3 lower alarm limit
        SIM_MONITOR_FILE => "design.txt"
)
port map (
--Reset and control
RESET => '0',
CONVST => '0',
CONVSTCLK => '0',
--Dedicated Analog input
VP => '0',
VN => '0',
--Auxilliary Analog inputs
VAUXP => X"0000",
VAUXN => X"0000",
--DRP I2C interface
I2C_SCLK => '0',
I2C_SDA => '0',
--DRP Port
DO => DO,
DRDY => DRDY,
DADDR => DADDR,
DCLK => DCLK,
DEN => DEN,
DI => DI,
DWE => DWE
);

DADDR <= X"00";
DWE <= '0';
DI <= X"0000";
DCLK <= psl_clk;
DEN <= drp_en;

drp_ready <= DRDY;
drp_dout <= DO;

--
 -- ----------------------------------- --
 -- Opeartion Tracking    --
 -- ----------------------------------- --
    op_pending_d <= '1' when ((drp_ready = '0') and (mon_enable = '1') and (op_pending = '0')) else
                    '0' when (drp_ready = '1') else
                    op_pending ;

    dff_op_pending: capi_rise_dff PORT MAP (
         dout => op_pending,
         din => op_pending_d,
         clk   => psl_clk
    );

   drp_en <= op_pending_d and not(op_pending);

   temp_data_d <= drp_dout(0 to 9) when (drp_ready = '1') else
                  temp_data;
    dff_temp_data: capi_rise_vdff GENERIC MAP ( width => 10 ) PORT MAP (
         dout => temp_data,
         din => temp_data_d,
         clk   => psl_clk
    );

    dff_drp_ready_q1: capi_rise_dff PORT MAP (
         dout => drp_ready_q1,
         din => drp_ready,
         clk   => psl_clk
    );
    dff_drp_ready_q2: capi_rise_dff PORT MAP (
         dout => drp_ready_q2,
         din => drp_ready_q1,
         clk   => psl_clk
    );

 -- ----------------------------------- --
 -- Format Temperature Reading    --
 -- ----------------------------------- --

--xfer function is (ACD data) * (.4896) [501.3743/2^bits] - 273.6777 = Temperature in degrees Celsius. Xilinx ultrascale sysmon equation for on-chip temperature reference
xfer_factor <= "00" & X"007D";
temp_kelvin <= std_logic_vector(unsigned(temp_data & X"00") * unsigned(xfer_factor));--20.16

    dff_temp_kelvin_q1: capi_rise_vdff GENERIC MAP ( width => 36 ) PORT MAP (
         dout => temp_kelvin_q1,
         din => temp_kelvin,
         clk   => psl_clk
    );

temp_celsius <= std_logic_vector(unsigned('0' & temp_kelvin_q1) - ('0' & X"00111AD7A"));

    dff_temp_current: capi_en_rise_vdff GENERIC MAP ( width => 16 ) PORT MAP (
         dout => temp_current,
         en => drp_ready_q2,
         din => temp_celsius(13 to 28),
         clk   => psl_clk
    );

 -- ----------------------------------- --
 -- Output Assignment    --
 -- ----------------------------------- --

  ptma_grant <= '0';
  mon_power <= X"0000";
  mon_temperature <= temp_current;--Capture 8.8 decimal format for psl reg

END capi_ptmon;
