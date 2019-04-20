set modules             [list ]
set ooc_implementations [list ]
set implementations     [list ]
set configurations      [list ]

set opt_directives   [list Explore                \
                           ExploreArea            \
                           AddRemap               \
                           ExploreSequentialArea  \
                           RuntimeOptimized       \
                     ]
set place_directives [list Explore                \
                           WLDrivenBlockPlacement \
                           LateBlockPlacement     \
                           ExtraNetDelay_high     \
                           ExtraNetDelay_medium   \
                           ExtraNetDelay_low      \
                           SpreadLogic_high       \
                           SpreadLogic_medium     \
                           SpreadLogic_low        \
                           ExtraPostPlacementOpt  \
                           SSI_ExtraTimingOpt     \
                           SSI_SpreadSLLs         \
                           SSI_BalanceSLLs        \
                           SSI_BalanceSLRs        \
                           SSI_HighSLRs           \
                           RuntimeOptimized       \
                           Quick                  \
                           Default                \
                     ]
set phys_directives  [list Explore                \
                           ExploreWithHoldFix     \
                           AggressiveExplore      \
                           AlternateReplication   \
                           AggressiveFanoutOpt    \
                           AlternateDelayModeling \
                           AddRetime              \
                           Default                \
                     ]
set route_directives [list Explore                \
                           NoTimingRelaxation     \
                           MoreGlobalIterations   \
                           HigherDelayCost        \
                           AdvancedSkewModeling   \
                           RuntimeOptimized       \
                           Quick                  \
                           Default                \
                      ]


array set module_attributes [list "moduleName"           [list string   null]  \
                                  "top_level"            [list boolean {0 1}]  \
                                  "prj"                  [list string   null]  \
                                  "includes"             [list string   null]  \
                                  "generics"             [list string   null]  \
                                  "vlog_headers"         [list string   null]  \
                                  "vlog_defines"         [list string   null]  \
                                  "sysvlog"              [list string   null]  \
                                  "vlog"                 [list string   null]  \
                                  "vhdl"                 [list string   null]  \
                                  "ip"                   [list string   null]  \
                                  "ipRepo"               [list string   null]  \
                                  "bd"                   [list string   null]  \
                                  "cores"                [list string   null]  \
                                  "xdc"                  [list string   null]  \
                                  "synthXDC"             [list string   null]  \
                                  "implXDC"              [list string   null]  \
                                  "synth"                [list boolean {0 1}]  \
                                  "synth_options"        [list string   null]  \
                                  "synthCheckpoint"      [list string   null]  \
                            ]

array set config_attributes [list "top"                  [list string   null]  \
                                  "implXDC"              [list string   null]  \
                                  "linkXDC"              [list string   null]  \
                                  "cores"                [list string   null]  \
                                  "impl"                 [list boolean {0 1}]  \
                                  "settings"             [list string   null]  \
                                  "link"                 [list boolean {0 1}]  \
                                  "opt"                  [list boolean {0 1}]  \
                                  "opt.pre"              [list string   null]  \
                                  "opt_options"          [list string   null]  \
                                  "opt_directive"        [list enum     $opt_directives]   \
                                  "place"                [list boolean {0 1}]  \
                                  "place.pre"            [list string   null]  \
                                  "place_options"        [list string   null]  \
                                  "place_directive"      [list enum     $place_directives] \
                                  "phys"                 [list boolean {0 1}]  \
                                  "phys.pre"             [list string   null]  \
                                  "phys_options"         [list string   null]  \
                                  "phys_directive"       [list enum     $phys_directives]  \
                                  "route"                [list boolean {0 1}]  \
                                  "route.pre"            [list string   null]  \
                                  "route.post"           [list string   null]  \
                                  "route_options"        [list string   null]  \
                                  "route_directive"      [list enum     $route_directives] \
                                  "verify"               [list boolean {0 1}]  \
                                  "bitstream"            [list boolean {0 1}]  \
                                  "bitstream.pre"        [list string   null]  \
                                  "bitstream_options"    [list string   null]  \
                                  "bitstream_settings"   [list string   null]  \
                                  "drc.quiet"            [list boolean {0 1}]  \
                                  "budget"               [list boolean {0 1}]  \
                            ]

array set impl_attributes   [list "top"                  [list string   null]  \
                                  "implXDC"              [list string   null]  \
                                  "linkXDC"              [list string   null]  \
                                  "cores"                [list string   null]  \
                                  "impl"                 [list boolean {0 1}]  \
                                  "hd.impl"              [list boolean {0 1}]  \
                                  "td.impl"              [list boolean {0 1}]  \
                                  "ic.impl"              [list boolean {0 1}]  \
                                  "partitions"           [list string   null]  \
                                  "link"                 [list boolean {0 1}]  \
                                  "opt"                  [list boolean {0 1}]  \
                                  "opt.pre"              [list string   null]  \
                                  "opt_options"          [list string   null]  \
                                  "opt_directive"        [list enum     $opt_directives]   \
                                  "place"                [list boolean {0 1}]  \
                                  "place.pre"            [list string   null]  \
                                  "place_options"        [list string   null]  \
                                  "place_directive"      [list enum     $place_directives] \
                                  "phys"                 [list boolean {0 1}]  \
                                  "phys.pre"             [list string   null]  \
                                  "phys_options"         [list string   null]  \
                                  "phys_directive"       [list enum     $phys_directives]  \
                                  "route"                [list boolean {0 1}]  \
                                  "route.pre"            [list string   null]  \
                                  "route.post"           [list string   null]  \
                                  "route_options"        [list string   null]  \
                                  "route_directive"      [list enum     $route_directives] \
                                  "bitstream"            [list boolean {0 1}]  \
                                  "bitstream.pre"        [list string   null]  \
                                  "bitstream_options"    [list string   null]  \
                                  "bitstream_settings"   [list string   null]  \
                                  "drc.quiet"            [list boolean {0 1}]  \
                            ]

array set ooc_attributes    [list "module"               [list string   null]  \
                                  "inst"                 [list string   null]  \
                                  "hierInst"             [list string   null]  \
                                  "implXDC"              [list string   null]  \
                                  "cores"                [list string   null]  \
                                  "impl"                 [list boolean {0 1}]  \
                                  "hd.isolated"          [list boolean {0 1}]  \
                                  "budget.create"        [list boolean {0 1}]  \
                                  "budget.percent"       [list integer  null]  \
                                  "link"                 [list boolean {0 1}]  \
                                  "opt"                  [list boolean {0 1}]  \
                                  "opt.pre"              [list string   null]  \
                                  "opt_options"          [list string   null]  \
                                  "opt_directive"        [list enum     $opt_directives]   \
                                  "place"                [list boolean {0 1}]  \
                                  "place.pre"            [list string   null]  \
                                  "place_options"        [list string   null]  \
                                  "place_directive"      [list enum     $place_directives] \
                                  "phys"                 [list boolean {0 1}]  \
                                  "phys.pre"             [list string   null]  \
                                  "phys_options"         [list string   null]  \
                                  "phys_directive"       [list enum     $phys_directives]  \
                                  "route"                [list boolean {0 1}]  \
                                  "route.pre"            [list string   null]  \
                                  "route.post"           [list string   null]  \
                                  "route_options"        [list string   null]  \
                                  "route_directive"      [list enum     $route_directives] \
                                  "bitstream"            [list boolean {0 1}]  \
                                  "bitstream.pre"        [list string   null]  \
                                  "bitstream_options"    [list string   null]  \
                                  "bitstream_settings"   [list string   null]  \
                                  "implCheckpoint"       [list string   null]  \
                                  "preservation"         [list enum    {logical placement routing}] \
                                  "drc.quiet"            [list boolean {0 1}]  \
                             ]
   

###############################################################
### Define a top-level implementation
###############################################################
proc add_implementation { name } {
   global implementations
   set procname [lindex [info level 0] 0]
   
   if {[lsearch -exact $implementations $name] >= 0} {
      set errMsg "\nERROR: Implementation $name is already defined"
      error $errMsg
   }

   lappend implementations $name
   set_attribute impl $name "top"                 ""
   set_attribute impl $name "implXDC"             "" 
   set_attribute impl $name "linkXDC"             "" 
   set_attribute impl $name "cores"               ""
   set_attribute impl $name "impl"                0
   set_attribute impl $name "hd.impl"             0
   set_attribute impl $name "td.impl"             0
   set_attribute impl $name "ic.impl"             0
   set_attribute impl $name "partitions"          [list ]
   set_attribute impl $name "link"                1
   set_attribute impl $name "opt"                 1
   set_attribute impl $name "opt.pre"             ""
   set_attribute impl $name "opt_options"         ""
   set_attribute impl $name "opt_directive"       ""
   set_attribute impl $name "place"               1
   set_attribute impl $name "place.pre"           ""
   set_attribute impl $name "place_options"       ""
   set_attribute impl $name "place_directive"     ""
   set_attribute impl $name "phys"                1
   set_attribute impl $name "phys.pre"            ""
   set_attribute impl $name "phys_options"        ""
   set_attribute impl $name "phys_directive"      ""
   set_attribute impl $name "route"               1
   set_attribute impl $name "route.pre"           ""
   set_attribute impl $name "route.post"          ""
   set_attribute impl $name "route_options"       ""
   set_attribute impl $name "route_directive"     ""
   set_attribute impl $name "bitstream"           0
   set_attribute impl $name "bitstream.pre"       ""
   set_attribute impl $name "bitstream_options"   ""
   set_attribute impl $name "bitstream_settings"  ""
   set_attribute impl $name "drc.quiet"           0
}

###############################################################
### Define a PR configuration
###############################################################
proc add_configuration { name } {
  global configurations

   if {[lsearch -exact $configurations $name] >= 0} {
      set errMsg "\nERROR: Configuration $name is already defined"
      error $errMsg
   }

   lappend configurations $name
   set_attribute config $name "top"                 ""
   set_attribute config $name "implXDC"             "" 
   set_attribute config $name "linkXDC"             "" 
   set_attribute config $name "cores"               ""
   set_attribute config $name "settings"            [list ]
   set_attribute config $name "impl"                0 
   set_attribute config $name "link"                1
   set_attribute config $name "opt"                 1
   set_attribute config $name "opt.pre"             ""
   set_attribute config $name "opt_options"         ""
   set_attribute config $name "opt_directive"       ""
   set_attribute config $name "place"               1
   set_attribute config $name "place.pre"           ""
   set_attribute config $name "place_options"       ""
   set_attribute config $name "place_directive"     ""
   set_attribute config $name "phys"                1
   set_attribute config $name "phys.pre"            ""
   set_attribute config $name "phys_options"        ""
   set_attribute config $name "phys_directive"      ""
   set_attribute config $name "route"               1
   set_attribute config $name "route.pre"           ""
   set_attribute config $name "route.post"          ""
   set_attribute config $name "route_options"       ""
   set_attribute config $name "route_directive"     ""
   set_attribute config $name "verify"              0
   set_attribute config $name "bitstream"           0
   set_attribute config $name "bitstream.pre"       ""
   set_attribute config $name "bitstream_options"   ""
   set_attribute config $name "bitstream_settings"  ""
   set_attribute config $name "drc.quiet"           0
   set_attribute config $name "budget"              0
}

###############################################################
### Define an OOC implementation
###############################################################
proc add_ooc_implementation { name } {
   global ooc_implementations
   global dcpDir

   set procname [lindex [info level 0] 0]
   
   if {[lsearch -exact $ooc_implementations $name] >= 0} {
      set errMsg "\nERROR: OOC implementation $name is already defined"
      error $errMsg
   }

   lappend ooc_implementations $name
   set_attribute ooc $name "module"              ""
   set_attribute ooc $name "inst"                "$name"
   set_attribute ooc $name "hierInst"            ""
   set_attribute ooc $name "implXDC"             "" 
   set_attribute ooc $name "cores"               ""
   set_attribute ooc $name "impl"                0
   set_attribute ooc $name "hd.isolated"         0
   set_attribute ooc $name "budget.create"       0
   set_attribute ooc $name "budget.percent"      50
   set_attribute ooc $name "link"                1
   set_attribute ooc $name "opt"                 1
   set_attribute ooc $name "opt.pre"             ""
   set_attribute ooc $name "opt_options"         ""
   set_attribute ooc $name "opt_directive"       ""
   set_attribute ooc $name "place"               1
   set_attribute ooc $name "place.pre"           ""
   set_attribute ooc $name "place_options"       ""
   set_attribute ooc $name "place_directive"     ""
   set_attribute ooc $name "phys"                1
   set_attribute ooc $name "phys.pre"            ""
   set_attribute ooc $name "phys_options"        ""
   set_attribute ooc $name "phys_directive"      ""
   set_attribute ooc $name "route"               1
   set_attribute ooc $name "route.pre"           ""
   set_attribute ooc $name "route.post"          ""
   set_attribute ooc $name "route_options"       ""
   set_attribute ooc $name "route_directive"     ""
   set_attribute ooc $name "bitstream"           0
   set_attribute ooc $name "bitstream.pre"       ""
   set_attribute ooc $name "bitstream_options"   ""
   set_attribute ooc $name "bitstream_settings"  ""
   set_attribute ooc $name "implCheckpoint"      "$dcpDir/${name}_route_design.dcp"
   set_attribute ooc $name "preservation"        "routing"
   set_attribute ooc $name "drc.quiet"           0
}
   
###############################################################
### Add a module
###############################################################
proc add_module { name } {
   global modules

   if {[lsearch -exact $modules $name] >= 0} {
      set errMsg "\nERROR: Module $name is already defined"
      error $errMsg
   }

   lappend modules $name
   set_attribute module $name "moduleName"       $name
   set_attribute module $name "top_level"        0
   set_attribute module $name "prj"              ""
   set_attribute module $name "includes"         ""
   set_attribute module $name "generics"         ""
   set_attribute module $name "vlog_headers"     [list ]
   set_attribute module $name "vlog_defines"     ""
   set_attribute module $name "sysvlog"          [list ]
   set_attribute module $name "vlog"             [list ]
   set_attribute module $name "vhdl"             [list ]
   set_attribute module $name "ip"               [list ]
   set_attribute module $name "ipRepo"           [list ]
   set_attribute module $name "bd"               [list ]
   set_attribute module $name "cores"            [list ]
   set_attribute module $name "xdc"              [list ]
   set_attribute module $name "synthXDC"         [list ]
   set_attribute module $name "implXDC"          [list ]
   set_attribute module $name "synth"            0 
   set_attribute module $name "synth_options"    "-flatten_hierarchy rebuilt" 
   set_attribute module $name "synthCheckpoint"  ""
}

###############################################################
### Set an implementation attribute
###############################################################
proc set_attribute { type name attribute {value null} } {
   global ${type}Attribute
   set procname [lindex [info level 0] 0]

   switch -exact -- $type {
      module  {set list_type "modules"}
      ooc     {set list_type "ooc_implementations"}
      impl    {set list_type "implementations"}
      config  {set list_type "configurations"}
      default {error "\nERROR: Invalid type $type specified"}
   }

   check_list $list_type $name $procname
   check_attribute $type $attribute $procname
   if {![string match $value "null"]} {
      check_attribute_value $type $attribute $value
      set ${type}Attribute(${name}.$attribute) $value
   } else {
      puts "Critical Warning: Attribute $attribute for $type $name is set to $value. The value will not be modified."
   }
   return $value
}

###############################################################
### Get an implementation attribute
###############################################################
proc get_attribute { type name attribute } {
   global ${type}Attribute
   set procname [lindex [info level 0] 0]

   switch -exact -- $type {
      module  {set list_type "modules"}
      ooc     {set list_type "ooc_implementations"}
      impl    {set list_type "implementations"}
      config  {set list_type "configurations"}
      default {error "\nERROR: Invalid type $type specified"}
   }

   check_list $list_type $name $procname
   check_attribute $type $attribute $procname
   return [subst -nobackslash \$${type}Attribute(${name}.$attribute)]
}

###############################################################
### Check if attribute exists
###############################################################
proc check_attribute { type attribute procname } {
   global ${type}_attributes
   set attributes [array names ${type}_attributes]
   if {[lsearch -exact $attributes $attribute] < 0} {
      set errMsg "\nERROR: Invalid \'$type\' attribute $attribute specified in $procname"
      error $errMsg
   }
}


###############################################################
### Check if attribute value matches type
###############################################################
proc check_attribute_value { type attribute value } {
   global ${type}_attributes 
   
   if {[info exists ${type}_attributes($attribute)]} {
      lassign [subst -nobackslashes \$${type}_attributes($attribute)] attr_type attr_values
      if {![string match $attr_values "null"] && [llength $value]} {
         set pass 0
         if {[string match $attr_type "boolean"]} {
            foreach attr_value $attr_values {
               if {$attr_value==$value} {
                  set pass 1
               }
            }
         } elseif {[string match $attr_type "enum"]} {
            foreach attr_value $attr_values {
               if {[string match $attr_value $value]} {
                  set pass 1
               }
            }
         } else {
            set errMsg "\nERROR: Attribute type \'$attr_type\' for $type attribute \'$attribute\' is not set to null.\n"
            append errMsg "This attribute type not currently supported to be checked.\n"
            append errMsg "Modify this attribute value to be \'null\', or change the type to a supported value."
            error $errMsg 
         }
         if {$pass==0} {
            set errMsg "\nERROR: Value \'$value\' of $type attribute $attribute of type $attr_type is not valid.\n"
            append errMsg "Supported values are: $attr_values"
            error $errMsg
         }
      }
   } else {
      set errMsg "\nERROR: Could not find attribute $attribute in array ${type}_attributes."
      error $errMsg
   }
}

###############################################################
### Check if object exists
###############################################################
proc check_list { list_type name procname } {
   global [subst $list_type]
   if {[lsearch -exact [subst -nobackslash \$$list_type] $name] < 0} {
      set errMsg "\nERROR: Invalid $list_type \'$name\' specified in $procname"
      error $errMsg 
   }
}

###############################################################
### Override directives with global values
###############################################################
proc set_directives {$type $name} {
   global Directives
     
   set_attribute $type $name opt_directive   $Directives(opt)
   set_attribute $type $name place_directive $Directives(place)
   set_attribute $type $name phys_directive  $Directives(phys)
   set_attribute $type $name route_directive $Directives(route)
}

###############################################################
### Sorts the list of configurations to put any configuration
### that implements Static at the beginning of the list. This
### prevents having to worry about what order the configurations
### are defined in design.tcl, or allows them to easily be changed.
###############################################################
proc sort_configurations { } {
   global configurations

   set configs "" 

   #Sort list of configurations. Insert "initial" config at beginning of list.
   foreach configuration $configurations {
      set settings [get_attribute config $configuration settings]
      set top      [get_attribute config $configuration top]
      foreach setting $settings {
         lassign $setting name module state
         if {[string match $module $top]} {
            if {[string match -nocase $state "implement"]} {
               set configs [linsert $configs 0 $configuration]
            } else {
               lappend configs $configuration
            }
         }
      }
   }

   puts "\n#HD: Sorted list of configurations:"
   foreach config $configs {
      set settings  [get_attribute config $config settings]
      set impl      [get_attribute config $config impl]
      set verify    [get_attribute config $config verify]
      set bitstream [get_attribute config $config bitstream]
      foreach setting $settings {
         lassign $setting name module state
         if {[string match -nocase $state "import"]} {
            #Add spaces to align print statement
            set state "import   "
         }
         if {[string match $module $top]} {
            puts "\t${config}\n\t\t(Static: $state\tImplement: $impl\tVerify: $verify\tBitstream: $bitstream\)"
         }
      }
   }
   puts "\n"

   #Make sure no configurations get lost in the sort
   if {[llength $configs] == [llength $configurations]} {
      set configurations $configs
   } else {
      set errMsg "\nERROR: Number of configurations changed during sorting process." 
      error $errMsg
   }
}

###############################################################
### Set specified parameters
###############################################################
proc set_parameters {params} {
   command "puts \"#HD: Setting Tcl Params:\""
   foreach {name value} $params   {
      puts "\t$name == $value"
      command "set_param $name $value"
   }
}
