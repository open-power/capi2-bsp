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

ENTITY capi_i2cacc IS
  PORT(psl_clk : in std_logic;
       -- power supply controller UCD9090 PMBUS
       b_basei2c_scl : inout std_logic;  -- clock
       b_basei2c_sda : inout std_logic;  -- data

       i2cacc_wren : in std_logic;
       i2cacc_data : in std_logic_vector(0 to 63);
       i2cacc_rden : in std_logic;
       i2cacc_rddata : out std_logic_vector(0 to 63)

       );
end capi_i2cacc;

architecture capi_i2cacc of capi_i2cacc is

  Component capi_ram32x8
    PORT (clk   : in  std_logic;
          q     : out std_logic_vector(0 to 7);
          rdad  : in  std_logic_vector(0 to 4);
          rden  : in  std_logic;
          data  : in  std_logic_vector(0 to 7);
          wrad  : in  std_logic_vector(0 to 4);
          wren  : in  std_logic);
  End Component capi_ram32x8;

  Component capi_rise_dff
    PORT (clk   : in std_logic;
          dout  : out std_logic;
          din   : in std_logic);
  End Component capi_rise_dff;

  Component capi_gpio1
    PORT(pin: inout std_logic;
         id                            : out   std_logic;
         od                            : in    std_logic;
         oe:      in std_logic);
  End Component capi_gpio1;

  Component capi_i2c
    PORT(psl_clk: in std_logic;

         -- --------------- --
         i2c0_scl_out                  : out   std_logic;
         i2c0_scl_in                   : in    std_logic;
         i2c0_sda_out                  : out   std_logic;
         i2c0_sda_in                   : in    std_logic;

         -- -------------- --
         mi2c_cmdval                   : in    std_logic;
         mi2c_dataval                  : in    std_logic;
         mi2c_addr                     : in    std_logic_vector(0 to 6);
         mi2c_rd                       : in    std_logic;
         mi2c_cmdin                    : in    std_logic_vector(0 to 7);
         mi2c_datain                   : in    std_logic_vector(0 to 7);
         mi2c_blk                      : in    std_logic;
         mi2c_bytecnt                  : in    std_logic_vector(0 to 7);
         mi2c_cntlrsel                 : in    std_logic_vector(0 to 2);
         i2cm_wrdatack                 : out   std_logic;
         i2cm_dataval                  : out   std_logic;
         i2cm_error                    : out   std_logic;
         i2cm_dataout                  : out   std_logic_vector(0 to 7);
         i2cm_ready:out std_logic);
  End Component capi_i2c;

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

  Signal status_capi_i2cacc_bytecnt: std_logic_vector(0 to 7);  -- v8bit
  Signal status_capi_i2cacc_rdata: std_logic_vector(0 to 7);  -- v8bit
  Signal status_capi_i2cacc_rdataval: std_logic;  -- bool
  Signal status_capi_i2cacc_ready: std_logic;  -- bool
  Signal status_capi_i2cacc_xfererr: std_logic;  -- bool
  Signal capi_i2cacc_wren_q: std_logic;  -- bool

  Signal bytecnt_d: std_logic_vector(0 to 7);  -- v8bit
  Signal bytecnt_m1: std_logic_vector(0 to 7);  -- v8bit
  Signal bytecnt_p1: std_logic_vector(0 to 7);  -- v8bit
  Signal bytecnt_q: std_logic_vector(0 to 7);  -- v8bit
  Signal hi2c_word: std_logic;  -- bool
  Signal i2c_buf_raddr: std_logic_vector(0 to 4);  -- v5bit
  Signal i2c_buf_rd: std_logic;  -- bool
  Signal i2c_buf_waddr: std_logic_vector(0 to 4);  -- v5bit
  Signal i2c_buf_wr: std_logic;  -- bool
  Signal i2c_buf_wrdat: std_logic_vector(0 to 7);  -- v8bit
  Signal i2c_cmdval_q: std_logic;  -- bool
  Signal i2c_cmdval_qq: std_logic;  -- bool
  Signal i2c_rddat_valid: std_logic;  -- bool
  Signal ld_bytecnt: std_logic;  -- bool

  Signal hi2c_addr: std_logic_vector(0 to 6);
  Signal hi2c_blk: std_logic;
  Signal hi2c_bytecnt: std_logic_vector(0 to 7);  -- v8bit
  Signal hi2c_cmdin: std_logic_vector(0 to 7);  -- v8bit
  Signal hi2c_cmdval: std_logic;  -- bool
  Signal hi2c_cntlrsel: std_logic_vector(0 to 2);  -- v3bit
  Signal hi2c_datain: std_logic_vector(0 to 7);  -- v8bit
  Signal hi2c_dataval: std_logic;  -- bool
  Signal hi2c_rd: std_logic;  -- bool
  Signal i2c_scl_en: std_logic;  -- bool
  Signal i2c_scl_in: std_logic;  -- bool
  Signal i2c_scl_out: std_logic;  -- bool
  Signal i2c_sda_en: std_logic;  -- bool
  Signal i2c_sda_in: std_logic;  -- bool
  Signal i2c_sda_out: std_logic;  -- bool
  Signal i2ch_dataout: std_logic_vector(0 to 7);  -- v8bit
  Signal i2ch_dataval: std_logic;  -- bool
  Signal i2ch_error: std_logic;  -- bool
  Signal i2ch_ready: std_logic;  -- bool
  Signal i2ch_wrdatack: std_logic;  -- bool

  Signal sel_1byte: std_logic;  -- bool
  Signal sel_2byte: std_logic;  -- bool
  Signal sel_bcnt: std_logic;  -- bool
  Signal sel_m1_bytecnt: std_logic;  -- bool
  Signal sel_p1_bytecnt: std_logic;  -- bool
  Signal sel_zero_bytecnt: std_logic;  -- bool

  Signal i2cacc_data_q : std_logic_vector(0 to 63);

begin

endff_i2cacc_data_q: capi_en_rise_vdff GENERIC MAP ( width => 64 ) PORT MAP (
    dout => i2cacc_data_q,
    en => i2cacc_wren,
    din => i2cacc_data,
    clk   => psl_clk
    );

-- I2c Ch0 - UCD access via vsec
--           See PSL8 v1.0 - CAPI_I2CACC register definition

  i2cacc_rddata <= ( status_capi_i2cacc_ready & status_capi_i2cacc_rdataval & status_capi_i2cacc_xfererr &
                     "000000000" & i2cacc_data_q(12 to 15) & "00000" & i2cacc_data_q(21 to 23) & status_capi_i2cacc_bytecnt(0 to 7)
                     & i2cacc_data_q(32 to 47) &  status_capi_i2cacc_rdata(0 to 7) & i2cacc_data_q(56 to 63) );
-- i2cacc_write 00030001fad00006  -- cmdval,dataval
-- i2cacc_write 00000001fad00006
--  i2cacc_read 00000000fad00006

  hi2c_cmdval <= i2c_cmdval_q  and   not i2c_cmdval_qq ;  -- rising edge i2cacc_data_q(15)
  hi2c_dataval <= i2cacc_data_q(14) ;
  hi2c_addr <= i2cacc_data_q(40 to 46) ;
  hi2c_rd <= i2cacc_data_q(47) ;
  hi2c_cmdin <= i2cacc_data_q(32 to 39) ;
  hi2c_datain <= i2cacc_data_q(56 to 63) ;
  hi2c_blk <= i2cacc_data_q(12);
  hi2c_word <= i2cacc_data_q(13) ;
  hi2c_cntlrsel <= i2cacc_data_q(21 to 23) ;

  -- Status from i2c controller
  status_capi_i2cacc_ready <= i2ch_ready ;
  status_capi_i2cacc_rdataval <= i2c_rddat_valid ;
  status_capi_i2cacc_xfererr <= i2ch_error ;
  status_capi_i2cacc_bytecnt <= bytecnt_q ;

  -- Outputs to i2c controller
  dff_i2c_cmdval_q: capi_rise_dff PORT MAP (
    dout => i2c_cmdval_q,
    din => i2cacc_data_q(15),
    clk   => psl_clk
    );

  dff_i2c_cmdval_qq: capi_rise_dff PORT MAP (
    dout => i2c_cmdval_qq,
    din => i2c_cmdval_q,
    clk   => psl_clk
    );

  sel_1byte <=  not hi2c_word  and hi2c_rd;
  sel_2byte <= hi2c_word  and  hi2c_rd;
  sel_bcnt <=  not hi2c_rd ;
  hi2c_bytecnt <= gate_and(sel_1byte,"00000001") or
                  gate_and(sel_2byte,"00000010") or
                  gate_and(sel_bcnt,bytecnt_q);
  -- Keep track of number of bytes
  i2c_rddat_valid <=  '0' when (bytecnt_q = "00000000")  else  hi2c_rd;

  bytecnt_p1 <= std_logic_vector(unsigned(bytecnt_q) + 1) ;
  bytecnt_m1 <= std_logic_vector(unsigned(bytecnt_q) - 1) ;

  sel_p1_bytecnt <= (capi_i2cacc_wren_q  and   not hi2c_rd)  or  i2ch_dataval ;
  sel_zero_bytecnt <= (capi_i2cacc_wren_q  and  hi2c_rd) ;
  sel_m1_bytecnt <=  not (sel_p1_bytecnt  or  sel_zero_bytecnt) ;
  bytecnt_d <= gate_and(sel_p1_bytecnt,bytecnt_p1) or
               gate_and(sel_m1_bytecnt,bytecnt_m1) or
               gate_and(sel_zero_bytecnt,"00000000");

  dff_capi_i2cacc_wren_q: capi_rise_dff PORT MAP (
    dout => capi_i2cacc_wren_q,
    din => i2cacc_wren,
    clk   => psl_clk
    );

  ld_bytecnt <= (capi_i2cacc_wren_q  and  hi2c_dataval  and   not hi2c_rd)  or
                (i2cacc_rden  and  i2c_rddat_valid  and  i2ch_ready)  or
                i2ch_dataval  or  i2ch_wrdatack ;

  endff_bytecnt_q: capi_en_rise_vdff GENERIC MAP ( width => 8 ) PORT MAP (
    dout => bytecnt_q,
    en => ld_bytecnt,
    din => bytecnt_d,
    clk   => psl_clk
    );

  -- Data Buffer
  i2c_buf_waddr <= bytecnt_q(3 to 7) ;
  dff_i2c_buf_raddr: capi_rise_vdff GENERIC MAP ( width => 5 ) PORT MAP (
    dout => i2c_buf_raddr,
    din => bytecnt_m1(3 to 7),
    clk   => psl_clk
    );

  i2c_buf_rd <= '1' ;
  i2c_buf_wr <= (capi_i2cacc_wren_q  and  hi2c_dataval)  or  i2ch_dataval ;
  i2c_buf_wrdat <= i2ch_dataout when i2ch_dataval='1' else hi2c_datain;

  i2c_dat_buf: capi_ram32x8 PORT MAP (
    q => status_capi_i2cacc_rdata,
    rdad => i2c_buf_raddr,
    rden => i2c_buf_rd,
    data => i2c_buf_wrdat,
    wrad => i2c_buf_waddr,
    wren => i2c_buf_wr,
    clk   => psl_clk
    );

  -- I2C master for powercontrol (UCD9090)
  i2c0:    capi_i2c
    PORT MAP (
      i2c0_scl_out => i2c_scl_out,
      i2c0_scl_in => i2c_scl_in,
      i2c0_sda_out => i2c_sda_out,
      i2c0_sda_in => i2c_sda_in,

      mi2c_cmdval => hi2c_cmdval,
      mi2c_dataval => hi2c_dataval,
      mi2c_addr => hi2c_addr,
      mi2c_rd => hi2c_rd,
      mi2c_cmdin => hi2c_cmdin,
      mi2c_datain => hi2c_datain,
      mi2c_blk => hi2c_blk,
      mi2c_bytecnt => hi2c_bytecnt,
      mi2c_cntlrsel => hi2c_cntlrsel,
      i2cm_wrdatack => i2ch_wrdatack,
      i2cm_dataval => i2ch_dataval,
      i2cm_error => i2ch_error,
      i2cm_dataout => i2ch_dataout,
      i2cm_ready => i2ch_ready,
      psl_clk => psl_clk
      );

  i2c_scl_en <=  i2c_scl_out;
  i2c_sda_en <=  i2c_sda_out;
  gpio_b_basei2c_scl:capi_gpio1
    PORT MAP (
      pin => b_basei2c_scl,
      id => i2c_scl_in,
      od => '0',
      oe => i2c_scl_en
      );

  gpio_b_basei2c_sda:capi_gpio1
    PORT MAP (
      pin => b_basei2c_sda,
      id => i2c_sda_in,
      od => '0',
      oe => i2c_sda_en
      );

end capi_i2cacc;
