set card_dir    $::env(CARD_DIR)
set ooc_xdcDir  $card_dir/ooc_Sources/xdc
set xdcDir      $card_dir/xdc   
read_xdc $ooc_xdcDir/ooc_bsp_black_box.xdc
read_xdc $ooc_xdcDir/ooc_bsp_phys.xdc
read_xdc $xdcDir/capi_bsp_io.xdc
read_xdc $xdcDir/capi_bsp_config.xdc
