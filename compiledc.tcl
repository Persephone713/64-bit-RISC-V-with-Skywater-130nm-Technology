#######################################################################
# User Defined Parameters
# You need to changes this parameters to fit you own design
#######################################################################
# Give the list of your verilog files
# If you have single file in your design, then
#set my_verilog_files [list PC.v]

# If you have multiple file in your design, then
set my_verilog_files [list WB.v TOP_RISCV.v ROM.v REGS.v RAM.v PC.v Multiplier.v MEM_WB.v MEM.v IF_ID.v IF.v ID_EX.v ID.v ICache.v EX_MEM.v EX.v Divider.v defines.v DCache.v CTRL.v CSR_REGS.v CLINT.v CHECK.v AXI4_Lite.v DFF_SET.v RISCV_SOC.v]

# Set the top module of your designset my_toplevel Counter
set my_toplevel TOP_RISCV

# set the clock period in ps
set CLK_PERIOD 50000

# setting the port of clock, this is the input Clock from your design
set CLOCK_INPUT clk


#######################################################################
# The following part needs no modifications
#######################################################################
####################################
# Use multiple cores               # 
####################################
set_host_options -max_cores 16

####################################
# Setup library                    # 
####################################

# allows files to be read in without specifying the directory path
set search_path ". /apps/eda/synopsys/syn/S-2021.06-SP1/libraries/syn \
/apps/eda/synopsys/syn/S-2021.06-SPI/minpower/syn \
/apps/eda/synopsys/syn/S-2021.06-SPI/dw/syn_ver \
/apps/eda/synopsys/syn/S-2021.06-SPI/dw/sim_ver \
/users/ee500x/e1323337/riscv2/"

# Technology cell symbol library 
# set symbol_lib "lsi_10k.sdb"

# Technology cell files
#set target_library "lsi_10k.db"
set target_library "scs130ms_tt_1.80v_25C.db"

# Used during design linking
#set link_library "* dw_foundation.sldb lsi_10k.db"
set link_library "* dw_foundation.sldb scs130ms_tt_1.80v_25C.db"

# Library of designware components
set synthetic_library "dw_foundation.sldb"

# Directory where DC placed intermediate files
define_design_lib WORK -path ./WORK

# removing high drive inverter
# set_dont_use inv_4

#######################################
# Read in Verilog Source Files        # 
#######################################

# This command does the same work of analyze+elaborate
# read_verilog $my_verilog_files   

# Translates HDL to intermediate format
analyze -f verilog $my_verilog_files

# Buids generic technology database
elaborate $my_toplevel

# Designate the design to synthesize
current_design $my_toplevel 

#######################################
# Verilog (?) Compiler settings       #
#######################################

# to make DC not use the assign statement in its output netlist
set verilogout_no_tri true

# assume this means DC will ignore the case of the letters in net and module names
#set verilogout_ignore_case true

# unconnected nets will be marked by adding a prefix to its name
set verilogout_unconnected_prefix "UNCONNECTED"

# show unconnected pins when creating module ports
set verilogout_show_unconnected_pins true

# make sure that vectored ports don't get split up into single bits
set verilogout_single_bit false

# generate a netlist without creating an EDIF schematic
set edifout_netlist_only true

#######################################
# Define constraints                  #
#######################################
# setting the approximate skew
set CLK_SKEW [expr 0.025 * $CLK_PERIOD]

# constraint design area units depends on the technology library
# set MAX_AREA 20000.0
# set_max_area $MAX_AREA

# power constraints
# set MAX_LEAKAGE_POWER 0.0
# set_max_leakage_power $MAX_LEAKAGE_POWER
# set MAX_DYNAMIC_POWER 0.0
# set_max_dynamic_power $MAX_DYNAMIC_POWER

# make sure ports aren't connected together
set_fix_multiple_port_nets -all

# setting the port of clock
create_clock -period  $CLK_PERIOD $CLOCK_INPUT

## Design Rule Constraints

set DRIVINGCELL inv_1
set DRIVE_PIN {Y}
# set input driving cell strength / Max fanout for all design
# set_driving_cell -lib_cell $DRIVINGCELL -pin $DRIVE_PIN [all_inputs]
# set_driving_cell -lib_cell $DRIVINGCELL [all_inputs]

# largest fanout allowed 
#set MAX_FANOUT 8
#set_max_fanout $MAX_FANOUT

# models load on output ports
#set MAX_OUTPUT_LOAD [load_of ssc_core/buf1a2/A]
#set_load $MAX_OUTPUT_load [all_outputs]
set MAX_OUTPUT_load 57.462
set_load $MAX_OUTPUT_load [all_outputs]

# incase of variable load at each output port
# set_load <loadvalue> [get_ports {<portnames>}] 


# set maximum and minimum capacitance 
# set_max_capacitance
# set_min_capacitance

# setting operating conditions if allowed by technology library 
# set_operating_conditions

# wireload models
# set_wireload_model
# set_wireload_mode 

set MAX_INPUT_DELAY 0.9
set MIN_INPUT_DELAY 0
set OUTPUT_MAX_DELAY 0.4
set OUTPUT_MIN_DELAY -0.4

# models the delay from signal source to design input port
# set_input_delay

# models delay from design to output port
# set_output_delay

# used when you are translating some netlist from one technology to another
link

# used to generate separate instances within the netlist
uniquify

#######################################
# Design Compiler settings            #
#######################################

# completely flatten the hierarchy to allow optimization to cross hierarchy boundaries
ungroup -flatten -all

# check internal DC representation for design consistency
check_design

# verifies timing setup is complete
check_timing

# enable DC ultra optimizations 
compile_ultra

# verifies timing setup is complete
check_timing

# report design size and object counts
report_area

report_timing
report_power
report_cell

# reports design database constraints attributes
report_timing_requirements

#######################################
# Output files                        #
#######################################

# save design
set filename [format "%s%s"  $my_toplevel ".ddc"]
write -format ddc -hierarchy -output $my_toplevel

# save delay and parasitic data
set filename [format "%s%s"  $my_toplevel ".sdf"]
write_sdf -version 1.0 $filename

# save synthesized verilog netlist
set filename [format "%s%s"  $my_toplevel ".syn.v"]
write -format verilog -hierarchy -output $filename

# this file is necessary for P&R with Encounter
set filename [format "%s%s"  $my_toplevel ".sdc"]
write_sdc $filename

# write milkyway database
if {[shell_is_in_topographical_mode]} {
    write_milkyway -output $my_toplevel -overwrite
}

redirect [format "%s%s" $my_toplevel  _design.repC] { report_design }
redirect [format "%s%s" $my_toplevel  _area.repC] { report_area }
redirect -append [format "%s%s" $my_toplevel  _area.repC] { report_reference }
redirect [format "%s%s" $my_toplevel  _latches.repC] { report_register -level_sensitive }
redirect [format "%s%s" $my_toplevel  _flops.repC] { report_register -edge }
redirect [format "%s%s" $my_toplevel  _violators.repC] { report_constraint -all_violators }
redirect [format "%s%s" $my_toplevel  _power.repC] { report_power }
redirect [format "%s%s" $my_toplevel  _max_timing.repC] { report_timing -delay max -nworst 3 -max_paths 20 -greater_path 0 -path full -nosplit}
redirect [format "%s%s" $my_toplevel  _min_timing.repC] { report_timing -delay min -nworst 3 -max_paths 20 -greater_path 0 -path full -nosplit}
redirect [format "%s%s" $my_toplevel  _out_min_timing.repC] { report_timing -to [all_outputs] -delay min -nworst 3 -max_paths 1000000 -greater_path 0 -path full -nosplit}

quit

