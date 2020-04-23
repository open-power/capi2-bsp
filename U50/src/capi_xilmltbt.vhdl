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

ENTITY capi_xilmltbt IS
  PORT(psl_clk: in std_logic;          -- 250Mhz PCIe clock
       icap_clk: in std_logic;         -- 125Mhz clock

       -- -------------- --
       cpld_softreconfigreq: in std_logic;
       cpld_user_bs_req: in std_logic;

       --IP arbitration interface. This module is the master of the icap
       icap_release: out std_logic;
       icap_grant: out std_logic;
       icap_request: in std_logic;


       icap_mltbt_csib: out std_logic;
       icap_mltbt_rdwrb: out std_logic;
       icap_mltbt_writedata: out std_logic_vector(0 to 31);
       icap_mltbt_takeover: out std_logic);

END capi_xilmltbt;

ARCHITECTURE capi_xilmltbt OF capi_xilmltbt IS

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

Component capi_rise_vdff
  GENERIC(width : positive );
  PORT (clk   : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_rise_vdff;

Signal axi_icap_start_pre: std_logic;  -- bool

Signal reset: std_logic;  -- bool
Signal start: std_logic;  -- bool
Signal start_l1: std_logic;  -- bool
Signal start_l2: std_logic;  -- bool
Signal start_l3: std_logic;  -- bool
--Signal version: std_logic_vector(0 to 31);  -- int
Signal wbstart_addr: std_logic_vector(31 downto 0);  -- v32bit
Signal wbstart_addr_l1: std_logic_vector(31 downto 0);  -- v32bit
Signal wbstart_addr_l2: std_logic_vector(31 downto 0);  -- v32bit
Signal wbstart_addr_l3: std_logic_vector(31 downto 0);  -- v32bit
Signal wbstart_addr_l3_swapendianness: std_logic_vector(31 downto 0);  -- v32bit
signal count_valid: std_logic;
signal count_valid_l: std_logic;
signal count_nxt: std_logic_vector(3 downto 0);
signal count_l: std_logic_vector(3 downto 0);
Signal start_d: std_logic;  -- bool
Signal start_q: std_logic;  -- bool
signal start_pulse: std_logic;
signal end_sequence: std_logic;
signal end_sequence_l: std_logic;
signal end_pulse: std_logic;
signal instruction_address: std_logic_vector(3 downto 0);
signal data: std_logic_vector(35 downto 0);
signal icap_request_q: std_logic;
signal icap_request_fall: std_logic;
signal icap_mltbt_takeover_d: std_logic;
signal icap_mltbt_takeover_q: std_logic;

begin

    dff_start: capi_rise_dff PORT MAP (
         dout => start,
         din => axi_icap_start_pre,
         clk   => psl_clk
    );

    dff_startl1: capi_rise_dff PORT MAP (
         dout => start_l1,
         din => start,
         clk   => icap_clk
    );
    dff_startl2: capi_rise_dff PORT MAP (
         dout => start_l2,
         din => start_l1,
         clk   => icap_clk
    );
    dff_startl3: capi_rise_dff PORT MAP (
         dout => start_l3,
         din => start_l2,
         clk   => icap_clk
    );

    axi_icap_start_pre <= cpld_softreconfigreq  or  start ;

    -- This is for Semptian NSA241. 256MiB total. Split to 2 areas.
    -- User image will be placed at 128MiB place 0x0800_0000 
    -- RS pins not used in SPI mode

    -- wbstart_addr: [31,30]: RS | [29]: RS_TS_B | [28:0]: START_ADDR
    -- Wait address expansion
    wbstart_addr <= ( "000" & "0" & cpld_user_bs_req & "000" & "000000000000000000000000" );

    dff_wbstart_addrl1: capi_rise_vdff GENERIC MAP ( width => 32 ) PORT MAP (
         dout => wbstart_addr_l1,
         din => wbstart_addr,
         clk   => icap_clk
    );
    dff_wbstart_addrl2: capi_rise_vdff GENERIC MAP ( width => 32 ) PORT MAP (
         dout => wbstart_addr_l2,
         din => wbstart_addr_l1,
         clk   => icap_clk
    );
    dff_wbstart_addrl3: capi_rise_vdff GENERIC MAP ( width => 32 ) PORT MAP (
         dout => wbstart_addr_l3,
         din => wbstart_addr_l2,
         clk   => icap_clk
    );
    wbstart_addr_l3_swapendianness <= wbstart_addr_l3(24) & wbstart_addr_l3(25) & wbstart_addr_l3(26) & wbstart_addr_l3(27) & wbstart_addr_l3(28)
     & wbstart_addr_l3(29) & wbstart_addr_l3(30) & wbstart_addr_l3(31) & wbstart_addr_l3(16) & wbstart_addr_l3(17) & wbstart_addr_l3(18)
     & wbstart_addr_l3(19) & wbstart_addr_l3(20) & wbstart_addr_l3(21) & wbstart_addr_l3(22) & wbstart_addr_l3(23) & wbstart_addr_l3(8)
     & wbstart_addr_l3(9) & wbstart_addr_l3(10) & wbstart_addr_l3(11) & wbstart_addr_l3(12) & wbstart_addr_l3(13) & wbstart_addr_l3(14)
     & wbstart_addr_l3(15) & wbstart_addr_l3(0) & wbstart_addr_l3(1) & wbstart_addr_l3(2) & wbstart_addr_l3(3) & wbstart_addr_l3(4)
     & wbstart_addr_l3(5) & wbstart_addr_l3(6) & wbstart_addr_l3(7);--ICAP takes swapped endianness on each byte

    start_pulse <= start_d and not(start_q);
    end_sequence <= '1' when ((count_l(3) = '1') and (count_l(2) = '0') and (count_l(1) = '0') and (count_l(0) = '1')) else '0';
    end_pulse <= end_sequence and not(end_sequence_l);
    count_valid <= '1' when (start_pulse = '1') else
                   '0' when (end_pulse = '1') else
                   count_valid_l;
    count_nxt <= (std_logic_vector(unsigned(count_l) + 1)) when (count_valid = '1') else
                   "0000";

    start_d <= start_l3 and icap_request_fall;
    dff_start_q: capi_rise_dff PORT MAP (
         dout => start_q,
         din => start_d,
         clk   => icap_clk
    );

    dff_end_sequence_l: capi_rise_dff PORT MAP (
         dout => end_sequence_l,
         din => end_sequence,
         clk   => icap_clk
    );

    dff_count_valid_l: capi_rise_dff PORT MAP (
         dout => count_valid_l,
         din => count_valid,
         clk   => icap_clk
    );

    dff_count_l: capi_rise_vdff GENERIC MAP ( width => 4) PORT MAP (
         dout => count_l,
         din => count_nxt,
         clk   => icap_clk
    );

instruction_address <= count_l;

process (instruction_address, wbstart_addr_l3_swapendianness)
begin
  case instruction_address is
    when "0000" => data <= X"3FFFFFFFF";
    when "0001" => data <= X"0FFFFFFFF";
    when "0010" => data <= X"05599AA66";
    when "0011" => data <= X"004000000";
    when "0100" => data <= X"00C400080";
    when "0101" => data <= X"0" & wbstart_addr_l3_swapendianness;
    when "0110" => data <= X"00C000180";
    when "0111" => data <= X"0000000F0";
    when "1000" => data <= X"004000000";
    when "1001" => data <= X"3FFFFFFFF";
    when "1010" => data <= X"3FFFFFFFF";
    when "1011" => data <= X"3FFFFFFFF";
    when "1100" => data <= X"3FFFFFFFF";
    when "1101" => data <= X"3FFFFFFFF";
    when "1110" => data <= X"3FFFFFFFF";
    when "1111" => data <= X"3FFFFFFFF";
    when others => data <= X"3FFFFFFFF";
  end case ;
end process;

    dff_icap_mltbt_csib: capi_rise_dff PORT MAP (
         dout => icap_mltbt_csib,
         din => data(33),
         clk   => icap_clk
    );
    dff_icap_mltbt_rdwrb: capi_rise_dff PORT MAP (
         dout => icap_mltbt_rdwrb,
         din => data(32),
         clk   => icap_clk
    );
    dff_icap_mltbt_writedata: capi_rise_vdff GENERIC MAP ( width => 32) PORT MAP (
         dout => icap_mltbt_writedata,
         din => data(31 downto 0),
         clk   => icap_clk
    );

    --Arbitration Logic. Multiboot permanently takes over until image is blown away.
    --Temporarily disabling sem core until more robust arbiter can be implemented
    --icap_release <= start_l3;
    --icap_grant <= not(start_l3);
    icap_release <= '1';
    icap_grant <= '0';

    dff_icap_request_q: capi_rise_dff PORT MAP (
         dout => icap_request_q,
         din => icap_request,
         clk   => icap_clk
    );
    --icap_request_fall <= icap_request_q and not(icap_request);
    --icap_mltbt_takeover_d <= icap_mltbt_takeover_q or icap_request_fall;
    icap_request_fall <= '1';
    icap_mltbt_takeover_d <= '1';
    --dff_icap_mktbt_takeover_q: capi_rise_dff PORT MAP (
    dff_icap_mktbt_takeover_q: capi_rise_dff_init1 PORT MAP (
         dout => icap_mltbt_takeover_q,
         din => icap_mltbt_takeover_d,
         clk   => icap_clk
    );
    icap_mltbt_takeover <= icap_mltbt_takeover_q;

END capi_xilmltbt;
