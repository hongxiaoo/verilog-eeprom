############################################################
# Tcl script for quartus
############################################################

# ========================================
# Step 1: Create project Design Setup
# ========================================

set PRJ_NAME    "eeprom_demo"
set TOP         "eeprom_top"
set FAMILY      "Cyclone IV"
set DEVICE      "EP4CE115F29C7"


set REPO_ROOT [exec git rev-parse --show-toplevel]

# Load Quartus II Tcl Project package
package require ::quartus::project

project_new $PRJ_NAME -revision $TOP -overwrite -part $DEVICE -family $FAMILY

# ========================================
# Step 2: Porject Assignment
# ========================================

set_global_assignment -name VERILOG_MACRO "SYNTHESIS=1"

# Commit assignments
export_assignments

# ========================================
# Step 3: Read in RTL and SDC
# ========================================

set_global_assignment -name VERILOG_FILE $REPO_ROOT/rtl/apb_eeprom.v
set_global_assignment -name VERILOG_FILE $REPO_ROOT/ip/verilog-i2c/rtl/i2c_master.v
set_global_assignment -name VERILOG_FILE $REPO_ROOT/ip/verilog-misc-ip/arbitration/rtl/majority3.v
set_global_assignment -name VERILOG_FILE $REPO_ROOT/ip/verilog-misc-ip/misc/rtl/dsync.v
set_global_assignment -name VERILOG_FILE $REPO_ROOT/ip/verilog-misc-ip/storage/rtl/fifo_fwft.v
set_global_assignment -name VERILOG_FILE $REPO_ROOT/ip/verilog-misc-ip/storage/rtl/fifo.v
set_global_assignment -name VERILOG_FILE $REPO_ROOT/demo/de2-115/rtl/eeprom_top.v

set_global_assignment -name SDC_FILE     $REPO_ROOT/demo/de2-115/constraint/timing.sdc

export_assignments

# ========================================
# Step 3: read IO constraint
# ========================================

source $REPO_ROOT/demo/de2-115/constraint/io.tcl

# ========================================
# Step 4: Synthesis
# ========================================
package require ::quartus::flow
execute_module -tool map

# ========================================
# Step 4: place and route
# ========================================
execute_module -tool fit

# ========================================
# Step 5: Reporting Utilization
# ========================================
package require ::quartus::report
load_report

# Print All Report Panel Names
# set panel_names [get_report_panel_names]
# foreach panel_name $panel_names {
# post_message "$panel_name"
#
# }

# Saving Report Data in csv Format
# This is the name of the report panel to save as a CSV file
set panel_name "Analysis & Synthesis||Analysis & Synthesis Resource Utilization by Entity"
set csv_file "synthesis_resource_utilization_by_entity.csv"
set fh [open $csv_file w]
set num_rows [get_number_of_rows -name $panel_name]
# Go through all the rows in the report file, including the
# row with headings, and write out the comma-separated data
for { set i 0 } { $i < $num_rows } { incr i } {
	set row_data [get_report_panel_row -name $panel_name \
		-row $i]
	puts $fh [join $row_data ","]
}
close $fh
unload_report

# ========================================
# Step 6: Generate bit stream
# ========================================

execute_module -tool asm

project_close
