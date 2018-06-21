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

ENTITY capi_gpio12 IS
  PORT(pin: inout std_logic_vector(0 to 11);
       id: out std_logic_vector(0 to 11);
       od: in std_logic_vector(0 to 11);
       oe: in std_logic);   -- 0: output 1: input

END capi_gpio12;

ARCHITECTURE capi_gpio12 OF capi_gpio12 IS

Component capi_gpio
  PORT(dataio: inout std_logic;
       dataout: out std_logic;
       datain: in std_logic;
       oe: in  std_logic );   -- 0: output 1: input
End Component capi_gpio;

begin

io_0: capi_gpio PORT MAP ( dataio=>pin(0), dataout=>id(0), datain=>od(0), oe=>oe );
io_1: capi_gpio PORT MAP ( dataio=>pin(1), dataout=>id(1), datain=>od(1), oe=>oe );
io_2: capi_gpio PORT MAP ( dataio=>pin(2), dataout=>id(2), datain=>od(2), oe=>oe );
io_3: capi_gpio PORT MAP ( dataio=>pin(3), dataout=>id(3), datain=>od(3), oe=>oe );
io_4: capi_gpio PORT MAP ( dataio=>pin(4), dataout=>id(4), datain=>od(4), oe=>oe );
io_5: capi_gpio PORT MAP ( dataio=>pin(5), dataout=>id(5), datain=>od(5), oe=>oe );
io_6: capi_gpio PORT MAP ( dataio=>pin(6), dataout=>id(6), datain=>od(6), oe=>oe );
io_7: capi_gpio PORT MAP ( dataio=>pin(7), dataout=>id(7), datain=>od(7), oe=>oe );
io_8: capi_gpio PORT MAP ( dataio=>pin(8), dataout=>id(8), datain=>od(8), oe=>oe );
io_9: capi_gpio PORT MAP ( dataio=>pin(9), dataout=>id(9), datain=>od(9), oe=>oe );
io_10: capi_gpio PORT MAP ( dataio=>pin(10), dataout=>id(10), datain=>od(10), oe=>oe );
io_11: capi_gpio PORT MAP ( dataio=>pin(11), dataout=>id(11), datain=>od(11), oe=>oe );

END capi_gpio12;
