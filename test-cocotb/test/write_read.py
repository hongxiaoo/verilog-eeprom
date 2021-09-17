import sys
sys.path.insert(0, '../env')
from APB import *
from Host import *
import cocotb

async def write_read(dut, iteration = 10):

    host = Host(dut)
    await host.start()

    for i in range(iteration):
        addr = await host.write()
        await host.read(addr)

@cocotb.test()
async def write_read_test(dut):
    await write_read(dut, 1)