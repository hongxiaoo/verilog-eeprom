############################################################
# Tcl script for quartus sta
############################################################


# ========================================
# Step 1: Design Setup
# ========================================
set PRJ_NAME    "eeprom_demo"
set TOP         "eeprom_top"
set FAMILY      "Cyclone IV"
set DEVICE      "EP4CE115F29C7"

set REPO_ROOT [exec git rev-parse --show-toplevel]

package require ::quartus::project
project_open -revision $TOP $PRJ_NAME

export_assignments

# ========================================
# Step 2: Run STA
# ========================================


# Always create the netlist first
package require ::quartus::sta

create_timing_netlist
read_sdc $REPO_ROOT/demo/de2-115/constraint/timing.sdc
update_timing_netlist

set timing_file "timing.rpt"
# Run a setup analysis between nodes "foo" and "bar",
# reporting the worst-case slack if a path is found.
report_clocks -file $timing_file
create_timing_summary -panel_name "Setup Summary" -file $timing_file -append
create_timing_summary -hold -panel_name "Hold Summary" -file $timing_file -append
report_timing -to_clock { clk } -setup -npaths 10 -detail full_path -panel_name {Setup: clk} -file $timing_file -append

project_close