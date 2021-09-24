############################################################
# makefile for running Quartus
############################################################

PRJ_SOF = output/eeprom_top.sof

all: clean build sta pgm

build: clean
	mkdir -p output
	cd output && quartus_sh --64bit -t ../script/build.tcl | tee build.log

sta:
	cd output && quartus_sta --64bit -t ./script/sta.tcl | tee sta.log

pgm:
	quartus_pgm -m jtag -o "p;$(PRJ_SOF)"

clean:
	rm -rf output