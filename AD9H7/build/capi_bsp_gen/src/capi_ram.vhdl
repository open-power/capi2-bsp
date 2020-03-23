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

ENTITY capi_ram IS
  GENERIC (
       ADDR_WIDTH : natural := 1;
       DATA_WIDTH : natural := 32
           );
  PORT (
       clk : in std_logic;
       wren : in std_logic;
       wrad : in std_logic_vector(0 to ADDR_WIDTH-1);
       wrdata : in std_logic_vector(0 to DATA_WIDTH-1);

       rden: in std_logic;
       rdad : in std_logic_vector(0 to ADDR_WIDTH-1);
       rddata : out std_logic_vector(0 to DATA_WIDTH-1)
        );
END capi_ram;

ARCHITECTURE capi_ram OF capi_ram IS

ATTRIBUTE array_update : string;
constant DEPTH : natural := 2**ADDR_WIDTH;
type storage IS ARRAY(0 to DEPTH - 1) OF std_logic_vector(0 TO DATA_WIDTH - 1);
signal r : storage := (others => (others => '0'));
ATTRIBUTE array_update of r : signal is "RW";

BEGIN

    process(clk)
    begin 
      if (clk'event AND clk = '1') then
        if (wren = '1') then
          r(to_integer(unsigned(wrad))) <= wrdata;
        end if;

        if (rden = '1') then
          rddata <= r(to_integer(unsigned(rdad)));
        end if;
      end if;
    end process;

END capi_ram;
