############################
#### Pt fix eco scripts
#### version 1.0
#### 2022.11.01
############################

source ~/scripts/pteco/proc.tcl
################
###   Start  ###
################
set date [clock format [clock seconds] -format "%b%d%H%M"]
puts $date
set current_dir [pwd]
puts "save_direction: $current_dir"
if {[info exists $current_dir/pteco] == 0} {
    file mkdir $current_dir/pteco
}
set out_PTeco [open $current_dir/pteco/pt_eco.tcl w]
set out_PReco [open $current_dir/pteco/pr_eco.tcl w]
puts $out_PReco "report_resource"
puts $out_PReco "setEcoMode -updateTiming false -prefixName ECO_[file mtime $current_dir/pteco/pr_eco.tcl]"
puts $out_PReco "setEcoMode -refinePlace false -batchMode true -honorDontUse false -honorDontTouch false -honorFixedStatus false"
#######################
###  setup target   ###
#######################
# target_01: get_timing_paths
set path_group "clk_cpu"
set max_paths "1000"
set nworst "1000"
set slack_lesser_than "0.00"

# target_02: fix to target slack
set target_slack "0.00"

# target_03: insert_buffer
set buffer "BUF_X2B_A12TR40"

#######################
###   run scripts   ###
#######################
set i 1
set j 1
set endpoint_list [list]
# 'proc_get_timing_paths_GROUP' get a list --> 'timing_paths_GROUP'
proc_get_timing_paths_GROUP $path_group $max_paths $nworst $slack_lesser_than
foreach {startpoint endpoint slack endpoint_clock_pin points} $timing_paths_GROUP {
    puts "$j"
    puts "startpoint: $starpoint"
    puts "endpoint: $endpoint"
    puts "slack: $slack"
    if {$slack < $target_slack} {
        # get RVT cell_list of the data path.
        # 'proc_get_points_RVT' get a list --> 'points_RVT'
        proc_get_points_RVT $points
        if {[llength $points_RVT] > 0} {
            #******************************#
            # 1 The data path have margin! #
            #******************************#
            puts "## Tune data path"
            # 1.1 Get lower delay of data path.
            # Size cell RVT --> LVT
            set fixed_slack $slack
            foreach {insts cell_refname} $points_PVT {
                if {$fixed_slack < $target_slack} {
                    proc_size_cell_VT $insts $cell_refname
                    set fixed_slack [get_attribute [get_timing_path -from $starpoint -through $insts -to endpoint] slack]
                    puts "The slack of fixed data path: $fixed_slack"
                }
            }
        } else {
            #**********************************#
            # 2 The data path have not margin! #
            #**********************************#
            if {[lsearch $endpoint_list $endpoint] > 1} {
                incr j 1
                continue
            } else {
                lappend endpoint_list $endpoint
            }
            puts "## Tune capture path."
            set next_slack [get_attribute [get_timing_path -from $endpoint] slack]
            puts "The next path slack: $next_salck"
            # 2.1 Add delay of the capture path.
            if {$next_slack < 0.07} {
                #*************************************************************#
                # 2.1.1 The next path have a small margin! (next_salck < 0.07)
                # The first step: size_cell
                # The second step: insert_buffer
                #*************************************************************#
                # Size cell RVT --> LVT
                set end_refname [get_attribute [get_cells $endpoint] ref_name]
                puts "Endpoint refname: $end_refname"
                if {[regexp {R} $end_refname]} {
                    proc_size_cell_VT $endpoint $end_refname
                }
                # Insert buffer --> BUF_X2B_A12TR40
                while {$fixed_slack < $target_slack} {
                    proc_insert_buffer_BUF $endpoint_clock_pin $buffer
                    incr i 1
                }
                # Fix next path
                if {$next_salck < 0} {
                    proc_fix_next_path $next_slack
                }
            } else {
                #*************************************************************#
                # 2.1.2 The next path have more margin! (next_salck > 0.07)
                # The first step: insert_buffer
                # The second step: size_cell
                # The third step: insert_buffer
                #*************************************************************#
                # insert buffer --> BUF_X2B_A12TR40
                proc_insert_buffer_BUF $endpoint_clock_pin $buffer
                incr i 1
                if {$fixed_slack < $target_slack} {
                    # Size cell RVT --> LVT
                    set end_refname [get_attribute [get_cells $endpoint] ref_name]
                    puts "Endpoint refname: $end_refname"
                    if {[regexp {R} $end_refname]} {
                        proc_size_cell_VT $endpoint $end_refname
                    }
                    # Insert buffer --> BUF_X2B_A12TR40
                    while {$fixed_slack < $target_slack} {
                        proc_insert_buffer_BUF $endpoint_clock_pin $buffer
                        incr i 1
                    }
                }
                # Fix next path
                if {$next_salck < 0} {
                    proc_fix_next_path $next_slack
                }
            }
        }
    }
    incr j 1
    puts "------------------------------------------------------------------------------------------------------------"
}
close $out_PReco
close $out_PTeco
puts "group_path: $path_group"
puts "-max_paths: $max_paths"
puts "-nworst: $nworst"
puts "-slack_lesser_than: $slack_lesser_than"
puts "target_slack: $target_slack"
puts "Fixed path: [expr $j - 1]"