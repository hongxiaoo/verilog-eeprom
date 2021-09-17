

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer

from APB import *

class Host:
    """ A host class """

    def __init__(self, dut):
        self.dut = dut
        self._apb = APB()
        self._apb.connect(dut.clk, dut.paddr, dut.pwrite, dut.psel,
                         dut.penable, dut.pwdata, dut.prdata, dut.pready, dut.pslverr)
        self._max_addr = 1024
        self._max_data = (1 << 31) - 1
        self._eeprom_data = {}

    async def start(self):
        clock = Clock(self.dut.clk, 10, units="ns")
        cocotb.fork(clock.start())
        self._apb.init()
        await self._reset()

    async def write(self):
        """ Send a write request to eeprom """
        addr = random.randint(0, self._max_addr)
        data = random.randint(0, self._max_data)
        self.dut._log.info(f"Write new data into EEPROM. ADDR: {hex(addr)}, DATA: {hex(data)}")
        self._eeprom_data[addr] = data
        await self._apb.write(addr, data)
        self.dut._log.info(f"Write Completed")
        return addr

    async def read(self, addr):
        """ Send a read request to eeprom """
        self.dut._log.info(f"Reading from EEPROM. ADDR: {hex(addr)}")
        data = await self._apb.read(addr)
        self.dut._log.info(f"Read Completed. DATA: {hex(data)}")

    async def _reset(self, time=20):
        """ Reset the design """
        self.dut.rst = 1
        await Timer(time, units="ns")
        await FallingEdge(self.dut.clk)
        self.dut.rst = 0
