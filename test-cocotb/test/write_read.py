import sys
sys.path.insert(0, '../env')
from APB import *
from Host import *
import cocotb

async def write(dut, iteration = 10):

    host = Host(dut)
    await host.start()
    for i in range(iteration):
        addr = await host.write()


async def write_read(dut, iteration = 10):
    tWC = 5000000 * 3
    host = Host(dut)
    await host.start()
    for i in range(iteration):
        addr = await host.write()
        await Timer(tWC, "ns")
        await host.read(addr)

#@cocotb.test()
async def write_test(dut):
    await write(dut, 5)

@cocotb.test()
async def write_read_test(dut):
    await write_read(dut, 1)