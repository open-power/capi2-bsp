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

ENTITY capi_gpio IS
  PORT(dataio: inout std_logic;
       dataout: out std_logic;
       datain: in std_logic;
       oe: in std_logic);

END capi_gpio;

ARCHITECTURE capi_gpio OF capi_gpio IS

signal dataout_int: std_logic;

begin

IOBUF_inst : IOBUF
  port map (
  O     => dataout_int,   -- Buffer output
  IO    => dataio,    -- Buffer inout port (connect directly to top-level port)
  I     => datain,    -- Buffer input
  T     => oe       -- 3-state enable input, high=input, low=output
  );
  dataout <= dataout_int;

END capi_gpio;
