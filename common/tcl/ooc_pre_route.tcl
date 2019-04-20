set card_dir    $::env(CARD_DIR)
set xdcDir      $card_dir/ooc_Sources/xdc

read_xdc $xdcDir/routed_normaltiming.xdc
set_property USED_IN {implementation out_of_context} [get_files $xdcDir/routed_normaltiming.xdc]
