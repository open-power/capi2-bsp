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
export ROOT_DIR ?= $(abspath .)

export CARDS += AD9V3 N250SP RCXVUP FX609 S241

include $(ROOT_DIR)/capi_bsp_env.mk

.PHONY: help $(CARDS) clean


help:
	@echo "Main targets for the capi_board_support project make process:";
	@echo "=============================================================";
	@echo "* AD9V3          Creates capi_bsp ip for AlphaData 9V3 card";
	@echo "* N250SP         Creates capi_bsp ip for Nallatech 250S+ card";
	@echo "* RCXVUP         Creates capi_bsp ip for XpressVUP-LP9PT card";
	@echo "* FX609          Creates capi_bsp ip for Flyslice-FX609QL card";
	@echo "* S241           Creates capi_bsp ip for Semptian S241 card";
	@echo "* clean          Removes all files generated in make process";
	@echo "* help           Prints this message";
	@echo "* Example : make AD9V3";


all: $(CARDS)


# Disabling implicit rule for shell scripts
%: %.sh


$(CARDS):
	@if [ -d $@ ]; then                                         \
	    $(MAKE) -sC $@ create_ip || exit -1;                    \
	else                                                        \
	    echo "ERROR: Directory $@ doesn't exist. Terminating."; \
	    exit -1;                                                \
	fi


clean:
	@echo "[CLEANING............] start "`date +"%T %a %b %d %Y"`
	@for dir in $(CARDS); do                   \
	    if [ -d $$dir ]; then                  \
	        $(MAKE) -s -C  $$dir $@ || exit 1; \
	    fi                                     \
	done
	@$(RM) *~
	@$(RM) -r vivado*
	@$(RM) -r .Xil
	@echo "[CLEANING............] done  "`date +"%T %a %b %d %Y"`
