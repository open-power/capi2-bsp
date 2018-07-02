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

ENTITY capi_fifo IS
  GENERIC (
       ADDR_WIDTH : natural := 1;
       DATA_WIDTH : natural := 32
           );
  PORT (
       clk : in std_logic;
       reset : in std_logic;
       push : in std_logic;
       wrdata : in std_logic_vector(0 to DATA_WIDTH-1);
       pull: in std_logic;
       rddata : out std_logic_vector(0 to DATA_WIDTH-1);
       empty : out std_logic;
       full : out std_logic
        );
END capi_fifo;

ARCHITECTURE capi_fifo OF capi_fifo IS

signal wren : std_logic;
signal rden : std_logic;
signal wrad : std_logic_vector(0 to ADDR_WIDTH - 1);
signal rdad : std_logic_vector(0 to ADDR_WIDTH - 1);
signal empty_int : std_logic;
signal full_int: std_logic;
signal writes_lapped_reads: std_logic;
signal reads_equal_writes: std_logic;

signal bufaddr_width_one: std_logic_vector(0 to ADDR_WIDTH - 1);
signal bufaddr_widthlessone_zeroes: std_logic_vector(0 to ADDR_WIDTH - 2);

BEGIN

  bufaddr_widthlessone_zeroes <= (others => '0');
  bufaddr_width_one <= bufaddr_widthlessone_zeroes & '1';

  wren <= push and not(full_int);
  rden <= pull and not(empty_int);
  writes_lapped_reads <= '1' when (wrad = (std_logic_vector(unsigned(rdad) - 1))) else '0';--write pointer has creeped up on read pointer from behind if next action is only a write.
  reads_equal_writes <= '1' when (rdad = (std_logic_vector(unsigned(wrad) - 1))) else '0';--reads have caught up with writes if next action is only a read.

  --storage for fifo
  fifo_buffer: ENTITY work.capi_ram
    GENERIC MAP (DATA_WIDTH => DATA_WIDTH,
                 ADDR_WIDTH => ADDR_WIDTH
    )
    PORT MAP (
      clk => clk,
      wren => wren,
      wrad => wrad,
      wrdata => wrdata,

      rden => '1',  -- was changed to rden, initially --'1',might vreate issue when flashing mem through PCIe (RB/AC)
      rdad => rdad,
      rddata => rddata
    );

    --update address pointers
    --update full/empty detect
    process(clk)
    begin
      if (clk'event AND clk = '1') then
        if(reset = '1') then
          empty_int <= '1';
          full_int  <= '0';
          wrad  <= (others => '0');
          rdad  <= (others => '0');
        elsif ((wren = '1') and (rden = '1')) then
          empty_int <= empty_int;
          full_int  <= full_int;
          wrad  <= std_logic_vector(unsigned(wrad) + 1);
          rdad  <= std_logic_vector(unsigned(rdad) + 1);
        elsif (wren = '1') then
          empty_int <= '0';
          full_int  <= writes_lapped_reads;
          wrad  <= std_logic_vector(unsigned(wrad) + 1);
          rdad  <= rdad;
        elsif (rden = '1') then
          empty_int <= reads_equal_writes;
          full_int  <= '0';
          wrad  <= wrad;
          rdad  <= std_logic_vector(unsigned(rdad) + 1);
        end if;
      end if;
    end process;

  empty <= empty_int;
  full <= full_int;

END capi_fifo;
