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
//
// *!***************************************************************************

module CAPI_STP_COUNTER
(
   input    CLK                                                 ,
   input    RESET                                               ,
   output   STP_COUNTER_1sec                                    ,
   output   STP_COUNTER_MSB
);

// Wire/Reg declaration
   reg [39:0]    capi_stp_counter_l  = 40'h0                    ;

   always @(posedge CLK)
     if (RESET)
       capi_stp_counter_l   <= 40'b0                            ;

     else
       capi_stp_counter_l   <= capi_stp_counter_l + 40'd1       ;

   assign 	 STP_COUNTER_1sec = capi_stp_counter_l[30]      ;
   assign 	 STP_COUNTER_MSB  = capi_stp_counter_l != 40'd1 ;

endmodule
