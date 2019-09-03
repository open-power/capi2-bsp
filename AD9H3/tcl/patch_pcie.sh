#!/bin/sh
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

SCRIPT=$(readlink -f "$0")
DIR=$(dirname $SCRIPT)
cd $DIR

cp pcie4c_uscale_plus_vsec_cap_0xB0.patch ip/pcie4c_uscale_plus_0/synth/
cd ip/pcie4c_uscale_plus_0/synth/
patch < pcie4c_uscale_plus_vsec_cap_0xB0.patch
