############################################################################
############################################################################
##
## Copyright 2018 International Business Machines
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
############################################################################
############################################################################

SHELL=/bin/bash

export FPGA_PART           ?= xcku15p-ffva1156-2-i
export PSL_VERSION         ?= 2.00
export PSL_ROOT_DIR        ?= $(abspath .)
export BUILD_DIR           ?= $(abspath .)/build_$(FPGA_PART)
export PSL9_DIR            ?= $(abspath .)/psl9
export PSL9_SRC            ?= $(PSL9_DIR)/src/verilog
export CREATE_IP_DONE      ?= $(PSL_ROOT_DIR)/.psl_$(FPGA_PART)
export CREATE_IP_TCL       ?= $(PSL_ROOT_DIR)/create_ip.tcl
export PSL_OOC_XDC         ?= $(PSL_ROOT_DIR)/psl9_clocks_ooc.xdc
export PSL9_ENCRYPTED_SRC  ?= "psl9_encrypted_v$(PSL_VERSION).zip"
export PSL9_ENCRYPTED_CORE ?= "ibm.com_CAPI_PSL9_WRAP_$(PSL_VERSION).zip"
export PSL_LOGS_DIR        ?= $(BUILD_DIR)/logs


all: create_ip

PHONY: help unzip_psl9_encrypted psl_ip_create create_ip clean gitclean

help:
	@echo "Main targets for the PSL9 IP generation make process:";
	@echo "=====================================================";
	@echo "* create_ip    Create PSL IP based on encrypted sources"
	@echo "* clean        Remove all files generated in make process";
	@echo "* gitclean     Cleaning and resetting local git clone";
	@echo "* help         Print this message";
	@echo;

# Disabling implicit rule for shell scripts
%: %.sh

unzip_psl9_encrypted:
	@if [ -e "$(PSL_ROOT_DIR)/$(PSL9_ENCRYPTED_CORE)" ]; then \
	    echo "Extracting encrypted PSL9 IP core from file $(PSL_ROOT_DIR)/$(PSL9_ENCRYPTED_CORE)"; \
	    mkdir -p $(PSL9_DIR); \
	    unzip $(PSL_ROOT_DIR)/$(PSL9_ENCRYPTED_CORE) -d $(PSL9_DIR)/ip_repo; \
	elif [ -e "$(PSL_ROOT_DIR)/$(PSL9_ENCRYPTED_SRC)" ]; then \
	    echo "Extracting encrypted PSL9 sources from file $(PSL_ROOT_DIR)/$(PSL9_ENCRYPTED_SRC)"; \
	    unzip $(PSL_ROOT_DIR)/$(PSL9_ENCRYPTED_SRC) -d $(PSL9_DIR); \
	else \
	    echo "ERROR: PSL9 sources not found!"; \
	    echo "ERROR: Missing $(PSL_ROOT_DIR)/$(PSL9_ENCRYPTED_SRC)"; \
	    echo "Please download $(PSL9_ENCRYPTED_SRC) and copy it to $(PSL_ROOT_DIR)"; \
	    echo; exit -1; \
	fi

$(PSL9_DIR):
	@$(MAKE) -s unzip_psl9_encrypted

psl_ip_create: $(PSL9_DIR)
	@echo "[CREATE IP...] start `date "+%Y-%m-%d %H:%M:%S"`"
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(PSL_LOGS_DIR)
	@echo "Creating PSL IP for $(FPGA_PART) ..."
	@cd $(BUILD_DIR) && vivado -quiet -mode batch -source $(CREATE_IP_TCL) -notrace -log $(PSL_LOGS_DIR)/vivado_create_ip.log -journal $(PSL_LOGS_DIR)/vivado_create_ip.jou
	@echo "[CREATE IP...] done  `date "+%Y-%m-%d %H:%M:%S"`"

$(CREATE_IP_DONE):
	$(RM) -r $(BUILD_DIR)
	$(MAKE) -s psl_ip_create
	touch $@

create_ip: $(CREATE_IP_DONE)

clean:
	$(RM) *~
	$(RM) vivado.*
	$(RM) vivado_*backup.*
	$(RM) .psl_*
	$(RM) -r build_*

gitclean:
	@echo "[GITCLEAN............] cleaning and resetting git clone";
	git clean -f -d -x
	git reset --hard
