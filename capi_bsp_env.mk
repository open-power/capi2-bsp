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

export COMMON_DIR              ?= $(ROOT_DIR)/common
export COMMON_SRC              ?= $(COMMON_DIR)/src
export COMMON_TCL              ?= $(COMMON_DIR)/tcl
export FPGA_SRC                ?= $(ROOT_DIR)/ultrascale_plus/src
export PSL_DIR                 ?= $(ROOT_DIR)/psl
export PSL_VERSION             ?= 2.00
export CAPI_BSP_VERSION        ?= 1.00
export FPGA_CARD               ?= $@
export CARD_DIR                ?= $(ROOT_DIR)/$(FPGA_CARD)
export CARD_BUILD              ?= $(CARD_DIR)/build
export CARD_IP                 ?= $(CARD_BUILD)/ip
export CARD_CAPI_BSP_GEN       ?= $(CARD_BUILD)/capi_bsp_gen
export CARD_LOGS               ?= $(CARD_BUILD)/logs
export CARD_SRC                ?= $(CARD_DIR)/src
export CARD_TCL                ?= $(CARD_DIR)/tcl
export CARD_XDC                ?= $(CARD_DIR)/xdc
export VIVADO_MODE             ?= batch

export REPOSITORY_BASE         ?= git@github.ibm.com:CAPI2-0HDK
export PSL_CREATE_REPOSITORY   ?= PSL9_ENCRYPT
export PSL_CREATE_BRANCH       ?= v$(PSL_VERSION)
