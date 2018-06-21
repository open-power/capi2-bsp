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

ENTITY capi_sreconfig IS
  PORT(psl_clk: in std_logic;

       -- -------------- --
       pci_pi_nperst0: in std_logic;
       cpld_softreconfigreq: out std_logic;
       cpld_user_bs_req: out std_logic;
       cpld_oe: out std_logic;

       -- -------------- --
       req_reconfig: in std_logic;
       req_user: in std_logic);

END capi_sreconfig;

ARCHITECTURE capi_sreconfig OF capi_sreconfig IS

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

Signal cyc_d: std_logic_vector(0 to 4);  -- v5bit
Signal cyc_nxt: std_logic_vector(0 to 4);  -- v5bit
Signal cyc_q: std_logic_vector(0 to 4);  -- v5bit
Signal nperst_l: std_logic;  -- bool
Signal nperst_ll: std_logic;  -- bool
Signal nperst_synced: std_logic;  -- bool
Signal nperst_synced_l: std_logic;  -- bool
Signal oe_d: std_logic;  -- bool
Signal req_reconfig_q: std_logic;  -- bool
Signal req_user_q: std_logic;  -- bool
Signal run: std_logic;  -- bool
Signal run_d: std_logic;  -- bool
Signal softreconfigreq: std_logic;  -- bool
Signal start: std_logic;  -- bool
Signal user_bs_req: std_logic;  -- bool
--Signal version: std_logic_vector(0 to 31);  -- int

begin

--    version <= "00000000000000000000000000000011" ;

--============================================================================================
---- Misc. Logic
--==============================================================================================--

 -- Latch Inputs                        --
    dff_nperst_l: capi_rise_dff PORT MAP (
         dout => nperst_l,
         din => pci_pi_nperst0,
         clk   => psl_clk
    );

    dff_nperst_ll: capi_rise_dff PORT MAP (
         dout => nperst_ll,
         din => nperst_l,
         clk   => psl_clk
    );

    dff_nperst_synced: capi_rise_dff PORT MAP (
         dout => nperst_synced,
         din => nperst_ll,
         clk   => psl_clk
    );


    dff_req_reconfig_q: capi_rise_dff PORT MAP (
         dout => req_reconfig_q,
         din => req_reconfig,
         clk   => psl_clk
    );

    dff_req_user_q: capi_rise_dff PORT MAP (
         dout => req_user_q,
         din => req_user,
         clk   => psl_clk
    );

 -- Latch Outputs                       --
    dff_cpld_softreconfigreq: capi_rise_dff PORT MAP (
         dout => cpld_softreconfigreq,
         din => softreconfigreq,
         clk   => psl_clk
    );

    dff_cpld_oe: capi_rise_dff PORT MAP (
         dout => cpld_oe,
         din => oe_d,
         clk   => psl_clk
    );

    dff_cpld_user_bs_req: capi_rise_dff PORT MAP (
         dout => cpld_user_bs_req,
         din => user_bs_req,
         clk   => psl_clk
    );

--============================================================================================
---- Reconfiguration Request Logic
--==============================================================================================--

    dff_nperst_synced_l: capi_rise_dff PORT MAP (
         dout => nperst_synced_l,
         din => nperst_synced,
         clk   => psl_clk
    );

    start <= nperst_synced_l  and   not nperst_synced  and  req_reconfig_q ;

    run_d <= start when (cyc_q  =  "11111") else start or run ;
    dff_run: capi_rise_dff PORT MAP (
         dout => run,
         din => run_d,
         clk   => psl_clk
    );

--============================================================================================
---- Cycle Counter
--==============================================================================================--

    cyc_nxt <= std_logic_vector(unsigned(cyc_q) + 1) ;

    cyc_d <= cyc_nxt when run='1' else "00000";

    dff_cyc_q: capi_rise_vdff GENERIC MAP ( width => 5 ) PORT MAP (
         dout => cyc_q,
         din => cyc_d,
         clk   => psl_clk
    );

--============================================================================================
---- Request Bitstream
--==============================================================================================--

    oe_d <= ( (  not cyc_q(0)  and   cyc_q(1)  and   cyc_q(2))  or
                  (  cyc_q(0)                           ) )  and  run ;

    user_bs_req <= req_user_q ;
    softreconfigreq <= run_d ;
END capi_sreconfig;
