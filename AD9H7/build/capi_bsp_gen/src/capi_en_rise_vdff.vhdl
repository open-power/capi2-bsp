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

ENTITY capi_en_rise_vdff IS
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        en    : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
attribute latch_type : string;
attribute latch_type of dout : signal is "master_latch";
attribute direct_enable : boolean;
attribute direct_enable of en : signal is true;

END capi_en_rise_vdff;

ARCHITECTURE capi_en_rise_vdff OF capi_en_rise_vdff IS

  Signal dout_int : std_logic_vector(0 to width-1) := (others => '0');

begin

    process(clk)
    begin
      if rising_edge(clk) then
        if (en = '1') then
          dout_int <= din;
        end if;
      end if;
    end process;

    dout <= dout_int;

END capi_en_rise_vdff;
