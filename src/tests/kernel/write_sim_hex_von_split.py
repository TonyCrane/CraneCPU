import os
from pwn import *

elf = ELF("build/kernel.elf", checksec=False)

def align_to_page(size):
    return (size + 0xfff) & ~0xfff

def write_rom():
    with open("build/kernel.hex", "r") as f:
        lines = f.readlines()
    text_lines = elf.get_section_by_name(".text").data_size // 4
    rom_lines = lines[:text_lines]
    with open("rom.hex", "w") as f:
        f.writelines(rom_lines)

def write_ram():
    text = elf.get_section_by_name(".text").data()
    text_size = elf.get_section_by_name(".text").data_size
    assert(text_size == len(text))
    text = text + b"\x00" * (align_to_page(text_size) - text_size)

    rodata = elf.get_section_by_name(".rodata").data()
    rodata_size = elf.get_section_by_name(".rodata").data_size
    assert(rodata_size == len(rodata))
    rodata = rodata + b"\x00" * (align_to_page(rodata_size) - rodata_size)

    data = elf.get_section_by_name(".data").data()
    data_size = elf.get_section_by_name(".data").data_size
    assert(data_size == len(data))
    data = data + b"\x00" * (align_to_page(data_size) - data_size)

    bss_size = elf.get_section_by_name(".bss").data_size

    total = text + rodata + data + b"\x00" * bss_size

    for i in range(8):
        with open(f"memory_{i}.hex", "w") as f:
            for byte in total[i::8]:
                f.write(hex(byte)[2:].zfill(2) + "\n")
    

if __name__ == "__main__":
    # write_rom()
    write_ram()