# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

ROOT = $(shell git rev-parse --show-toplevel)
RTL = $(ROOT)/rtl
IP  = $(ROOT)/ip

VERILOG_SOURCES += $(RTL)/apb_eeprom.v
VERILOG_SOURCES += $(IP)/verilog-i2c/rtl/i2c_master.v
VERILOG_SOURCES += $(IP)/verilog-misc-ip/arbitration/rtl/majority3.v
VERILOG_SOURCES += $(IP)/verilog-misc-ip/misc/rtl/dsync.v
VERILOG_SOURCES += $(IP)/verilog-misc-ip/storage/rtl/fifo_fwft.v
VERILOG_SOURCES += $(IP)/verilog-misc-ip/storage/rtl/fifo.v

VERILOG_SOURCES += $(ROOT)/demo/de2-115/rtl/eeprom_top.v
VERILOG_SOURCES += $(ROOT)/demo/de2-115/tb/24LC32A.v
VERILOG_SOURCES += $(ROOT)/demo/de2-115/tb/eeprom_top_tb.v


# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = eeprom_top_tb

# MODULE is the basename of the Python test file
MODULE = test

dump ?= 0
ifeq ($(dump),1)
	COMPILE_ARGS += -DDUMP
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
