############################
#### Pt proc scripts
#### version 1.0
#### 2022.11.01
############################

proc proc_get_timing_paths_GROUP {path_group max_paths nworst slack_lesser_than} {
    global timing_paths_GROUP
    set clk_cpu_paths [get_timing_paths -group $path_group -max_paths $max_paths -nworst $nworst -slack_lesser_than $slack_lesser_than]
    puts "<CMD> get_timing_path -group $path_group -max_paths $max_paths -noworst $noworst -slack_lesser_than $slack_lesser_than"
    puts "Have violation path:[sizeof_collection $clk_cpu_paths]"
    set j 1
    set timing_paths_GROUP [list]
    foreach_in_collection path $clk_cpu_paths {
        set startpoint [get_object_name [get_cells -of_object [get_attribute $path startpoint]]]
        set endpoint [get_object_name [get_cells -of_object [get_attribute $path endpoint]]]
        set slack [get_attribute $path slack]
        set endpoint_clock_pin [get_object_name [get_attribute $path endpoint_clock_pin]]
        set points_collection [get_cells -of_object [filter_collection [get_attribute [get_attribute $path points] object] "obiect_class == pin && pin_direction == out"]]
        set points [lreplace [get_object_name $points_collection] 0 0]
        lappend timing_paths_GROUP $startpoint
        lappend timing_paths_GROUP $endpoint
        lappend timing_paths_GROUP $slack
        lappend timing_paths_GROUP $endpoint_clock_pin
        lappend timing_paths_GROUP $points
        puts "$j"
        puts "startpoint:$startpoint"
        puts "endpoint:$endpoint"
        puts "slack:$slack"
        puts "endpoint_clock_pin:$endpoint_clock_pin"
        incr j 1
    }
    puts "Have violation path:[expr $j - 1]"
    puts "Have violation path:[sizeof_collection $clk_cpu_paths]"
    puts "------------------------------------------------------------------------------------------------------------"
}

proc proc_get_timing_paths_NEXT {from} {
    global timing_paths_NEXT
    set next_paths [get_timing_paths -from $from]
    puts "<CMD> get_timing_path -from $from"
    puts "Have violation path:[sizeof_collection $next_paths]"
    set j 1
    set timing_paths_NEXT [list]
    foreach_in_collection path $next_paths {
        set startpoint [get_object_name [get_cells -of_object [get_attribute $path startpoint]]]
        set endpoint [get_object_name [get_cells -of_object [get_attribute $path endpoint]]]
        set slack [get_attribute $path slack]
        set endpoint_clock_pin [get_object_name [get_attribute $path endpoint_clock_pin]]
        set points_collection [get_cells -of_object [filter_collection [get_attribute [get_attribute $path points] object] "obiect_class == pin && pin_direction == out"]]
        set points [lreplace [get_object_name $points_collection] 0 0]
        lappend timing_paths_NEXT $startpoint
        lappend timing_paths_NEXT $endpoint
        lappend timing_paths_NEXT $slack
        lappend timing_paths_NEXT $endpoint_clock_pin
        lappend timing_paths_NEXT $points
        puts "$j"
        puts "startpoint:$startpoint"
        puts "endpoint:$endpoint"
        puts "slack:$slack"
        puts "endpoint_clock_pin:$endpoint_clock_pin"
        incr j 1
    }
    puts "Have violation path:[expr $j - 1]"
    puts "Have violation path:[sizeof_collection $clk_cpu_paths]"
    puts "----------------------------------------------------------------------------"
}

proc proc_get_points_RVT {points} {
    global points_RVT
    set points_RVT [list]
    foreach point $points {
        set cell_refname [get_attribute [get_cells $point] ref_name]
        if {[regexp {R40|R50} $cell_refname]} {
            lappend points_RVT $point
            lappend points_RVT $cell_refname
        }
    }
    pust "## The number of RVT gor data path:[llength $points_RVT]"
}

proc proc_fix_next_path {} {
    puts "## Beginning fix setup of the next path."
    set from $::endpoint
    set next_slack [get_attribute [get_timing_path -from $from] slack]
    puts "The slack of next path:$next_slack"
    while { $next_slack < 0 } {
        # 'proc_get_timing_paths_NEXT' get a list --> 'timing_paths_NEXT'
        proc_get_timing_paths_NEXT $from
        foreach {startpoint endpoint slack endpoint_clock_pin points} $::timing_paths_NEXT {
            # 'proc_get_points_RVT' get a list --> 'points_RVT'
            proc_get_points_RVT $points
            if {[llength $::points_RVT] > 0} {
                puts "## The data path have margin of the next path."
                # Size cell RVT --> LVT
                set fixed_slack $slack 
                foreach {insts cell_refname} $::points_RVT {
                    if {$fixed_slack < 0} {
                        proc_size_cell_VT $insts $cell_refname
                        set fixed_slack [get_attribute [get_timing_path -from $startpoint -through $insts -to endpoint] slack]
                        puts "The fixed slack of next path:$fixed_slack"
                    } else {
                        break
                    }
                }
            }
        }
        set next_slack [get_attribute [get_timing_path -from $from] slack]
        puts "The slack of next path:$next_slack"   
        if { $next_slack == $slack } {
            break
        }
    }
    puts "## End of fixed the next path!"
}

proc proc_size_cell_VT {cell_fullname cell_refname} {
    global fixed_slack
    global next_slack
    set cell_refname [string replace $cell_refname end-2 end-2 L]
    puts "<CMD> size_cell $cell_fullname $cell_refname"
    size_cell $cell_fullname $cell_refname
    puts $::out_PTeco "##hier: SizeCell $cell_fullname"
    puts $::out_PTeco "size_cell $cell_fullname $cell_refname"
    puts $::out_PReco "##hier: ChangeInst $cell_fullname"
    puts $::out_PReco "set insts_pt \[dbGet \[dbGet top.insts.name $cell_fullname -p].pt]"
    puts $::out_PReco "ecoChangeCell -inst $cell_fullname -cell $cell_refname"
    puts $::out_PReco "placeInstance $cell_fullname \$insts_pt -placed"
    set fixed_slack [get_attribute [get_timing_path -to $::endpoint] slack]
    puts "The fixed slack: $fixed_slack"
    set next_slack [get_attribute [get_timing_path -from $::endpoint] slack]
    puts "The next path slack: $next_slack"
}

proc proc_insert_buffer_BUF {cell_pin buffer} {
    global fixed_slack
    global next_slack
    puts "<CMD> insert_buffer $cell_pin $buffer -new_net_names net_PH_$::date\_PTECO_SETUP_NET$::i -new_cell_names U_PH_$::date\_PTECO_SETUP_BUF$::i"
    insert_buffer $cell_pin $buffer -new_net_names net_PH_$::date\_PTECO_SETUP_NET$::i \
                                    -new_cell_names U_PH_$::date\_PTECO_SETUP_BUF$::i
    puts $::out_PTeco "##insert $buffer to dirve $cell_pin"
    puts $::out_PTeco "insert_buffer $cell_pin $buffer -new_net_names net_PH_$::date\_PTECO_SETUP_NET$::i -new_cell_names U_PH_$::date\_PTECO_SETUP_BUF$::i"
    puts $::out_PReco "##insert $buffer to dirve $cell_pin"
    puts $::out_PReco "set instsTerm_pt \[dbGet \[dbGet top.instTerms.name $cell_pin -p].pt]"
    puts $::out_PReco "ecoAddRepeater -cell $buffer -term $cell_pin  -_name U_PH_$::date\_PTECO_SETUP_BUF$::i -newNetName net_PH_$::date\_PTECO_SETUP_NET$::i -loc \$instsTerm_pt "
    set fixed_slack [get_attribute [get_timing_path -to $::endpoint] slack]
    puts "The fixed slack: $fixed_slack"
    set next_slack [get_attribute [get_timing_path -from $::endpoint] slack]
    puts "The next path slack: $next_slack"

}