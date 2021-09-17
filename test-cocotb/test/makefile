# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

ROOT = $(shell git rev-parse --show-toplevel)
RTL = $(ROOT)/rtl
TB = $(ROOT)/tb
IP  = $(ROOT)/ip

VERILOG_SOURCES += $(RTL)/apb_eeprom.v
VERILOG_SOURCES += $(IP)/verilog-i2c/rtl/i2c_master.v
VERILOG_SOURCES += $(IP)/verilog-misc-ip/arbitration/rtl/majority3.v
VERILOG_SOURCES += $(IP)/verilog-misc-ip/misc/rtl/dsync.v
VERILOG_SOURCES += $(IP)/verilog-misc-ip/storage/rtl/fifo_fwft.v
VERILOG_SOURCES += $(IP)/verilog-misc-ip/storage/rtl/fifo.v

VERILOG_SOURCES += $(TB)/24LC32A.v
VERILOG_SOURCES += $(TB)/tb.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = write_read

dump ?= 0
ifeq ($(dump),1)
	COMPILE_ARGS += -DDUMP
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
