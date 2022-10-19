
# Please do not modify the sdir variable.
# Doing so may cause script to fail.
set sdir "." 

##################################################################
#    Source common and pt_setup.tcl File                         #
##################################################################

source $sdir/rm_setup/common_setup.tcl
source $sdir/rm_setup/pt_setup.tcl

# make REPORTS_DIR
file mkdir $REPORTS_DIR

# make RESULTS_DIR
file mkdir $RESULTS_DIR

# set the working directory and error files (delete the old work directory first)
file delete -force ./work
set multi_scenario_working_directory ./work
set multi_scenario_merged_error_log ./work/error_log.txt

# add search path for design scripts (scenarios will
# inherit the master's search_path)
set search_path "$search_path $sh_launch_dir $sh_launch_dir/$sdir/rm_pt_scripts"

# add slave workstation information
#
# NOTE: change this to your desired machine/add more machines!

# run processes on the local machine
set_host_options -num_processes $dmsa_num_of_hosts -max_cores 4

# run processes on machine lm121
#set_host_options -num_processes $dmsa_num_of_hosts -max_cores 4 lm121

# run SSH processes on machine lm121 (per SolvNet article 023519)
#set_host_options -num_processes $dmsa_num_of_hosts -max_cores 4 \
   -submit_command "/usr/bin/ssh" lm121

# run processes using lsf (LSF compute farm)
#set_host_options -num_processes $dmsa_num_of_hosts -max_cores 4 \
  -submit_command "bsub -n 2" \
  -terminate_command "/lsf/bin/bkill"

# run processes using grd (Sun Grid compute farm)
#set_host_options -num_processes $dmsa_num_of_hosts -max_cores 4 \
  -submit_command "qsub -P bnormal" \
  -terminate_command "/grd/bin/qdel"




#####################################################################
#                   Scenario Affinity                               #
#   Optionally one can assign scenarios an "affinity" for           # 
#   execution on a specified hosts, allowing more efficient         #
#   allocation of limited computing resources. For example,         #
#   For smaller jobs you can specify lower number of cores and      #
#   smaller memory size:                                            #
#                                                                   #
#   set_host_options -name SmallHosts -max_cores 8 num_processes 2 \#
#   submit_command {bsub -n 8 -R "rusage[mem=40000] span[ptile=1]"} #
#                                                                   #
#   For larger jobs you can specify higher number of cores and      #
#   bigger memory size:                                             #
#                                                                   #
#   set_host_options -name BigHosts -max_cores 16 num_processes 2 \ #
#   submit_command {bsub -n 16 -R "rusage[mem=80000] span[ptile=1]"}#
#                                                                   #
#   You can assign smaller jobs to smaller hosts                    #
#   and larger jobs to larger hosts:                                #
#                                                                   #
#   create_scenario -name S1 -affinity SmallHosts ...               #
#   create_scenario -name S2 -affinity SmallHosts ...               #
#   create_scenario -name S3 -affinity BigHosts ...                 #
#   create_scenario -name S4 -affinity BigHosts ...                 #
#####################################################################
# create scenario at every corner, for every mode
#
# note that link command must be executed after library definitions
# in the common_data scripts before any constraints are applied!
#
# the search_path is used below to resolve the script location

foreach corner $dmsa_corners {
 foreach mode $dmsa_modes {
  create_scenario \
   -name ${mode}_${corner} \
   -specific_variables {mode corner } \
   -specific_data "$sdir/rm_setup/common_setup.tcl $sdir/rm_setup/pt_setup.tcl $sdir/rm_pt_scripts/dmsa_mc.tcl"
 }
}


# start processes on all remote machines
#
# if this hangs, check to make sure that you can run this version
# of PrimeTime on the specified machines/farm
start_hosts

# set session focus to all scenarios
current_session -all

# Produce report for all scenarios
source $sdir/rm_pt_scripts/dmsa_analysis.tcl





