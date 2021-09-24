

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer

class Host:
    """ A host class """

    def __init__(self, dut):
        self.dut = dut
        self._max_addr = (1 << 10) - 1
        self._max_data = (1 << 7) - 1

    async def init(self):
        self.dut.addr = 0
        self.read_n = 1
        self.write_n = 1

    async def start(self):
        clock = Clock(self.dut.clk, 10, units="ns")
        cocotb.fork(clock.start())
        await self._reset()

    async def write(self):
        """ Send a write request to eeprom """
        addr = random.randint(0, self._max_addr)
        data = random.randint(0, self._max_data)
        self.dut._log.info(f"Write new data into EEPROM. ADDR: {hex(addr)}, DATA: {hex(data)}")
        await FallingEdge(self.dut.clk)
        self.dut.write_n = 0
        self.dut.addr = addr
        self.dut.data = data
        await FallingEdge(self.dut.clk)
        self.dut.write_n = 1
        await RisingEdge(self.dut.complete)
        self.dut._log.info(f"Write Completed")
        await RisingEdge(self.dut.clk)
        return (addr, data)

    async def read(self, addr):
        """ Send a read request to eeprom """
        self.dut._log.info(f"Reading from EEPROM. ADDR: {hex(addr)}")
        await FallingEdge(self.dut.clk)
        self.dut.read_n = 0
        self.dut.addr = addr
        await FallingEdge(self.dut.clk)
        self.dut.read_n = 1
        await RisingEdge(self.dut.complete)
        data = self.dut.display.value
        self.dut._log.info(f"Read Completed. DATA: {hex(data)}")
        return data

    async def _reset(self, time=20):
        """ Reset the design """
        self.dut.rst_n = 0
        await Timer(time, units="ns")
        await FallingEdge(self.dut.clk)
        self.dut.rst_n = 1

#@cocotb.test()
async def write_test(dut):
    host = Host(dut)
    await host.start()
    await host.write()

@cocotb.test()
async def read_test(dut):
    DELTA = 200
    host = Host(dut)
    await host.start()
    (addr, data1) = await host.write()
    await Timer(DELTA, "us")
    data = await host.read(addr)
    assert (data1 & 0xFF) == (data & 0xFF)