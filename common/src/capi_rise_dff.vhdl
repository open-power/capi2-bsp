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

ENTITY capi_rise_dff IS
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
attribute latch_type : string;
attribute latch_type of dout : signal is "master_latch";

END capi_rise_dff;

ARCHITECTURE capi_rise_dff OF capi_rise_dff IS

  Signal dout_int : std_logic := '0';

begin

    process(clk)
    begin
      if rising_edge(clk) then
        dout_int <= din;
      end if;
    end process;

    dout <= dout_int;

END capi_rise_dff;
