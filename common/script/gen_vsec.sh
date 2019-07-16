#!/bin/bash

#This script helps you generate the VPD (Virtual Product Data) (vpd44data_be) used in capi_vsec.vhdl
#The original script comes from https://github.com/open-power/capiflash/blob/master/src/afu/surelock_vpd2rbf 

# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
# TODO                                                                                      TODO
# TODO 1. Write information in new file vpd_CARDNAME.csv, use vpd_FlashGT.csv as template   TODO
# TODO 2. Modify the company_name and card_name!!!                                          TODO
# TODO 3. Run this script "./gen_vsec.sh vpd_CARDNAME.csv"                                  TODO
# TODO 4. Copy/Paste the generated lines into capi_vsec.vhdl                                TODO
# TODO                                                                                      TODO
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 

company_name="ThisCompany"
card_name="ThisCard"
if [ "$1" ]; then
   csv_name=$1
else
   csv_name=vpd_FlashGT
fi
./surelock_vpd2rbf -id "$company_name $card_name PCIe CAPI2 Adapter" -f ${csv_name}.csv

xxd -c 4 -ps ${csv_name}.vpdrbf | perl -ne 'chomp; printf(" when \"%06b\" => vpd44data_be <= X\"%s\";\n",$i,$_); $i++;'
