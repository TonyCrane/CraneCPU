CROSS	:= riscv64-unknown-elf-
FLAGS	:= -nostdlib -nostdinc -static -g -Ttext 0x0 -march=rv64i -mabi=lp64
CC		:= $(CROSS)gcc
OBJDUMP	:= $(CROSS)objdump
OBJCOPY	:= $(CROSS)objcopy

all: RV64I.elf RV64I.bin RV64I.dump RV64I.hex

RV64I.elf: RV64I.s
	$(CC) $(FLAGS) RV64I.s -o RV64I.elf

RV64I.bin: RV64I.elf
	$(OBJCOPY) -O binary RV64I.elf RV64I.bin

RV64I.dump: RV64I.elf
	$(OBJDUMP) -d RV64I.elf > RV64I.dump

RV64I.hex: RV64I.bin
	# xxd -p -c 4 RV64I.bin > RV64I.hex
	od -t x4 -An -v RV64I.bin | python -c 'import sys, re; print(re.sub("[ \n]+", "\n", "".join(sys.stdin))[1:])' > RV64I.hex

clean:
	rm -f *.elf *.bin *.dump