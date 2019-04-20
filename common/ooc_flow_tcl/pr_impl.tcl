#####################################
#### Implement PR Configurations ####
#####################################
proc pr_impl { impl } {
   global tclParams 
   global part
   global dcpLevel
   global verbose
   global implDir
   global dcpDir
   global configurations 
   global ooc_implementations 

   set top                 [get_attribute config $impl top]
   set implXDC             [get_attribute config $impl implXDC]
   set linkXDC             [get_attribute config $impl linkXDC]
   set cores               [get_attribute config $impl cores]
   set settings            [get_attribute config $impl settings]
   set link                [get_attribute config $impl link]
   set opt                 [get_attribute config $impl opt]
   set opt.pre             [get_attribute config $impl opt.pre]
   set opt_options         [get_attribute config $impl opt_options]
   set opt_directive       [get_attribute config $impl opt_directive]
   set place               [get_attribute config $impl place]
   set place.pre           [get_attribute config $impl place.pre]
   set place_options       [get_attribute config $impl place_options]
   set place_directive     [get_attribute config $impl place_directive]
   set phys                [get_attribute config $impl phys]
   set phys.pre            [get_attribute config $impl phys.pre]
   set phys_options        [get_attribute config $impl phys_options]
   set phys_directive      [get_attribute config $impl phys_directive]
   set route               [get_attribute config $impl route]
   set route.pre           [get_attribute config $impl route.pre]
   set route_options       [get_attribute config $impl route_options]
   set route_directive     [get_attribute config $impl route_directive]
   set drc.quiet           [get_attribute config $impl drc.quiet]
   set budget              [get_attribute config $impl budget]

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

   command "puts \"#HD: Running PR implementation $impl (Partial Reconfiguration)\"" 
   puts "\tWriting results to: $resultDir"
   puts "\tWriting reports to: $reportDir"
   set impl_start [clock seconds]

   #### Set Tcl Params
   if {[info exists tclParams] && [llength $tclParams] > 0} {
      set_parameters $tclParams
   }

   #Create in-memory project
   command "create_project -in_memory -part $part" "$resultDir/create_project.log"

   #Determine state of Static (import or implement). 
   foreach setting $settings {
      lassign $setting name cell state
      if {[string match $cell $top]} {
         set staticName $name
         if {[string match $state "implement"]} {
            set staticState "implement"
         } elseif {[string match $state "import"]} {
            set staticState "import"
         } else {
            set errMsg "\nERROR: Invalid state $state in Configuration settings for $name\($impl).\n"
            error $errMsg
         }
      }
   }
   
   ###########################################
   # Linking
   ###########################################
   if {$link} {
      ###########################################
      # Define the Static sources
      # Determine if Static is being implemented 
      # or imported, and add appropriate source
      ###########################################
      if {[string match $staticState "implement"]} {
         set topFile [get_module_file $staticName]
      } elseif {[string match $staticState "import"]} {
         set topFile "$dcpDir/${top}_static.dcp"
      }
      puts "\tAdding file $topFile for $staticName"
      if {[info exists topFile]} {
         command "add_files $topFile"
      } else {
         set errMsg "\nERROR: No module found with with attribute \"staticName\" equal to $top, which is defined as \"top\" for implementation $impl."
         error $errMsg
      }

      #Read in top-level cores and XDC on first configuration
      if {[string match $staticState "implement"]} { 
         #### Read in IP Netlists 
         if {[llength $cores] > 0} {
            add_cores $cores
         }
 
         #### Read in Static XDC file
         if {[llength $implXDC] > 0} {
            add_xdc $implXDC
         } else {
            puts "\tWarning: No XDC file specified for $impl"
         }
      }

      ################################################
      # Link the Static design with blackboxes for RMs
      ################################################
      set start_time [clock seconds]
      puts "\t#HD: Running link_design for $top \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
      command "link_design -mode default -part $part -top $top" "$resultDir/${top}_link_design.log"
      set end_time [clock seconds]
      log_time link_design $start_time $end_time 1 "link_design -part $part -top $top"

      ################################################
      # Fill in RM blackboxes based on config settings 
      ################################################
      foreach setting $settings {
         lassign $setting name cell state
         if {![string match $cell $top]} {
            if {[string match $state "implement"]} {
               set rmFile [get_module_file $name]
            } elseif {[string match $state "import"]} {
               set rmFile "$dcpDir/${name}_route_design.dcp"
            } elseif {[string match $state "blackbox"]} {
               puts "\tInfo: Cell $cell will be implemented as a blackbox."
            } else {
               set errMsg "\nERROR: Invalid state \"$state\" in settings for $name\($impl)."
               append errMsg"Valid states are \"implement\", \"import\", or \"blackbox\".\n" 
               error $errMsg
            }
            if {[string match $state "blackbox"]} {
               set start_time [clock seconds]
               puts "\tInserting LUT1 buffers on interface of $name \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
               command "update_design -cells $cell -buffer_ports" "$resultDir/update_design_$name.log"
               log_time buffer_port $start_time $end_time 0 "Buffer blackbox RM $name"
            } else {
               set fileSplit [split $rmFile "."]
               set type [lindex $fileSplit end]
               if {[string match $type "dcp"]} {
                  set start_time [clock seconds]
                  puts "\tReading in checkpoint $rmFile for $name \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
                  command "read_checkpoint -cell $cell $rmFile -strict" "$resultDir/read_checkpoint_$name.log"
                  set end_time [clock seconds]
                  log_time read_checkpoint $start_time $end_time 0 "Resolve blacbox for $name"
               } elseif {[string match $type "edf"] || [string match $type "edn"]} {
                  set start_time [clock seconds]
                  puts "\tUpdating design with $rmFile for $name \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
                  command "update_design -cells $cell -from_file $rmFile" "$resultDir/update_design_$name.log"
                  set end_time [clock seconds]
                  log_time update_design $start_time $end_time 0 "Resolve blackbox for $name"
               } else {
                  if {[string match $type "ngc"]} {
                     set errMsg "\nERROR: File of type \"$type\" for $rmFile is not supported for RM modules.\nConvert this file to an EDIF or DCP."
                  } else {
                     set errMsg "\nERROR: Invalid file type \"$type\" for $rmFile.\n RM file type must be DCP, EDN or EDF."
                  }
                  error $errMsg
               }
            }

            ##Mark RM with HD.RECONFIGURABLE if first configuration
            if {[string match $staticState "implement"]} {
               command "set_property HD.RECONFIGURABLE 1 \[get_cells $cell]" "$resultDir/set_HD.RECONFIG.log"
            }

            #Add code to read in module Core files using read_checkpoint or update_design


            #Read in RM XDC if RM is not imported
            if {![string match $state "import"]} { 
               ## Read in RM XDC files 
               set implXDC [get_attribute module $name implXDC]
               if {[llength $implXDC] > 0} {
                  foreach xdc $implXDC {
                     puts "\tReading in implXDC $implXDC for module $name"
                     set start_time [clock seconds]
                     command "read_xdc -cell $cell $xdc" "$resultDir/read_xdc_$name.log"
                     set end_time [clock seconds]
                     log_time read_xdc $start_time $end_time 0 "Cell level XDC for $name"
                  }
               } else {
                  puts "\tINFO: No cell XDC file specified for $cell"
               }
            }

            if {[string match $state "import"]} {
               set start_time [clock seconds]
               puts "\tLocking $cell \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
               command "lock_design -level routing $cell" "lock_design_$name.log"
               set end_time [clock seconds]
               log_time lock_design $start_time $end_time 0 "Lock imported RM $name"
            }

            if {$verbose} {
               set rpPblock [get_pblocks -quiet -of [get_cells $cell]]
               if {![llength $rpPblock]} {
                  set errMsg "ERROR: No pblock found for PR cell $cell."
                  #error $errMsg
               }
            }
         }
      }
   
      ##############################################
      # Bring in OOC module check points on first config
      ##############################################
      if {[llength $ooc_implementations] > 0 && [string match $staticState "implement"]} {
         get_ooc_results $ooc_implementations
      }

      ##############################################
      # Read in any linkXDC files 
      ##############################################
      if {[llength $linkXDC] > 0} {
         readXDC $linkXDC
      }

      ##############################################
      # Write out full logical design checkpoint 
      ##############################################
      puts "\t#HD: Completed link_design"
      puts "\t##########################\n"
      if {$dcpLevel > 0} {
         set start_time [clock seconds]
         command "write_checkpoint -force $resultDir/${top}_link_design.dcp" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time write_checkpoint $start_time $end_time 0 "Post link_design checkpoint"
      }
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
   }
   
   if {$phys} {
      impl_step phys_opt_design $top $phys_options $phys_directive ${phys.pre}
   }
   
   if {$route} {
      impl_step route_design $top $route_options $route_directive ${route.pre}
   
      #Run report_timing_summary on final design
      set start_time [clock seconds]
      command "report_timing_summary -file $reportDir/${top}_timing_summary.rpt" "$resultDir/temp.log"
      set end_time [clock seconds]
      log_time report_timing $start_time $end_time 0 "Timing Summary"
   
      #Run a final DRC that catches any Critical Warnings (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $top bitstream_checks ${drc.quiet}
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "bistream_checks"

      #Report PR specific statitics for debug and analysis
      command "debug::report_design_status" "$reportDir/${top}_design_status.rpt"
   }

   #################################################
   # Export cell level checkpoints for each RM
   # Carve out each RM to leave a blackbox in Static
   # Export Static to be used in other configuration 
   #################################################
   if {![file exists $dcpDir]} {
      command "file mkdir $dcpDir"
   }   

   foreach setting $settings {
      lassign $setting name cell state
      if {![string match $cell $top]} {
         set start_time [clock seconds]
         command "write_checkpoint -force -cell $cell $resultDir/${name}_route_design.dcp" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time write_checkpoint $start_time $end_time 0 "Write cell checkpoint for $name"
         command "file copy -force $resultDir/${name}_route_design.dcp $dcpDir"
         if {[string match $staticState "implement"]} {
            set start_time [clock seconds]
            puts "\tCarving out $cell to be a black box \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
            command "update_design -cell $cell -black_box" "$resultDir/carve_$name.log"
            set end_time [clock seconds]
            log_time update_design $start_time $end_time 0 "Carve out (blackbox) RM $name"
         }
      }
   }


   if {[string match $staticState "implement"]} {
      set start_time [clock seconds]
      puts "\tLocking $top and exporting results \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
      command "lock_design -level routing" "$resultDir/lock_design_$top.log"
      set end_time [clock seconds]
      log_time lock_design $start_time $end_time 0 "Lock placement and routing of Static"
      command "write_checkpoint -force $resultDir/${top}_static.dcp" "$resultDir/temp.log"
      command "file copy -force $resultDir/${top}_static.dcp $dcpDir"
   }


   set impl_end [clock seconds]
   log_time final $impl_start $impl_end 
   log_data $impl $top

   command "close_project"
   command "\n"
   command "puts \"#HD: PR implementation of $impl complete\\n\""
   close $rfh
   close $cfh
   close $wfh
}
