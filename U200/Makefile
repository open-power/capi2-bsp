#
# Copyright 2018 International Business Machines
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

SHELL=/bin/bash

export FPGA_CARD    = U200
export FPGA_DISPLAY = "Xilinx-U200"

#Note: Set FPGA_PART first, then change to BOARD_PART
export FPGA_PART    = xcu200-fsgd2104-2-e
export BOARD_PART   = xilinx.com:au200:part0:1.0
export FPGA_SRC     = $(ROOT_DIR)/ultrascale_plus/src

include ../capi_card.mk
