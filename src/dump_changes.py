import gdb
import re

class DumpChanges(gdb.Command):
    def __init__(self):
        super(DumpChanges, self).__init__("dump-changes", gdb.COMMAND_USER)
        self.registers = [
            "ra", "sp", "gp", "tp",
            "t0", "t1", "t2",
            "fp", "s1",
            "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7",
            "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11",
            "t3", "t4", "t5", "t6"
        ]
        self.reg_to_idx = {}
        for i, reg in enumerate(self.registers):
            self.reg_to_idx[reg] = i + 1
        self.regs = {}
        self.watched = False
        self.output = open("gdb_changes.txt", "w")
        self.cnt = 0
    
    def invoke(self, arg, from_tty):
        length = 0
        if arg:
            length = int(arg)
        
        if self.regs == {}:
            res = gdb.execute("info registers", to_string=True)
            self.regs = self.parse_registers(res)
        
        while True:
            gdb.execute("si")

            res = gdb.execute("info registers", to_string=True)
            regs = self.parse_registers(res)

            for reg in self.registers:
                if regs[reg] != self.regs[reg]:
                    pc = self.regs["pc"][2:].zfill(16)
                    idx = str(self.reg_to_idx[reg]).rjust(2)
                    old = self.regs[reg][2:].zfill(16)
                    new = regs[reg][2:].zfill(16)
                    self.output.write(f"[{pc}] x{idx} 0x{new}\n")
                    self.cnt += 1
            self.regs = regs

            if self.cnt == length:
                self.output.close()
                break
    
    def parse_registers(self, res):
        regs = {}
        for line in res.split("\n"):
            if line == "":
                continue
            match = re.findall(r"(.*?) +(.*?)\t", line)
            if match == []:
                continue
            regs[match[0][0]] = match[0][1]
        return regs

DumpChanges()