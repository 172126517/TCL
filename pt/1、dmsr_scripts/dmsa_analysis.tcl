puts "RM-Info: Running script [info script]\n"
#################################################################################
# PrimeTime Reference Methodology Script
# Script: dmsa_analysis.tcl
# Version: Q-2019.12-SP4 (July 20, 2020)
# Copyright (C) 2009-2020 Synopsys All rights reserved.
#################################################################################


#################################################################################
# 
# This file will produce the reports for the DMSA mode based on the options
# used within the GUI.
#
# The output files will reside within the work/scenario subdirectories.
#
#################################################################################



##################################################################
#    Update_timing and check_timing Section                      #
##################################################################
remote_execute {
set timing_save_pin_arrival_and_slack true
update_timing -full
# Ensure design is properly constrained
check_timing -verbose > $REPORTS_DIR/${DESIGN_NAME}_check_timing.report
}


##################################################################
#   Writing an Reduced Resource ECO design                       #
##################################################################
# PrimeTime has the capability to write out an ECO design which 
# is a smaller version of the orginal design ECO can be performed
# with fewer compute resources.
#
# Writes an ECO design  that  preserves  the  specified  violation
# types  compared to those in the original design. You can specify
#  one or more of the following violation types:
#              o setup - Preserves setup timing results.
#              o hold - Preserves hold timing results.
#              o max_transistion - Preserves max_transition results.
#              o max_capacitance - Preserves max_capacitance results.
#              o max_fanout - Preserves max_fanout results.
#              o noise - Preserves noise results.
#              o timing - Preserves setup and hold timing results.
#              o drc  -  Preserves  max_transition,  max_capacitance,  
#                and max fanout results.
# There is also capability to write out specific endpoints with
# the -endpoints options.
#
# In DMSA analyis the RRECO design is written out relative to all
# scenarios enabled for analysis.
# 
# To create a RRECO design the user should perform the following 
# command and include violations types which the user is interested
# in fixing, for example for setup and hold.
# 
# write_eco_design  -type {setup hold} my_RRECO_design
#
# Once the RRECO design is created, the user then would invoke 
# PrimeTIme ECO in a seperate session and access the appropriate
# resourses and then read in the RRECO to perform the ECO
# 
# set_host_options ....
# start_hosts
# read_eco_design my_RRECO_design
# fix_eco...
#
# For more details please see man pages for write_eco_design
# and read_eco design.


##################################################################
#    Report_timing Section                                       #
##################################################################
#==============================================================================
#Cover through reporting from 2018.06* version
#get_timing_paths and report_timing commands are enhanced with a new option, -cover_through through_list, which collects the single worst violating path through    each of the objects specified in a list. 
#For example,
#pt_shell> remote_execute {get_timing_paths -cover_through {n1 n2 n3} }
#This command creates a collection containing the worst path through n1, the worst path
#through n2, and the worst path through n3, resulting in a collection of up to three paths.
#=======================================================================
report_global_timing > $REPORTS_DIR/${DESIGN_NAME}_dmsa_report_global_timing.report
report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net -sign 4 > $REPORTS_DIR/${DESIGN_NAME}_dmsa_report_timing.report

report_analysis_coverage > $REPORTS_DIR/${DESIGN_NAME}_dmsa_report_analysis_coverage.report 

remote_execute {
report_clock -skew -attribute > $REPORTS_DIR/${DESIGN_NAME}_report_clock.report 
}
remote_execute {
report_aocvm > $REPORTS_DIR/${DESIGN_NAME}_report_aocvm.report
}





##################################################################
#    Fix ECO Power Cell Downsize Section                         #
##################################################################
# Note if power attributes flow is desired fix_eco_power -power_attribute
# then attribute file needs to be provided for lib cells.
# See 2014.12 update training for examples
#
# PBA mode can be enabled by changing the -pba_mode option
# See fix_eco_power man page for more details on PBA based fixing
# Additional PBA controls are also available with -pba_path_selection_options
# Reporting options should be changed to reflect PBA based ECO
#
fix_eco_power -pba_mode none -verbose

##################################################################
#    Fix ECO Power Buffer Removal                                #
##################################################################
# Power recovery also has buffer removal capability.  
# Buffer removal usage is as follows:
# fix_eco_power -method remove_buffer
# When can specify -method remove_buffer, it cannot be used in conjunction 
# with size_cell, so buffer removal needs to be done in a separate 
# fix_eco_power command.  Please see the man page for additional details.

 




#This is for power attribute flow for Scalar and DMSA
#fix_eco_timing -type hold -power_attribute <attr name>
#This is for leakage based flow for DMSA
#fix_eco_timing -type hold -power_mode leakage -leakage_scenario <scen_name>

##################################################################
#    Fix ECO Leakage Section                                     #
##################################################################
remote_execute {
# Note: the report_power command requires a PrimeTime PX license
set power_enable_analysis true
report_cell_usage -pattern_priority $leakage_pattern_priority_list > $REPORTS_DIR/${DESIGN_NAME}_pre_leakage_eco_report_cell_usage.report
report_power -threshold -pattern_priority $leakage_pattern_priority_list -group "combinational register sequential" > $REPORTS_DIR/${DESIGN_NAME}_pre_leakage_eco_report_power.report
}

# fix leakage
# refer to man page for more details
#
# use the following example for lib cells that don't have common naming notation
# INV1XH is high vt
# INV1XN is normal vt
# INV1X is low vt
# define_user_attribute vt_swap_priority -type string -class lib_cell
# set_user_attr -class lib_cell lib/INV1XH vt_swap_priority INV1X_best
# set_user_attr -class lib_cell lib/INV1XN vt_swap_priority INV1X_ok
# set_user_attr -class lib_cell lib/INV1X  vt_swap_priority INV1X_worst
# ...
# fix_eco_leakage -pattern "best ok worst" -attribute vt_swap_priority
# PBA mode can be enabled by changing the -pba_mode option
# See fix_eco_power man page for more details on PBA based fixing
# Additional PBA controls are also available with -pba_path_selection_options
# Reporting options should be changed to reflect PBA based ECO
#
fix_eco_power -pba_mode none -pattern_priority $leakage_pattern_priority_list -verbose

remote_execute {
report_cell_usage -pattern_priority $leakage_pattern_priority_list > $REPORTS_DIR/${DESIGN_NAME}_post_leakage_eco_report_cell_usage.report
report_power -threshold -pattern_priority $leakage_pattern_priority_list -group "combinational register sequential" > $REPORTS_DIR/${DESIGN_NAME}_post_leakage_eco_report_power.report
}

##################################################################
#    Fix ECO Output Section                                      #
##################################################################
# write netlist changes
remote_execute {
write_changes -format icctcl -output $RESULTS_DIR/eco_changes.tcl
}










puts "RM-Info: Completed script [info script]\n"
