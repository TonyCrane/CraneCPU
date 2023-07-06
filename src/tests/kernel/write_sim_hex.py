import os
from pwn import *

elf = ELF("build/kernel.elf", checksec=False)

def write_rom():
    with open("build/kernel.hex", "r") as f:
        lines = f.readlines()
    text_lines = elf.get_section_by_name(".text").data_size // 4
    rom_lines = lines[:text_lines]
    with open("rom.hex", "w") as f:
        f.writelines(rom_lines)

def write_ram():
    rodata = elf.get_section_by_name(".rodata").data()
    rodata_size = elf.get_section_by_name(".rodata").data_size
    assert(rodata_size == len(rodata))
    bss_size = elf.get_section_by_name(".bss").data_size
    with open("ram.hex", "w") as f:
        for byte in rodata:
            f.write(hex(byte)[2:].zfill(2) + "\n")
        for i in range(0x1000 - rodata_size):
            f.write("00\n")
        for i in range(bss_size):
            f.write("00\n")
    

if __name__ == "__main__":
    write_rom()
    write_ram()