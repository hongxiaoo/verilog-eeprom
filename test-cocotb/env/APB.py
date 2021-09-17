

from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer

class APB:
    """ APB interface """

    def __init__(self):
        self.paddr = None
        self.pwrite = None
        self.psel = None
        self.penable = None
        self.pwdata = None
        self.prdata = None
        self.pready = None
        self.pslverr = None
        self.clk = None

    def connect(self, clk, paddr, pwrite, psel, penable, pwdata, prdata, pready, pslverr):
        self.clk     = clk
        self.paddr   = paddr
        self.pwrite  = pwrite
        self.psel    = psel
        self.penable = penable
        self.pwdata  = pwdata
        self.prdata  = prdata
        self.pready  = pready
        self.pslverr = pslverr

    def init(self):
        """ Initialize input to zero """
        self.paddr <= 0
        self.pwrite <= 0
        self.psel <= 0
        self.penable <= 0
        self.pwdata <= 0

    async def _wait_ready(self):
        while self.pready.value == 0:
            await FallingEdge(self.clk)

    async def write(self, addr, data):
        """ Send a write request """
        await self._request(1, addr, data)

    async def read(self, addr):
        """ Send a read request """
        return await self._request(0, addr, 0)

    async def _request(self, write, addr, wdata):
        """ Send a new request """
        await FallingEdge(self.clk)
        await self._wait_ready()
        self.paddr <= addr
        self.pwrite <= write
        self.psel <= 1
        self.penable <= 1
        self.pwdata <= wdata
        await FallingEdge(self.clk)
        await self._wait_ready()
        self.psel <= 0
        self.penable <= 0
        rdata = int(self.prdata.value)
        return rdata
