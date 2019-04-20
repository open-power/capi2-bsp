# rerun phys_opt_design several times
# stop optimization when timing is met or timing no longer improves
set card_dir    $::env(CARD_DIR)
set ooc_dir     $::env(CARD_BUILD_OOC)
set ooc_xdcDir  $card_dir/ooc_Sources/xdc

read_xdc $ooc_xdcDir/phys_opt_overcnstr.xdc
set_property USED_IN {implementation out_of_context} [get_files $ooc_xdcDir/phys_opt_overcnstr.xdc]

for { set i 1 } { $i <= 2 } { incr i } {
    if {$i == 1} {
        phys_opt_design -directive AggressiveExplore
        report_timing_summary -file $ooc_dir/phys_opt_1.rpt -max_paths 100
    } else {
        phys_opt_design -directive AlternateFlowWithRetiming
        report_timing_summary -file $ooc_dir/phys_opt_2.rpt -max_paths 100
    }
}         

