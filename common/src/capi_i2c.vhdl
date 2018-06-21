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

ENTITY capi_i2c IS
  PORT(psl_clk: in std_logic;

       -- --------------- --
       i2c0_scl_out: out std_logic;
       i2c0_scl_in: in std_logic;
       i2c0_sda_out: out std_logic;
       i2c0_sda_in: in std_logic;

       -- -------------- --
       mi2c_cmdval: in std_logic;
       mi2c_dataval: in std_logic;
       mi2c_addr: in std_logic_vector(0 to 6);
       mi2c_rd: in std_logic;
       mi2c_cmdin: in std_logic_vector(0 to 7);
       mi2c_datain: in std_logic_vector(0 to 7);
       mi2c_blk: in std_logic;
       mi2c_bytecnt: in std_logic_vector(0 to 7);
       mi2c_cntlrsel: in std_logic_vector(0 to 2);
       i2cm_wrdatack: out std_logic;
       i2cm_dataval: out std_logic;
       i2cm_error: out std_logic;
       i2cm_dataout: out std_logic_vector(0 to 7);
       i2cm_ready: out std_logic);

END capi_i2c;

ARCHITECTURE capi_i2c OF capi_i2c IS

Component capi_rise_dff
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_rise_dff;

Component capi_en_rise_dff
  PORT (clk   : in std_logic;
        en    : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_en_rise_dff;

Component capi_en_rise_vdff
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        en    : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_en_rise_vdff;

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

Signal ack_phase: std_logic;  -- bool
Signal addr: std_logic_vector(0 to 7);  -- v8bit
Signal addr_d: std_logic_vector(0 to 7);  -- v8bit
Signal addr_phase: std_logic;  -- bool
Signal addr_phase_d: std_logic;  -- bool
Signal addren: std_logic;  -- bool
Signal addrin: std_logic_vector(0 to 7);  -- v8bit
Signal adv_sm: std_logic;  -- bool
Signal ap_reset: std_logic;  -- bool
Signal ap_set: std_logic;  -- bool
Signal bitcnt: std_logic_vector(0 to 2);  -- v3bit
Signal bitcnt_d: std_logic_vector(0 to 2);  -- v3bit
Signal bitcnt_en: std_logic;  -- bool
Signal bytecnt: std_logic_vector(0 to 7);  -- v8bit
Signal bytecnt_d: std_logic_vector(0 to 7);  -- v8bit
Signal bytecnt_en: std_logic;  -- bool
Signal bytecnt_m1: std_logic_vector(0 to 7);  -- v8bit
Signal clkdiv: std_logic_vector(0 to 10);  -- v11bit
Signal clkdiv_q: std_logic_vector(0 to 10);  -- v11bit
Signal clkhiadv: std_logic;  -- bool
Signal clkloadv: std_logic;  -- bool
Signal data: std_logic_vector(0 to 7);  -- v8bit
Signal data_d: std_logic_vector(0 to 7);  -- v8bit
Signal data_phase: std_logic;  -- bool
Signal data_phase_d: std_logic;  -- bool
Signal dataen: std_logic;  -- bool
Signal datain_q: std_logic_vector(0 to 7);  -- v8bit
Signal dataouten: std_logic;  -- bool
Signal dataval: std_logic;  -- bool
Signal dbounce: std_logic_vector(0 to 7);  -- v8bit
Signal dbounce_d: std_logic_vector(0 to 7);  -- v8bit
Signal dbounce_end: std_logic;  -- bool
Signal dbounce_gate: std_logic;  -- bool
Signal dbounce_nxt: std_logic_vector(0 to 7);  -- v8bit
Signal dbounce_start: std_logic;  -- bool
Signal do_read: std_logic;  -- bool
Signal dp_reset: std_logic;  -- bool
Signal dp_set: std_logic;  -- bool
Signal error_d: std_logic;  -- bool
Signal error_q: std_logic;  -- bool
Signal hold_clk: std_logic;  -- bool
Signal hold_done: std_logic;  -- bool
Signal holdadv: std_logic;  -- bool
Signal holdcnt: std_logic_vector(0 to 8);  -- v9bit
Signal holdcnt_d: std_logic_vector(0 to 8);  -- v9bit
Signal holdcnt_en: std_logic;  -- bool
Signal holdcnt_nxt: std_logic_vector(0 to 8);  -- v9bit
Signal i2c0_scl_in_q: std_logic;  -- bool
Signal i2c0_scl_in_qq: std_logic;  -- bool
Signal i2c0_sda_in_q: std_logic;  -- bool
Signal i2c0_sda_in_qq: std_logic;  -- bool
Signal i2c_s0x0: std_logic;  -- bool
Signal i2c_s0x1: std_logic;  -- bool
Signal i2c_s0x10: std_logic;  -- bool
Signal i2c_s0x11: std_logic;  -- bool
Signal i2c_s0x12: std_logic;  -- bool
Signal i2c_s0x13: std_logic;  -- bool
Signal i2c_s0x14: std_logic;  -- bool
Signal i2c_s0x15: std_logic;  -- bool
Signal i2c_s0x16: std_logic;  -- bool
Signal i2c_s0x17: std_logic;  -- bool
Signal i2c_s0x18: std_logic;  -- bool
Signal i2c_s0x19: std_logic;  -- bool
Signal i2c_s0x1A: std_logic;  -- bool
Signal i2c_s0x1B: std_logic;  -- bool
Signal i2c_s0x1C: std_logic;  -- bool
Signal i2c_s0x1D: std_logic;  -- bool
Signal i2c_s0x1E: std_logic;  -- bool
Signal i2c_s0x1F: std_logic;  -- bool
Signal i2c_s0x2: std_logic;  -- bool
Signal i2c_s0x3: std_logic;  -- bool
Signal i2c_s0x4: std_logic;  -- bool
Signal i2c_s0x5: std_logic;  -- bool
Signal i2c_s0x6: std_logic;  -- bool
Signal i2c_s0x7: std_logic;  -- bool
Signal i2c_s0x8: std_logic;  -- bool
Signal i2c_s0x9: std_logic;  -- bool
Signal i2c_s0xA: std_logic;  -- bool
Signal i2c_s0xB: std_logic;  -- bool
Signal i2c_s0xC: std_logic;  -- bool
Signal i2c_s0xD: std_logic;  -- bool
Signal i2c_s0xE: std_logic;  -- bool
Signal i2c_s0xF: std_logic;  -- bool
Signal i2c_scl_out: std_logic;  -- bool
Signal i2c_sda_out: std_logic;  -- bool
Signal i2c_sm: std_logic_vector(0 to 4);  -- v5bit
Signal i2c_sm_inc: std_logic_vector(0 to 4);  -- v5bit
Signal i2c_sm_nxt: std_logic_vector(0 to 4);  -- v5bit
Signal i2c_sm_nxt_addr: std_logic;  -- bool
Signal i2c_sm_nxt_datw: std_logic;  -- bool
Signal i2c_sm_nxt_err: std_logic;  -- bool
Signal i2c_sm_nxt_inc: std_logic;  -- bool
Signal i2c_sm_nxt_read: std_logic;  -- bool
Signal i2c_sm_nxt_reps: std_logic;  -- bool
Signal i2c_sm_nxt_sndd: std_logic;  -- bool
Signal i2c_sm_nxt_stop: std_logic;  -- bool
Signal i2cm_dataval_d: std_logic;  -- bool
Signal i2cm_error_d: std_logic;  -- bool
Signal justadv: std_logic;  -- bool
Signal ld_div: std_logic;  -- bool
Signal ld_div_q: std_logic;  -- bool
Signal more_bits: std_logic;  -- bool
Signal more_bytes: std_logic;  -- bool
Signal noack: std_logic;  -- bool
Signal nxtaddr: std_logic_vector(0 to 7);  -- v8bit
Signal nxtclkdiv: std_logic_vector(0 to 10);  -- v11bit
Signal nxtdata: std_logic_vector(0 to 7);  -- v8bit
Signal nxtdataen: std_logic;  -- bool
Signal nxtdataout: std_logic_vector(0 to 7);  -- v8bit
Signal other_phase: std_logic;  -- bool
Signal rdaddrin: std_logic_vector(0 to 7);  -- v8bit
Signal read_bcnt: std_logic;  -- bool
Signal read_bcnt_d: std_logic;  -- bool
Signal reset_read_bcnt: std_logic;  -- bool
Signal reset_send_bcnt: std_logic;  -- bool
Signal reset_send_data: std_logic;  -- bool
Signal run_clk: std_logic;  -- bool
Signal run_dbounce: std_logic;  -- bool
Signal run_dbounce_d: std_logic;  -- bool
Signal scl0_in_d: std_logic;  -- bool
Signal scl_in: std_logic;  -- bool
Signal scl_in_d: std_logic;  -- bool
Signal scl_in_q: std_logic;  -- bool
Signal scl_out: std_logic;  -- bool
Signal sda0_in: std_logic;  -- bool
Signal sda_in: std_logic;  -- bool
Signal sda_out: std_logic;  -- bool
Signal sel_bcnt_m1: std_logic;  -- bool
Signal sel_host_bc: std_logic;  -- bool
Signal sel_read_bc: std_logic;  -- bool
Signal selbytecnt: std_logic;  -- bool
Signal seldata: std_logic;  -- bool
Signal selnxtdata: std_logic;  -- bool
Signal send_bcnt: std_logic;  -- bool
Signal send_bcnt_d: std_logic;  -- bool
Signal send_data: std_logic;  -- bool
Signal send_data_d: std_logic;  -- bool
Signal set_read_bcnt: std_logic;  -- bool
Signal set_send_bcnt: std_logic;  -- bool
Signal set_send_data: std_logic;  -- bool
Signal sp_reset: std_logic;  -- bool
Signal sp_set: std_logic;  -- bool
Signal start_phase: std_logic;  -- bool
Signal startxfer: std_logic;  -- bool
Signal stop_phase: std_logic;  -- bool
Signal stop_phase_d: std_logic;  -- bool
Signal toggle_scl: std_logic;  -- bool
--Signal version: std_logic_vector(0 to 31);  -- int
Signal wrdatack_d: std_logic;  -- bool
Signal wrdatack_d1: std_logic;  -- bool
Signal wrdatack_d2: std_logic;  -- bool
Signal wrdatack_dly: std_logic;  -- bool
Signal i2cm_dataoutinternal: std_logic_vector(0 to 7);  -- v8bit

begin


--    version <= "00000000000000000000000000000001" ;

 -- ----------------------------------- --
 -- Input latches                       --
 -- ----------------------------------- --
    dff_i2c0_scl_in_q: capi_rise_dff PORT MAP (
         dout => i2c0_scl_in_q,
         din => i2c0_scl_in,
         clk   => psl_clk
    );

    dff_i2c0_sda_in_q: capi_rise_dff PORT MAP (
         dout => i2c0_sda_in_q,
         din => i2c0_sda_in,
         clk   => psl_clk
    );

    dff_i2c0_scl_in_qq: capi_rise_dff PORT MAP (
         dout => i2c0_scl_in_qq,
         din => i2c0_scl_in_q,
         clk   => psl_clk
    );

    dff_i2c0_sda_in_qq: capi_rise_dff PORT MAP (
         dout => i2c0_sda_in_qq,
         din => i2c0_sda_in_q,
         clk   => psl_clk
    );

    dff_scl0_in_d: capi_rise_dff PORT MAP (
         dout => scl0_in_d,
         din => i2c0_scl_in_qq,
         clk   => psl_clk
    );

    dff_sda0_in: capi_rise_dff PORT MAP (
         dout => sda0_in,
         din => i2c0_sda_in_qq,
         clk   => psl_clk
    );

    i2c0_scl_out <= i2c_scl_out ;
    i2c0_sda_out <= i2c_sda_out ;
    scl_in_d <= scl0_in_d ;
    sda_in <= sda0_in ;

    dbounce_gate <=  not run_dbounce_d ;
    endff_scl_in: capi_en_rise_dff PORT MAP (
         dout => scl_in,
         en => dbounce_gate,
         din => scl_in_d,
         clk   => psl_clk
    );

    dff_scl_in_q: capi_rise_dff PORT MAP (
         dout => scl_in_q,
         din => scl_in,
         clk   => psl_clk
    );

    endff_do_read: capi_en_rise_dff PORT MAP (
         dout => do_read,
         en => mi2c_cmdval,
         din => mi2c_rd,
         clk   => psl_clk
    );

 -- ----------------------------------- --
 -- Next State Equations and SM Latch   --
 -- ----------------------------------- --
    ---- State 0  : Idle (waiting for a command)                                            ----
    ---- State 1  : Activate Start bit                                                      ----
    --              Nxt State 2 after hold and scl_in for bus idle time                     ----
    ---- State 2  : Wait for clock low                                                      ----
    ---- State 3  : Hold Data                                                               ----
    ---- State 4  : Present Next Address                                                    ----
    ---- State 5  : Wait for clock high                                                     ----
    ---- State 6  : Wait for clock low                                                      ----
    --              Nxt State 3 if more address bits                                        ----
    --              Nxt State 7 if address frame complete                                   ----
    ---- State 7  : Hold Data                                                               ----
    ---- State 8  : Wait for clock high                                                     ----
    ---- State 9  : Check for ack / nack                                                    ----
    --              Nxt State  A if Ack                                                     ----
    --              Nxt State 18 if No Ack                                                  ----
    ---- State A  : Wait for clock low                                                      ----
    --              Nxt State  B if a I2C Write                                             ----
    --              Nxt State 12 if a I2C Read                                              ----
    ----     START OF WRITE                                                                 ----
    ---- State B  : Hold Data                                                               ----
    ---- State C  : Preset Next Data                                                        ----
    ---- State D  : Wait for clock high                                                     ----
    ---- State E  : Wait for clock low                                                      ----
    --              Nxt State  B if more data bits                                          ----
    --              Nxt State  F if data frame complete                                     ----
    ---- State F  : Hold Data                                                               ----
    ---- State 10 : Wait for clock high                                                     ----
    ---- State 11 : Check for ack / nack (after hold)                                       ----
    --              Nxt State  A if need to send data                                       ----
    --              Nxt State 18 if send data complete                                      ----
    --              Nxt State 1E if read command                                            ----
    ----                                                                                    ----
    ----     START OF READ                                                                  ----
    ---- State 12 : Wait for clock high                                                     ----
    ---- State 13 : Capture Data                                                            ----
    ---- State 14 : Wait for clock low                                                      ----
    --              Nxt State 12 if more data bits                                          ----
    --              Nxt State 15 if data frame complete                                     ----
    ----     CHECK FOR ACK / NACK AND STOP BIT                                              ----
    ---- State 15 : Hold Data                                                               ----
    ---- State 16 : Send ack                                                                ----
    ---- State 17 : Wait for clock high                                                     ----
    ----                                                                                    ----
    ---- State 18 : Wait for clock low                                                      ----
    ---- State 19 : Hold Data                                                               ----
    --              Nxt State 12 if more bytes to read                                      ----
    --              Nxt State 1A if read complete                                           ----
    ---- State 1A : Present stop bit                                                        ----
    ---- State 1B : Wait for clock high                                                     ----
    ---- State 1C : Hold Data                                                               ----
    ---- State 1D : Release stop bit                                                        ----
    --              Nxt State  0 after a Hold Delay                                         ----
    ----                                                                                    ----
    ----     PREPARE FOR REPEATED START                                                     ----
    ---- State 1E : Wait for clock low                                                      ----
    ---- State 1F : Wait for clock high and sda_in high                                     ----
    --              Nxt State  1 after hold                                                 ----

    ---- Next State Controls ----

    -- Next State Equations --
    i2c_sm_inc <= std_logic_vector(unsigned(i2c_sm) + 1) ;

    i2c_sm_nxt_addr <= more_bits  and  i2c_s0x6 ;
    i2c_sm_nxt_datw <= more_bits  and  i2c_s0xE ;
    i2c_sm_nxt_sndd <=  not do_read  and  send_data  and  i2c_s0x11 ;
    i2c_sm_nxt_stop <=  not do_read  and   not send_data  and  i2c_s0x11 ;
    i2c_sm_nxt_reps <= do_read  and  i2c_s0x11 ;
    i2c_sm_nxt_read <= (addr(7)  and  i2c_s0xA)  or  (more_bits  and  i2c_s0x14)  or
                            (more_bytes  and  addr(7)  and  i2c_s0x19  and   not error_q) ;
    i2c_sm_nxt_err <= sda_in  and  i2c_s0x9 ;
    i2c_sm_nxt_inc <=  not (i2c_sm_nxt_addr  or  i2c_sm_nxt_datw  or  i2c_sm_nxt_sndd  or  i2c_sm_nxt_stop  or  i2c_sm_nxt_reps  or
                              i2c_sm_nxt_read  or  i2c_sm_nxt_err   or  i2c_s0x1D  or  i2c_s0x1F) ;

    i2c_sm_nxt <= gate_and(i2c_sm_nxt_inc,i2c_sm_inc) or
                  gate_and(i2c_sm_nxt_addr,"00011") or
                  gate_and(i2c_sm_nxt_datw,"01011") or
                  gate_and(i2c_sm_nxt_sndd,"01010") or
                  gate_and(i2c_sm_nxt_reps,"11110") or
                  gate_and(i2c_sm_nxt_stop,"11000") or
                  gate_and(i2c_sm_nxt_read,"10010") or
                  gate_and(i2c_sm_nxt_err,"11000") or
                  gate_and(i2c_s0x1D,"00000") or
                  gate_and(i2c_s0x1F,"00001");

    -- Next State Latch and advance control --
    startxfer <= i2c_s0x0  and  mi2c_cmdval ;
    clkloadv <=  not scl_in    and  (i2c_s0x2   or  i2c_s0x6   or  i2c_s0xA  or
                                   i2c_s0xE   or  i2c_s0x14  or  i2c_s0x18  or  i2c_s0x1E) ;
    clkhiadv <= scl_in    and  (i2c_s0x5   or  i2c_s0x8   or  i2c_s0xD  or  i2c_s0x10  or
                                   i2c_s0x12  or  i2c_s0x17  or  i2c_s0x1B) ;
    holdadv <= hold_done  and  holdcnt_en ;
    justadv <= (i2c_s0x4   or  i2c_s0x9   or  i2c_s0xC   or
                       i2c_s0x13  or  i2c_s0x16  or  i2c_s0x1A ) ;
    adv_sm <= startxfer  or  clkhiadv  or  clkloadv  or  holdadv  or  justadv ;

    endff_i2c_sm: capi_en_rise_vdff GENERIC MAP ( width => 5 ) PORT MAP (
         dout => i2c_sm,
         en => adv_sm,
         din => i2c_sm_nxt,
         clk   => psl_clk
    );

 -- ----------------------------------- --
 -- Outputs                             --
 -- ----------------------------------- --
    dff_i2cm_ready: capi_rise_dff PORT MAP (
         dout => i2cm_ready,
         din => i2c_s0x0,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Data Source Latch                   --
 -- ----------------------------------- --
    set_send_bcnt <= i2c_s0x0   and  mi2c_cmdval  and  mi2c_blk  and   not mi2c_rd ;
    reset_send_bcnt <= (i2c_s0x11  and  holdadv)  or  (i2c_s0x0  and  mi2c_rd) ;
    send_bcnt_d <= set_send_bcnt  or  (send_bcnt  and   not reset_send_bcnt) ;

    set_send_data <= i2c_s0x0   and  mi2c_cmdval  and  mi2c_dataval  and   not mi2c_rd ;
    reset_send_data <= ((i2c_s0x11  and  holdadv)  or  (i2c_s0x0  and  mi2c_rd))  and   not send_bcnt  and   not more_bytes ;
    send_data_d <= set_send_data  or  (send_data  and   not reset_send_data) ;

    nxtdata <= ( data(1 to 7) & data(0) );


    seldata <= (i2c_s0x11  and   not send_bcnt) ;
    selbytecnt <= (i2c_s0x11  and  send_bcnt) ;

    selnxtdata <=  not (mi2c_cmdval  or  selbytecnt  or  seldata) ;
    data_d <= gate_and(mi2c_cmdval,mi2c_cmdin) or
              gate_and(selbytecnt,mi2c_bytecnt) or
              gate_and(seldata,datain_q) or
              gate_and(selnxtdata,nxtdata);

    dataen <= (i2c_s0x0  and  mi2c_cmdval)  or  i2c_s0xC  or  i2c_s0x11 ;
    wrdatack_d <= (i2c_s0x0  and  mi2c_cmdval  and   not mi2c_rd)  or  (i2c_s0x11  and  holdadv  and   not send_bcnt  and  send_data_d) ;

    nxtdataen <= mi2c_cmdval  or  (wrdatack_dly  and   not send_bcnt) ;

    endff_data: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => data,
         en => dataen,
         din => data_d,
         clk   => psl_clk
    );

    endff_datain_q: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => datain_q,
         en => nxtdataen,
         din => mi2c_datain,
         clk   => psl_clk
    );

    dff_send_data: capi_rise_dff PORT MAP (
         dout => send_data,
         din => send_data_d,
         clk   => psl_clk
    );

    dff_send_bcnt: capi_rise_dff PORT MAP (
         dout => send_bcnt,
         din => send_bcnt_d,
         clk   => psl_clk
    );

    dff_i2cm_wrdatack: capi_rise_dff PORT MAP (
         dout => i2cm_wrdatack,
         din => wrdatack_d,
         clk   => psl_clk
    );

    dff_wrdatack_d1: capi_rise_dff PORT MAP (
         dout => wrdatack_d1,
         din => wrdatack_d,
         clk   => psl_clk
    );

    dff_wrdatack_d2: capi_rise_dff PORT MAP (
         dout => wrdatack_d2,
         din => wrdatack_d1,
         clk   => psl_clk
    );

    dff_wrdatack_dly: capi_rise_dff PORT MAP (
         dout => wrdatack_dly,
         din => wrdatack_d2,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Address Source Latch                --
 -- ----------------------------------- --
    addrin <= ( mi2c_addr & '0' );

    rdaddrin <= ( addr(0 to 6) & do_read );

    nxtaddr <= ( addr(1 to 7) & addr(0) );

    addr_d <= gate_and(i2c_s0x0,addrin) or
              gate_and(i2c_s0x4,nxtaddr) or
              gate_and(i2c_s0x11,rdaddrin);

    addren <= i2c_s0x0  or  i2c_s0x4  or  i2c_s0x11 ;
    endff_addr: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => addr,
         en => addren,
         din => addr_d,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Data Input Latch                    --
 -- ----------------------------------- --
    nxtdataout <= ( i2cm_dataoutinternal(1 to 7) & sda_in );

    dataouten <= i2c_s0x13 ;
    endff_i2cm_dataout: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => i2cm_dataoutinternal,
         en => dataouten,
         din => nxtdataout,
         clk   => psl_clk
    );

    dataval <= ( not more_bits  and  i2c_s0x14  and  clkloadv) ;
    i2cm_dataval_d <= dataval  and   not read_bcnt ;
    dff_i2cm_dataval: capi_rise_dff PORT MAP (
         dout => i2cm_dataval,
         din => i2cm_dataval_d,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Error Output                        --
 -- ----------------------------------- --
    noack <= (i2c_s0x9  and  sda_in)  or  (i2c_s0x11  and  sda_in) ;
    error_d <= noack  or  ( not (mi2c_cmdval  and  mi2c_rd)  and  error_q) ;

    dff_error_q: capi_rise_dff PORT MAP (
         dout => error_q,
         din => error_d,
         clk   => psl_clk
    );

    i2cm_error_d <= error_q  and  i2c_s0x0 ;
    dff_i2cm_error: capi_rise_dff PORT MAP (
         dout => i2cm_error,
         din => i2cm_error_d,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- SDA Output                          --
 -- ----------------------------------- --
    -- Start Phase Generation --
    start_phase <= i2c_s0x2   or  i2c_s0x3 ;
    --bool sp_set   = i2c_s0x16 | i2c_s0x1A; --

    -- Stop Phase Generation --
    sp_set <= i2c_s0x1A ;
    sp_reset <= i2c_s0x1D  or  i2c_s0x0 ;
    stop_phase_d <= sp_set  or  (stop_phase  and   not sp_reset) ;
    --bool stop_phase  = i2c_s0x16 | i2c_s0x17 | i2c_s0x18 | --
    --                   i2c_s0x19 | i2c_s0x1A | i2c_s0x1B;  --

    -- Addr Phase Generation --
    ap_set <= i2c_s0x3  and  holdadv ;
    ap_reset <= (i2c_s0x7  and  holdadv)  or  i2c_s0x0 ;
    addr_phase_d <= ap_set  or  (addr_phase  and   not ap_reset) ;

    -- Data Phase Generation --
    dp_set <= i2c_s0xC ;
    dp_reset <= (i2c_s0xF  and  holdadv)  or  i2c_s0x0 ;
    data_phase_d <= dp_set  or  (data_phase  and   not dp_reset) ;

    -- Ack Phase Generation --
    ack_phase <= (i2c_s0x16  or  i2c_s0x17  or  i2c_s0x18  or  i2c_s0x19)  and  more_bytes ;

    -- Other Phase Generation --
    other_phase <=  not start_phase  and   not stop_phase  and   not addr_phase  and   not data_phase  and   not ack_phase ;

    -- SDA Generation --
    -- Take the least signigicant bit since the data is pre-shifted.
    -- Sending MSB first
    sda_out <= (start_phase and '0') or
               (stop_phase and '0') or
               (ack_phase and '0') or
               (addr_phase and addr(7)) or
               (data_phase and data(7)) or
               (other_phase and '1');

    dff_i2c_sda_out: capi_rise_dff PORT MAP (
         dout => i2c_sda_out,
         din => sda_out,
         clk   => psl_clk
    );

    dff_addr_phase: capi_rise_dff PORT MAP (
         dout => addr_phase,
         din => addr_phase_d,
         clk   => psl_clk
    );

    dff_data_phase: capi_rise_dff PORT MAP (
         dout => data_phase,
         din => data_phase_d,
         clk   => psl_clk
    );

    dff_stop_phase: capi_rise_dff PORT MAP (
         dout => stop_phase,
         din => stop_phase_d,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Clock Circuit                       --
 -- ----------------------------------- --
    hold_clk <= i2c_s0x1  or  (i2c_s0x1F  and   not sda_in) ;
    ld_div <= '1'  when  (clkdiv_q  =  "00000000000") else i2c_s0x1 ;

    nxtclkdiv <= std_logic_vector(unsigned(clkdiv_q) - 1) ;
    clkdiv <= "10100000000" when ld_div='1' else nxtclkdiv;

    run_clk <=  not (i2c_s0x0  or  (scl_out  and   not scl_in)  or  hold_clk) ;

    toggle_scl <=  not ld_div_q  and  ld_div  and   not i2c_s0x1 ;
    scl_out <= i2c_s0x0  or  (toggle_scl  xor  i2c_scl_out) ;

    endff_clkdiv_q: capi_en_rise_vdff GENERIC MAP ( width => 11 ) PORT MAP (
         dout => clkdiv_q,
         en => run_clk,
         din => clkdiv,
         clk   => psl_clk
    );

    dff_ld_div_q: capi_rise_dff PORT MAP (
         dout => ld_div_q,
         din => ld_div,
         clk   => psl_clk
    );

    dff_i2c_scl_out: capi_rise_dff PORT MAP (
         dout => i2c_scl_out,
         din => scl_out,
         clk   => psl_clk
    );


 -- -- End Section -- --
 -- ----------------------------------- --
 -- Bit Counter                         --
 -- ----------------------------------- --
    bitcnt_d <= std_logic_vector(unsigned(bitcnt) + 1) ;
    bitcnt_en <= i2c_s0x4  or  i2c_s0xC  or  i2c_s0x13 ;
    endff_bitcnt: capi_en_rise_vdff GENERIC MAP ( width => 3 ) PORT MAP (
         dout => bitcnt,
         en => bitcnt_en,
         din => bitcnt_d,
         clk   => psl_clk
    );

    more_bits <=  '0' when (bitcnt  =  "000") else '1' ;

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Byte Counter                        --
 -- ----------------------------------- --
    set_read_bcnt <= i2c_s0x0   and  mi2c_cmdval  and  mi2c_blk  and  mi2c_rd ;
    reset_read_bcnt <= dataval  or  (i2c_s0x0  and  ( not mi2c_rd  or   not mi2c_blk)) ;
    read_bcnt_d <= set_read_bcnt  or  (read_bcnt  and   not reset_read_bcnt) ;

    bytecnt_m1 <= std_logic_vector(unsigned(bytecnt) - 1) ;

    sel_host_bc <= i2c_s0x0 ;
    sel_read_bc <= read_bcnt ;
    sel_bcnt_m1 <=  not (sel_host_bc  or  sel_read_bc) ;

    bytecnt_d <= gate_and(sel_host_bc,mi2c_bytecnt) or
                 gate_and(sel_read_bc,i2cm_dataoutinternal) or
                 gate_and(sel_bcnt_m1,bytecnt_m1);

    bytecnt_en <= mi2c_cmdval  or  (i2c_s0xF  and  holdadv  and   not send_bcnt  and   not do_read)  or  dataval ;

    dff_read_bcnt: capi_rise_dff PORT MAP (
         dout => read_bcnt,
         din => read_bcnt_d,
         clk   => psl_clk
    );

    endff_bytecnt: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => bytecnt,
         en => bytecnt_en,
         din => bytecnt_d,
         clk   => psl_clk
    );

    more_bytes <=  '0' when (bytecnt  =  "00000000") else '1';

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Hold Counter                        --
 -- ----------------------------------- --
    holdcnt_nxt <= std_logic_vector(unsigned(holdcnt) + 1) ;
    holdcnt_en <= i2c_s0x1   or  i2c_s0x3   or  i2c_s0x7   or  i2c_s0xB   or  i2c_s0xF   or
                       i2c_s0x11  or  i2c_s0x15  or  i2c_s0x19  or  i2c_s0x1C  or  i2c_s0x1D  or
                       (i2c_s0x1F  and  scl_in  and  sda_in) ;
    holdcnt_d <= "000000000" when i2c_s0x0='1' else holdcnt_nxt;

    endff_holdcnt: capi_en_rise_vdff GENERIC MAP ( width => 9 ) PORT MAP (
         dout => holdcnt,
         en => holdcnt_en,
         din => holdcnt_d,
         clk   => psl_clk
    );

    hold_done <= '1' when (holdcnt  =  "111111111") else '0' ;

 -- -- End Section -- --
 -- ----------------------------------- --
 -- Debounce Counter                    --
 -- ----------------------------------- --
    dbounce_nxt <= std_logic_vector(unsigned(dbounce) + 1) ;
    dbounce_d <= dbounce_nxt when run_dbounce='1' else "00000000";

    dbounce_start <= (scl_in  xor  scl_in_q) ;
    dbounce_end <= '1' when (dbounce = "11111111") else '0';
    run_dbounce_d <= dbounce_start  or  (run_dbounce  and   not dbounce_end) ;

    dff_dbounce: capi_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
         dout => dbounce,
         din => dbounce_d,
         clk   => psl_clk
    );

    dff_run_dbounce: capi_rise_dff PORT MAP (
         dout => run_dbounce,
         din => run_dbounce_d,
         clk   => psl_clk
    );

 -- -- End Section -- --
 -- ----------------------------------- --
 -- I2C SM Decodes                      --
 -- ----------------------------------- --
    i2c_s0x0 <= '1' when (i2c_sm  =  "00000") else '0';     -- 0x0  --
    i2c_s0x1 <= '1' when (i2c_sm  =  "00001") else '0';     -- 0x1  --
    i2c_s0x2 <= '1' when (i2c_sm  =  "00010") else '0';     -- 0x2  --
    i2c_s0x3 <= '1' when (i2c_sm  =  "00011") else '0';     -- 0x3  --
    i2c_s0x4 <= '1' when (i2c_sm  =  "00100") else '0';     -- 0x4  --
    i2c_s0x5 <= '1' when (i2c_sm  =  "00101") else '0';     -- 0x5  --
    i2c_s0x6 <= '1' when (i2c_sm  =  "00110") else '0';     -- 0x6  --
    i2c_s0x7 <= '1' when (i2c_sm  =  "00111") else '0';     -- 0x7  --
    i2c_s0x8 <= '1' when (i2c_sm  =  "01000") else '0';     -- 0x8  --
    i2c_s0x9 <= '1' when (i2c_sm  =  "01001") else '0';     -- 0x9  --
    i2c_s0xA <= '1' when (i2c_sm  =  "01010") else '0';     -- 0xA  --
    i2c_s0xB <= '1' when (i2c_sm  =  "01011") else '0';     -- 0xB  --
    i2c_s0xC <= '1' when (i2c_sm  =  "01100") else '0';     -- 0xC  --
    i2c_s0xD <= '1' when (i2c_sm  =  "01101") else '0';     -- 0xD  --
    i2c_s0xE <= '1' when (i2c_sm  =  "01110") else '0';     -- 0xE  --
    i2c_s0xF <= '1' when (i2c_sm  =  "01111") else '0';     -- 0xF  --
    i2c_s0x10 <= '1' when (i2c_sm  =  "10000") else '0';     -- 0x10 --
    i2c_s0x11 <= '1' when (i2c_sm  =  "10001") else '0';     -- 0x11 --
    i2c_s0x12 <= '1' when (i2c_sm  =  "10010") else '0';     -- 0x12 --
    i2c_s0x13 <= '1' when (i2c_sm  =  "10011") else '0';     -- 0x13 --
    i2c_s0x14 <= '1' when (i2c_sm  =  "10100") else '0';     -- 0x14 --
    i2c_s0x15 <= '1' when (i2c_sm  =  "10101") else '0';     -- 0x15 --
    i2c_s0x16 <= '1' when (i2c_sm  =  "10110") else '0';     -- 0x16 --
    i2c_s0x17 <= '1' when (i2c_sm  =  "10111") else '0';     -- 0x17 --
    i2c_s0x18 <= '1' when (i2c_sm  =  "11000") else '0';     -- 0x18 --
    i2c_s0x19 <= '1' when (i2c_sm  =  "11001") else '0';     -- 0x19 --
    i2c_s0x1A <= '1' when (i2c_sm  =  "11010") else '0';     -- 0x1A --
    i2c_s0x1B <= '1' when (i2c_sm  =  "11011") else '0';     -- 0x1B --
    i2c_s0x1C <= '1' when (i2c_sm  =  "11100") else '0';     -- 0x1C --
    i2c_s0x1D <= '1' when (i2c_sm  =  "11101") else '0';     -- 0x1D --
    i2c_s0x1E <= '1' when (i2c_sm  =  "11110") else '0';     -- 0x1E --
    i2c_s0x1F <= '1' when (i2c_sm  =  "11111") else '0';     -- 0x1F --

 -- -- End Section -- --
  i2cm_dataout <= i2cm_dataoutinternal;
END capi_i2c;
