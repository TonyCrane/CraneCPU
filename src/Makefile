GTKWAVE = /Users/crane/gtk/inst/bin/gtkwave

.PHONY: all compile simulate clean

all: compile simulate

compile:
	iverilog -o core.vvp -y . \
		-y components -y memory -y utils \
		-I headers \
		CoreSim.v

simulate:
	vvp -n core.vvp
	$(GTKWAVE) dump.vcd wave.gtkw

clean:
	rm -f core.vvp dump.vcd