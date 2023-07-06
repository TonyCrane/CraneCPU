ASM_SRC		= $(filter-out uapp.S, $(sort $(wildcard *.S)))
C_SRC       = $(sort $(wildcard *.c))
OBJ		    = $(patsubst %.S,%.o,$(ASM_SRC)) $(patsubst %.c,%.o,$(C_SRC))

CFLAG = -march=$(ISA) -mabi=$(ABI) -mcmodel=medany -fno-builtin -ffunction-sections -fdata-sections -nostartfiles -nostdlib -nostdinc -static -lgcc -Wl,--nmagic $(shell test ${DEBUG} -eq 1 && echo -DDEBUG)

all: uapp.o

uapp.o: uapp.S uapp.bin
	${GCC} ${CFLAG} -c uapp.S

%.o:%.c
	${GCC} ${CFLAG} -c $<

%.o:%.S
	${GCC} ${CFLAG}  -c $<

uapp.bin: $(OBJ)
	${GCC} ${CFLAG} -fpie -T link.lds -o uapp.elf ${OBJ} /Users/crane/riscv64-toolchain/lib/gcc/riscv64-unknown-elf/8.3.0/rv64ifd/lp64d/libgcc.a
	${OBJCOPY} uapp.elf -O binary uapp.bin
	${OBJDUMP} -d uapp.elf > uapp.dump

clean:
	$(shell rm *.o uapp.o uapp.elf uapp.bin 2>/dev/null)
