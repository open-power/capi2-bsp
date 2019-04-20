set VIVADO_CAPI_PROJECT_DIR [get_property DIRECTORY [current_project]]
link_design -mode default -top psl_fpga -part xcku060-ffva1156-2-e
set_property HD.PARTITION 1 [get_cells b]
read_checkpoint -cell b -strict $VIVADO_CAPI_PROJECT_DIR/../../../Checkpoint/b_route_design.dcp
lock_design -level routing b
