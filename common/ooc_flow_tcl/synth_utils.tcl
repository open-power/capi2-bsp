###############################################################
### Source scripts need for implementation
###############################################################
source $tclDir/synth.tcl

###############################################################
### Parse PRJ and add all files 
###############################################################
proc add_prj { prj } {
   global srcDir

   if {[file exists $prj]} {
      puts "\tParsing PRJ file: $prj"
      set source [open $prj r]
      set source_data [read $source]
      close $source
      #Remove quotes from PRJ file
      regsub -all {\"} $source_data {} source_data
      set prj_lines [split $source_data "\n" ]
      set line_count 0
      foreach line $prj_lines {
         incr line_count
         #Ignore empty and commented lines
         if {[llength $line] > 0 && ![string match -nocase "#*" $line]} {
            if {[llength $line]!=3} {
               set errMsg "\nERROR: Line $line_count is invalid format. Should be:\n\t<file_type> <library> <file>"
               error $errMsg
            }
            lassign $line type lib file
            if {![string match -nocase $type "dcp"]     && \
                ![string match -nocase $type "header"]  && \
                ![string match -nocase $type "system"]  && \
                ![string match -nocase $type "verilog"] && \
                ![string match -nocase $type "vhdl"]} {
               set errMsg "\nERROR: File type $type is not a supported value.\n"
               append errMsg "Supported types are:\n\tdcp\n\theader\n\tsystem\n\tverilog\n\tvhdl\n\t"
               error $errMsg
            }
            if {[file exists ${srcDir}/$file]} {
               set file ${srcDir}/$file
               command "add_files $file"
               if {[string match -nocase $type "vhdl"]} {
                  command "set_property LIBRARY $lib \[get_files $file\]"
               }
               if {[string match -nocase $type "system"]} {
                  command "set_property FILE_TYPE SystemVerilog \[get_files $file\]"
               }
               if {[string match -nocase $type "header"]} {
                   command "set_property FILE_TYPE {Verilog Header} \[get_files $file\]"
               }
            } elseif {[file exists $file]} {
               command "add_files $file"
               if {[string match -nocase $type "vhdl"]} {
                  command "set_property LIBRARY $lib \[get_files $file\]"
               }
               if {[string match -nocase $type "system"]} {
                  command "set_property FILE_TYPE SystemVerilog \[get_files $file\]"
               }
               if {[string match -nocase $type "header"]} {
                   command "set_property FILE_TYPE {Verilog Header} \[get_files $file\]"
               }
            } else {
               puts "ERROR: Could not find file \"$file\" on line $line_count."
               set error 1
            }
         }
      }
      if {[info exists error]} {
         set errMsg "\nERROR: Files not found. Check messages for more details.\n"
         error $errMsg
      }
   } else {
      set errMsg "\nERROR: Could not find PRJ file $prj"
      error $errMsg
   }
}

###############################################################
### Add all XCI files in list
###############################################################
proc add_ip { ips } {
   upvar resultDir resultDir

   foreach ip $ips {
      if {[string length ip] > 0} { 
         if {[file exists $ip]} {
            set ip_split [split $ip "/"] 
            set xci [lindex $ip_split end]
            set ipPathList [lrange $ip_split 0 end-1]
            set ipPath [join $ipPathList "/"]
            set ipName [lindex [split $xci "."] 0]
            command "add_files $ipPath/$xci"
            if {[get_property GENERATE_SYNTH_CHECKPOINT [get_files $ipPath/$xci]]} {
               if {![file exists $ipPath/${ipName}.dcp]} {
                  puts "\tSynthesizing IP $ipName"
                  command "synth_ip \[get_files $ipPath/$xci]" "$resultDir/${ipName}_synth.log"
               }
            } else {
               puts "\tGenerating output for IP $ipName"
               command "generate_target all \[get_ips $ipName]" "$resultDir/${ipName}_generate.log"
            }
         } else {
            set errMsg "\nERROR: Could not find specified IP file: $ip" 
            error $errMsg
         }
      }
   }
}

###############################################################
### Add all BD files in list
###############################################################
proc add_bd { files } {
   upvar resultDir resultDir

   foreach file $files {
      if {[string length file] > 0} { 
         if {[file exists $file]} {
            set bd_split [split $file "/"] 
            set bd [lindex $bd_split end]
            set bdName [lindex [split $bd "."] 0]
            if {[regexp {.*\.tcl} $file]} {
               command "source $file"
               command "generate_target all \[get_files .srcs/sources_1/bd/${bdName}/${bdName}.bd\]"
            } else {
               command "add_files $file" "$resultDir/add_bd.log"
               command "generate_target all \[get_files $file]" "$resultDir/${bdName}_generate.log"
            }
         } else {
            set errMsg "\nERROR: Could not find specified BD file: $file" 
            error $errMsg
         }
      }
   }
}

###############################################################
### Add all system Verilog files 
###############################################################
proc add_sysvlog { sysvlog } {
   set files [join $sysvlog]
   foreach file $files {
      if {[file exists $file]} {
         command "add_files $file"
         command "set_property FILE_TYPE SystemVerilog \[get_files $file\]"
      } else {
         puts "ERROR: Could not find file \"$file\"."
         set error 1;
      }
   }
   if {[info exists error]} {
      set errMsg "\nERROR: Files not found. Check messages for more details.\n"
      error $errMsg
   }
}

###############################################################
### Add all Verilog files 
###############################################################
proc add_vlog { vlog } {
   set files [join $vlog]
   foreach file $files {
      if {[file exists $file]} {
         command "add_files $file"
      } else {
         puts "ERROR: Could not find file \"$file\"."
         set error 1;
      }
   }
   if {[info exists error]} {
      set errMsg "\nERROR: Files not found. Check messages for more details.\n"
      error $errMsg
   }
}

###############################################################
### Add all VHDL files 
###############################################################
proc add_vhdl { vhdl } {
   set index 0
   while {$index < [llength $vhdl]} {
      set lib [lindex $vhdl [expr $index+1]]
      foreach file [lindex $vhdl $index] {
         if {[file exists $file]} {
            command "add_files $file"
            command "set_property LIBRARY $lib \[get_files $file\]"
         } else {
            puts "ERROR: Could not find file \"$file\"."
            set error 1;
         }
      }
      set index [expr $index+2]
   }
   if {[info exists error]} {
      set errMsg "\nERROR: Files not found. Check messages for more details.\n"
      error $errMsg
   }
}

