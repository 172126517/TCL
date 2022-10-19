puts "RM-Info: Running script [info script]\n"

#################################################################################
# PrimeTime Reference Methodology Script
# Script: dmsa_mc.tcl
# Version: Q-2019.12-SP4 (July 20, 2020)
# Copyright (C) 2009-2020 Synopsys All rights reserved.
#################################################################################

set sh_source_uses_search_path true
set report_default_significant_digits 3

# make REPORTS_DIR
file mkdir $REPORTS_DIR

# make RESULTS_DIR
file mkdir $RESULTS_DIR 

# Under normal circumstances, when executing a script with source, Tcl
# errors (syntax and semantic) cause the execution of the script to terminate.
# Uncomment the following line to set sh_continue_on_error to true to allow
# processing to continue when errors occur.
#set sh_continue_on_error true

set timing_remove_clock_reconvergence_pessimism true 
# Enabling aocvm analysis
set timing_aocvm_enable_analysis true

# Enabling AOCVM distance based analysis 
set timing_ocvm_enable_distance_analysis true 
# Load parasitics location for physical ECO on route buffering 
set read_parasitics_load_locations true



echo "Checking $dmsa_corner_library_files($corner)"

set select_dmsa_corner_libs "";

foreach dml $dmsa_corner_library_files($corner)  {
    lappend select_dmsa_corner_libs $dml
}

echo "select_dmsa_corner_libs $select_dmsa_corner_libs"

set link_path "* $select_dmsa_corner_libs"
read_verilog $NETLIST_FILES
current_design $DESIGN_NAME
link


##################################################################
#    Back Annotation Section                                     #
##################################################################

# Galaxy Parasitic Data (GPD) is a new parasitics format introduced from the 2015.12 release of PrimeTime and StarRC. StarRC creates a single GPD directory for a simultaneous multicorner (SMC) flow. This GPD is a compact database containing parasitics for all corners in the SMC run. Hence when we read this multi-corner GPD into PrimeTime, user need to specify the parasitic corner to be used in the current session using the parasitic_corner_name setting.
# Example :
# pt_shell> set parasitic_corner_name cworst_125
# pt_shell> read_parasitics -format GPD gpd_dir
# Details of the corner names extracted within the GPD can be seen in the ASCII "README" file inside the GPD directory. 
# User also need to specify -format GPD while reading in GPD in PrimeTime.
if { [info exists PARASITIC_PATHS] && [info exists PARASITIC_FILES] } {
foreach para_path $PARASITIC_PATHS($corner) para_file $PARASITIC_FILES($corner) {
   if {[string compare $para_path $DESIGN_NAME] == 0} {
      read_parasitics -format GPD $para_file 
   } else {
      read_parasitics -format GPD -path $para_path $para_file 
   }
}
}



######################################
# reading design constraints
######################################

if {[info exists dmsa_mode_constraint_files($mode)]} {
        foreach dmcf $dmsa_mode_constraint_files($mode) {
                if {[file extension $dmcf] eq ".sdc"} {
                        read_sdc -echo $dmcf
                } else {
                        source -echo $dmcf
                }
        }
}




foreach aocvm_file $dmsa_corner_aocvm_file($corner) {
	echo "reading $aocvm_file"
	read_ocvm $aocvm_file
}










puts "RM-Info: Completed script [info script]\n"
