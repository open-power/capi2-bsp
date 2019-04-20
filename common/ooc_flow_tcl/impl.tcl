###########################
#### Implement Modules ####
###########################
proc impl {impl} {
   global tclParams 
   global part
   global dcpLevel
   global verbose
   global implDir
   global xdcDir
   global dcpDir
   global modules
   global ooc_implementations 

   set top                 [get_attribute impl $impl top]
   set implXDC             [get_attribute impl $impl implXDC]
   set linkXDC             [get_attribute impl $impl linkXDC]
   set cores               [get_attribute impl $impl cores]
   set hd                  [get_attribute impl $impl hd.impl]
   set td                  [get_attribute impl $impl td.impl]
   set ic                  [get_attribute impl $impl ic.impl]
   set partitions          [get_attribute impl $impl partitions]
   set link                [get_attribute impl $impl link]
   set opt                 [get_attribute impl $impl opt]
   set opt.pre             [get_attribute impl $impl opt.pre]
   set opt_options         [get_attribute impl $impl opt_options]
   set opt_directive       [get_attribute impl $impl opt_directive]
   set place               [get_attribute impl $impl place]
   set place.pre           [get_attribute impl $impl place.pre]
   set place_options       [get_attribute impl $impl place_options]
   set place_directive     [get_attribute impl $impl place_directive]
   set phys                [get_attribute impl $impl phys]
   set phys.pre            [get_attribute impl $impl phys.pre]
   set phys_options        [get_attribute impl $impl phys_options]
   set phys_directive      [get_attribute impl $impl phys_directive]
   set route               [get_attribute impl $impl route]
   set route.pre           [get_attribute impl $impl route.pre]
   set route_options       [get_attribute impl $impl route_options]
   set route_directive     [get_attribute impl $impl route_directive]
   set bitstream           [get_attribute impl $impl bitstream]
   set bitstream.pre       [get_attribute impl $impl bitstream.pre]
   set bitstream_options   [get_attribute impl $impl bitstream_options]
   set bitstream_settings  [get_attribute impl $impl bitstream_settings]
   set drc.quiet           [get_attribute impl $impl drc.quiet]

   if {($hd && $td) || ($hd && $ic) || ($td && $ic)} {
      set errMsg "\nERROR: Implementation $impl has more than one of the following flow variables set to 1"
      append errMsg "\n\thd.impl($hd)\n\ttd.impl($td)\n\tic.impl($ic)\n"
      append errMsg "Only one of these variables can be set true at one time. To run multiple flows, create separate implementation runs."
      error $errMsg
   }

   set resultDir "$implDir/$impl"
   set reportDir "$resultDir/reports"

   # Make the implementation directory if needed
   if {![file exists $implDir]} {
      file mkdir $implDir
   }

   # Clean-out and re-make the implemenation directory
   file delete -force $resultDir
   file mkdir $resultDir
   file mkdir $reportDir
   
   #Open local log files
   set rfh [open "$resultDir/run.log" w]
   set cfh [open "$resultDir/command.log" w]
   set wfh [open "$resultDir/critical.log" w]

   command "puts \"#HD: Running implementation $impl\""
   puts "\tWriting results to: $resultDir"
   puts "\tWriting reports to: $reportDir"
   set impl_start [clock seconds]

   #### Set Tcl Params
   if {[info exists tclParams] && [llength $tclParams] > 0} {
      set_parameters $tclParams
   }

   #Create in-memory project
   command "create_project -in_memory -part $part" "$resultDir/create_project.log"
   
   ###########################################
   # Linking
   ###########################################
   if {$link} {
      ###########################################
      # Define the top-level sources
      ###########################################
      #Determine state of Top (import or implement). 
      if {[llength $partitions]} {
         foreach partition $partitions {
            lassign $partition module cell state
            if {[string match $cell $top]} {
               if {[string match $state "implement"]} {
                  set topState "implement"
               } elseif {[string match $state "import"]} {
                  set topState "import"
               } else {
                  set errMsg "\nERROR: Invalid state $state in Partition settings for $module\($impl).\n"
                  error $errMsg
               }
            }
         }
      } else {
         set topState "implement"
      }
      foreach module $modules {
         set name [get_attribute module $module moduleName]
         if {[string match $name $top]} {
            if {[string match $topState "implement"]} {
               set topFile [get_module_file $module]
            } elseif {[string match $topState "import"]} {
               set topFile "$dcpDir/${top}_routed.dcp"
            }
         }
      }

      puts "\tAdding file $topFile for $top"
      if {[info exists topFile]} {
         command "add_files $topFile"
      } else {
         set errMsg "\nERROR: No module found with with attribute \"moduleName\" equal to $top, which is defined as \"top\" for implementation $impl."
         error $errMsg
      }
   
      #Read in top-level cores and XDC on if Top is being implemented
      if {[string match $topState "implement"]} { 
         #### Read in IP Netlists 
         if {[llength $cores] > 0} {
            add_cores $cores
         }

         #### Read in XDC file
         if {[llength $implXDC] > 0} {
            add_xdc $implXDC
         } else {
            puts "\tWarning: No XDC file specified for $impl"
         }
      }
   
      ##############################################
      # Link the top-level design with black boxes 
      ##############################################
      set start_time [clock seconds]
      puts "\t#HD: Running link_design for $top \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
      command "link_design -mode default -part $part -top $top" "$resultDir/${top}_link_design.log"
      set end_time [clock seconds]
      log_time link_design $start_time $end_time 1 "link_design -part $part -top $top"
   
      ##############################################
      # Bring in OOC module check points
      ##############################################
      if {$hd && [llength $ooc_implementations] > 0} {
         get_ooc_results $ooc_implementations
      }

      if {$td && $verbose > 0} {
         #Turn phys_opt_design and route_design for TD run
         set phys  [set_attribute impl $impl phys  0]
         set route [set_attribute impl $impl route 0]

         puts "\t#HD: Creating OOC constraints"
         set start_time [clock seconds]
         foreach ooc $ooc_implementations {
            #Set HD.PARTITION and create set_logic_* constraints
            set module [get_attribute ooc $ooc module]
            set instName [get_attribute ooc $ooc inst]
            set hierInst [get_attribute ooc $ooc hierInst]
            set oocFile [get_module_file $module]
            set fileSplit [split $oocFile "."]
            set type [lindex $fileSplit end]
            set start_time [clock seconds]
            puts "\tResolving $hierInst ($module) with $oocFile \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
            if {[string match $type "dcp"]} {
               command "read_checkpoint -cell $hierInst $oocFile -strict" "$resultDir/read_checkpoint_$instName.log"
               set end_time [clock seconds]
               log_time read_checkpoint $start_time $end_time 0 "Resolve blacbox for $instName"
            } elseif {[string match $type "edf"] || [string match $type "edn"]} {
               command "update_design -cells $hierInst -from_file $oocFile" "$resultDir/update_design_$instName.log"
               set end_time [clock seconds]
               log_time update_design $start_time $end_time 0 "Resolve blacbox for $instName"
            } else {
               set errMsg "\nERROR: Invalid file type \"$type\" for $oocFile.\n"
               error $errMsg
            }
            command "set_property HD.PARTITION 1 \[get_cells $hierInst\]"
            create_set_logic $instName $hierInst $xdcDir
            create_ooc_clocks $instName $hierInst $xdcDir
         }
         set end_time [clock seconds]
         log_time "create_ooc" $start_time $end_time 0 "Create necessary OOC constraints"
      }

      #If Partitions are defined, process accordingly
      foreach partition $partitions {
         lassign $partition module cell state
         set moduleName [get_attribute module $module moduleName]
         set name [lindex [split $cell "/"] end]
         if {![string match $moduleName $top]} {
            if {[string match $state "implement"]} {
               set partitionFile [get_module_file $module]
            } elseif {[string match $state "import"]} {
               set partitionFile "$dcpDir/${name}_route_design.dcp"
            } elseif {[string match $state "blackbox"]} {
               puts "\tInfo: Cell $cell will be implemented as a blackbox."
            } else {
               set errMsg "\nERROR: Invalid state \"$state\" in settings for $name\($impl)."
               append errMsg"Valid states are \"implement\", \"import\", or \"blackbox\".\n" 
               error $errMsg
            }

            if {[string match $state "blackbox"]} {
               puts "\tInserting LUT1 buffers on interface of $name"
               command "set_property HD.PARTITION 1 \[get_cells $cell]"
               command "update_design -cells $cell -buffer_ports" "$resultDir/update_design_$name.log"
            } else {
               set fileSplit [split $partitionFile "."]
               set type [lindex $fileSplit end]
               if {[string match $type "dcp"]} {
                  set start_time [clock seconds]
                  puts "\tReading in checkpoint $partitionFile for $cell ($module) \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
                  command "read_checkpoint -cell $cell $partitionFile -strict" "$resultDir/read_checkpoint_$name.log"
                  set end_time [clock seconds]
                  log_time read_checkpoint $start_time $end_time 0 "Resolve blacbox for $name"
               } elseif {[string match $type "edf"] || [string match $type "edn"]} {
                  set start_time [clock seconds]
                  puts "\tUpdating design with $partitionFile for $cell ($module) \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
                  command "update_design -cells $cell -from_file $partitionFile" "$resultDir/update_design_$name.log"
                  set end_time [clock seconds]
                  log_time update_design $start_time $end_time 0 "Resolve blacbox for $name"
               } else {
                  set errMsg "\nERROR: Invalid file type \"$type\" for $partitionFile.\n"
                  error $errMsg
               }
            }

            if {[string match $state "import"]} {
               set start_time [clock seconds]
               puts "\tLocking $cell \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
               command "lock_design -level routing $cell" "$resultDir/lock_design_$name.log"
               set end_time [clock seconds]
               log_time lock_design $start_time $end_time 0 "Locking cell $cell at level routing"
            }

            ##Mark module with HD.PARTITION if being implemented
            if {[string match $state "implement"]} {
               command "set_property HD.PARTITION 1 \[get_cells $cell]"
            }
         }
      }

      ##############################################
      # Read in any linkXDC files 
      ##############################################
      if {[llength $linkXDC] > 0} {
         readXDC $linkXDC
      }

      if {$dcpLevel > 0} {
         set start_time [clock seconds]
         command "write_checkpoint -force $resultDir/${top}_link_design.dcp" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time write_checkpoint $start_time $end_time 0 "Post link_design checkpoint"
      }
      puts "\t#HD: Completed link_design"
      puts "\t##########################\n"

      if {$verbose > 1} {
         set start_time [clock seconds]
         command "report_utilization -file $reportDir/${top}_utilization_link_design.rpt" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time report_utilization $start_time $end_time
      } 
      #Run methodology DRCs and catch any Critical Warnings or Error (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $top methodology_checks 1
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "methodology checks"
      #Run timing DRCs and catch any Critical Warnings or Error (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $top timing_checks 1
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "timing_checks"
   }
   
   ############################################################################################
   # Implementation steps: opt_design, place_design, phys_opt_design, route_design
   ############################################################################################
   if {$opt} {
      impl_step opt_design $top $opt_options $opt_directive ${opt.pre}
   }

   if {$place} {
      impl_step place_design $top $place_options $place_directive ${place.pre}

      #### If Top-Down, write out XDCs 
      if {$td && $verbose > 0} {
         puts "\n\tWriting instance level XDC files."
         foreach ooc $ooc_implementations {
            set instName [get_attribute ooc $ooc inst]
            set hierInst [get_attribute ooc $ooc hierInst]
            write_hd_xdc $instName $hierInst $xdcDir
         }
      }
   }

   if {$phys} {
      impl_step phys_opt_design $top $phys_options $phys_directive ${phys.pre}
   }

   if {$route} {
      impl_step route_design $top $route_options $route_directive ${route.pre}

      #Workaround for RTSTAT-3 DRC bug
      #command "close_project"
      #command "open_checkpoint $resultDir/${top}_route_design.dcp"
 
      #Run report_timing_summary on final design
      set start_time [clock seconds]
      command "report_timing_summary -max_paths 100 -file $reportDir/${top}_timing_summary.rpt" "$resultDir/temp.log"
      set end_time [clock seconds]
      log_time report_timing $start_time $end_time 0 "Timing Summary"
   
      #Run a final DRC that catches any Critical Warnings (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $top bitstream_checks ${drc.quiet}
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "bistream_checks"
   
   }
   
   if {![file exists $dcpDir]} {
      command "file mkdir $dcpDir"
   }   

   #Unplace all top-level logic to in-context partitions can be written out without Exclude Placement
   set unplaceFilter ""
   set partitionCount 0
   set partitionLength [llength $partitions]
   foreach partition $partitions {
      incr partitionCount
      lassign $partition module cell state
      set moduleName [get_attribute module $module moduleName]
      if {![string match $moduleName $top]} {
         if {$partitionCount==$partitionLength} {
            append unplaceFilter "NAME!~$cell/*" 
         } else {
            append unplaceFilter "NAME!~$cell/* && " 
         }
      }
   }
   #command "place_design -unplace -cells \[get_cells -hier -filter \"$unplaceFilter\"\]" "unplace_design.log"
 
   #Write out cell checkpoints for in-context HD flow
   foreach partition $partitions {
      lassign $partition module cell state
      set moduleName [get_attribute module $module moduleName]
      set name [lindex [split $cell "/"] end]
      if {![string match $moduleName $top]} {
         set start_time [clock seconds]
         command "write_checkpoint -force -cell $cell $resultDir/${name}_route_design.dcp" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time write_checkpoint $start_time $end_time 0 "Write cell checkpoint for $name"
         command "file copy -force $resultDir/${name}_route_design.dcp $dcpDir"
   #      if {[string match $topState "implement"]} {
   #         set start_time [clock seconds]
   #         command "update_design -cell $cell -black_box" "$resultDir/carve_$name.log"
   #         set end_time [clock seconds]
   #         log_time update_design $start_time $end_time 0 "Carve out (blackbox) Partition $name"
   #      }
      }
   }

   #if {[llength $partitions] && [string match $topState "implement"]} {
   #   set start_time [clock seconds]
   #   puts "\tLocking $top and exporting results \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
   #   command "lock_design -level routing" "$resultDir/lock_design_$top.log"
   #   set end_time [clock seconds]
   #   log_time lock_design $start_time $end_time 0 "Lock placement and routing of $top"
   #   command "write_checkpoint -force $resultDir/${top}_routed.dcp" "$resultDir/temp.log"
   #   command "file copy -force $resultDir/${top}_routed.dcp $dcpDir"
   #}

   if {$bitstream} {
      impl_step write_bitstream $top $bitstream_options none ${bitstream.pre} $bitstream_settings
   }
   
   set impl_end [clock seconds]
   log_time final $impl_start $impl_end 
   log_data $impl $top

   command "close_project"
   command "puts \"#HD: Implementation $impl complete\\n\""
   close $rfh
   close $cfh
   close $wfh
}
