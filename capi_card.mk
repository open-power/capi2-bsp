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

export ROOT_DIR ?= $(abspath ..)

ifndef FPGA_ACTION_CLK
export FPGA_ACTION_CLK = "250MHZ"
endif

include $(ROOT_DIR)/capi_bsp_env.mk

export PSL_IP             ?= $(PSL_DIR)/build_$(FPGA_PART)/output
export PSL_CREATE_IP_DONE ?= $(PSL_DIR)/.psl_$(FPGA_PART)

.PHONY: help create_ip psl build_ooc clean


help:
	@echo "Main targets for the $(FPGA_CARD) capi_board_support project make process:";
	@echo "====================================================================";
	@echo "* create_ip      Create capi_bsp ip for $(FPGA_DISPLAY) card";
	@echo "* build_ooc      Create capi_bsp pre-routed checkpoint for $(FPGA_DISPLAY) card";
	@echo "* psl            Create encrypted PSL IP";
	@echo "* clean          Remove all files generated in make process";
	@echo "* help           Print this message";
	@echo;


all: create_ip


# Disabling implicit rule for shell scripts
%: %.sh


$(CARD_LOGS):
	@mkdir -p $(CARD_LOGS)


$(CARD_CAPI_BSP_GEN): $(CARD_LOGS)
	@echo "[PREPARE DIRECTORIES.] start "`date +"%T %a %b %d %Y"`
	@mkdir -p $(CARD_CAPI_BSP_GEN)
	@echo "[PREPARE DIRECTORIES.] done  "`date +"%T %a %b %d %Y"`


$(CARD_BUILD_OOC): $(CARD_LOGS)
	@echo "[PREPARE DIRECTORIES.] start "`date +"%T %a %b %d %Y"`
	@mkdir -p $(CARD_BUILD_OOC)/Synth
	@mkdir -p $(CARD_BUILD_OOC)/Implement
	@mkdir -p $(CARD_BUILD_OOC)/Checkpoint
	@echo "[PREPARE DIRECTORIES.] done  "`date +"%T %a %b %d %Y"`


$(PSL_CREATE_IP_DONE):
	@echo "[CREATE PSL IP.......] start "`date +"%T %a %b %d %Y"`
	@$(MAKE) -sC $(PSL_DIR) create_ip
	@echo "[CREATE PSL IP.......] done  "`date +"%T %a %b %d %Y"`
	@touch $@


$(PSL_IP): $(PSL_CREATE_IP_DONE)
	@if [ ! -d $@ ]; then                                                                              \
	    echo "ERROR: Variable PSL_IP needs to point to directory containing the packaged IP for PSL."; \
	    echo "ERROR: Its value is $(PSL_IP)";                                                          \
	    echo "ERROR: That is no valid path.   Terminating.";                                           \
	    exit -1;                                                                                       \
	fi


psl: $(PSL_CREATE_IP_DONE)


$(CARD_DIR)/.create_ip_done: $(PSL_IP)
	@$(MAKE) -s $(CARD_CAPI_BSP_GEN)
	@echo "Starting vivado in $(VIVADO_MODE) mode to generate capi_bsp_wrap IP"
	@vivado -quiet -mode $(VIVADO_MODE) -source $(COMMON_TCL)/create_capi_bsp.tcl -notrace -log $(CARD_LOGS)/vivado_create_project.log  -journal $(CARD_LOGS)/vivado_create_project.jou
	@touch $(CARD_DIR)/.create_ip_done
	@if [ $(FPGA_ACTION_CLK) == "225MHZ" ]; then		\
            touch .action_clk_225MHZ;                           \
        fi
	@if [ $(FPGA_ACTION_CLK) == "250MHZ" ]; then		\
            touch .action_clk_250MHZ;                           \
	fi

$(CARD_DIR)/.create_ooc_done: $(PSL_IP)
	@$(MAKE) -s $(CARD_BUILD_OOC)
	@echo "Starting vivado in $(VIVADO_MODE) mode to generate pre-routed checkpoint (OOC)"
	@echo "It places and routes capi_bsp_wrap. It may take several hours"
	@vivado -quiet -mode $(VIVADO_MODE) -source $(COMMON_TCL)/build_ooc_chkpt.tcl -notrace -log $(CARD_LOGS)/vivado_build_ooc.log  -journal $(CARD_LOGS)/vivado_build_ooc.jou
	@touch $(CARD_DIR)/.create_ooc_done

create_ip: $(CARD_DIR)/.create_ip_done

build_ooc: $(CARD_DIR)/.create_ooc_done

create_ip_ooc:
	@echo "Starting vivado in $(VIVADO_MODE) mode to create capi_bsp_wrap with the OOC checkpoint"
	@vivado -quiet -mode $(VIVADO_MODE) -source $(COMMON_TCL)/create_capi_bsp_ooc.tcl -notrace -log $(CARD_LOGS)/vivado_create_bsp_ooc.log  -journal $(CARD_LOGS)/vivado_create_bsp_ooc.jou


clean:
	@$(RM) *~
	@$(RM) .create_ip_done
	@$(RM) .create_ooc_done
	@$(RM) .action_clk_*
	@$(RM) -r vivado.*
	@$(RM) -r build
	@$(RM) -r .Xil
