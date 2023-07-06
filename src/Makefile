GTKWAVE = /Users/crane/gtk/inst/bin/gtkwave

.PHONY: all compile simulate clean

all: compile simulate

compile:
	iverilog -o core.vvp -y . \
		-y components -y utils \
		-I headers \
		CoreSim.v

simulate:
	vvp -n core.vvp

open:
	$(GTKWAVE) dump.vcd wave.gtkw

mmu: compile-mmu simulate-mmu

compile-mmu:
	iverilog -o core.vvp -y . \
		-y components -y utils \
		-I headers \
		MMUSim.v

simulate-mmu:
	vvp -n core.vvp
	$(GTKWAVE) dump.vcd wave_mmu.gtkw

clean:
	rm -f core.vvp dump.vcd