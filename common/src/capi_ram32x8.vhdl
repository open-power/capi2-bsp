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

ENTITY capi_ram32x8 IS
  PORT (clk   : in  std_logic;
        q     : out std_logic_vector(0 to 7);
        rdad  : in  std_logic_vector(0 to 4);
        rden  : in  std_logic;
        data  : in  std_logic_vector(0 to 7);
        wrad  : in  std_logic_vector(0 to 4);
        wren  : in  std_logic);

END capi_ram32x8;

ARCHITECTURE capi_ram32x8 OF capi_ram32x8 IS

type storage IS ARRAY(natural range <>) OF std_logic_vector(0 TO 7);
signal r : storage (0 TO 31);
attribute ram_style : string;
attribute ram_style of r : signal is "distributed";

begin

    process(clk)
    begin -- Width < 32
      if rising_edge(clk) then
        if (wren = '1') then
          r(to_integer(unsigned(wrad))) <= data;
        end if;

        if (rden = '1') then
          q <= r(to_integer(unsigned(rdad)));
        end if;
      end if;
    end process;
END capi_ram32x8;
