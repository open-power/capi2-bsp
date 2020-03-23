// *!***************************************************************************
// *! Copyright 2014-2018 International Business Machines
// *!
// *! Licensed under the Apache License, Version 2.0 (the "License");
// *! you may not use this file except in compliance with the License.
// *! You may obtain a copy of the License at
// *!
// *!     http://www.apache.org/licenses/LICENSE-2.0
// *!
// *! Unless required by applicable law or agreed to in writing, software
// *! distributed under the License is distributed on an "AS IS" BASIS,
// *! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// *! See the License for the specific language governing permissions and
// *! limitations under the License.
// *!
// *!***************************************************************************

module CAPI_FPGA_RESET_GEN
(
   input    PLL_LOCKED                                       ,
   input    CLK                                              ,
   output   RESET
);

// Reset length
   parameter COUNT_TO = 10'd1000                             ;
// Wire/Reg declaration
   reg [9:0]     pll_locked_counter_l                        ;
   reg           reset_reg                                   ;

   wire          rst_pll_lock_n                              ;

   always @(posedge CLK or negedge PLL_LOCKED)
     if (!PLL_LOCKED)
       pll_locked_counter_l   <= 10'b0                       ;

     else if (pll_locked_counter_l != COUNT_TO)
       pll_locked_counter_l <= pll_locked_counter_l + 10'd1  ;

   always @(posedge CLK)
     reset_reg <= pll_locked_counter_l != COUNT_TO           ;

   assign RESET = reset_reg                                  ;

endmodule
