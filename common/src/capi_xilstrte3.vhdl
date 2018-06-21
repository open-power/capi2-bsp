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

ENTITY capi_xilstrte3 IS
  PORT(
       datain: out std_logic_vector(3 downto 0);
       dataout: in std_logic_vector(3 downto 0);
       datat: in std_logic;
       ce_in: in std_logic;
       ce_t: in std_logic);

END capi_xilstrte3;



ARCHITECTURE capi_xilstrte3 OF capi_xilstrte3 IS

Signal datatbus : std_logic_vector(3 downto 0);
Signal di : std_logic_vector(3 downto 0);
Signal do : std_logic_vector(3 downto 0);
Signal dts : std_logic_vector(0 to 3);
Signal fcsbo : std_logic;
Signal fcsbts : std_logic;


begin

-- datatbus <= not(datat) & not(datat) & not(datat) & not(datat);
datatbus <= datat & datat & datat & datat;

datain <= di;
do <= dataout;
dts <= datatbus;
fcsbo <= ce_in;
fcsbts <= ce_t;  -- not(ce_t);

STARTUPE3_inst : STARTUPE3
generic map (
PROG_USR => "FALSE", -- Activate program event security feature. Requires encrypted bitstreams.
SIM_CCLK_FREQ => 0.0 -- Set the Configuration Clock Frequency(ns) for simulation
)
port map (
--CFGCLK => CFGCLK, -- 1-bit output: Configuration main clock output
--CFGMCLK => CFGMCLK, -- 1-bit output: Configuration internal oscillator clock output
DI => di, -- 4-bit output: Allow receiving on the D input pin
--EOS => EOS, -- 1-bit output: Active-High output signal indicating the End Of Startup
--PREQ => PREQ, -- 1-bit output: PROGRAM request to fabric output
DO => do, -- 4-bit input: Allows control of the D pin output
DTS=> dts, -- 4-bit input: Allows tristate of the D pin
FCSBO => fcsbo, -- 1-bit input: Contols the FCS_B pin for flash access
FCSBTS => fcsbts, -- 1-bit input: Tristate the FCS_B pin
GSR => '0', -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port)
GTS => '0', -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
KEYCLEARB => '1', -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
PACK => '0', -- 1-bit input: PROGRAM acknowledge input
USRCCLKO => '0', -- 1-bit input: User CCLK input
USRCCLKTS => '1', -- 1-bit input: User CCLK 3-state enable input
USRDONEO => '0', -- 1-bit input: User DONE pin output control
USRDONETS => '1' -- 1-bit input: User DONE 3-state enable output
);

END capi_xilstrte3;
