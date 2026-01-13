# =========================
# Configurações
# =========================
IVERILOG = iverilog
VVP      = vvp

TOP      = top
OUT      = sim.out

SRCS = 	riscv_pkg.sv \
	alu.sv \
	branch_control.sv \
	control.sv \
	data_memory.sv \
	decode.sv \
	fetch.sv \
	instruction_memory.sv \
	register_file.sv \\\r\n\tdatapath.sv \\\r\n\tRV32I.sv \\\r\n\ttop.sv

# =========================
# Alvos
# =========================

all: compile

compile:
	$(IVERILOG) -v -g2012 -s $(TOP) -o $(OUT) $(SRCS)

run: compile
	$(VVP) $(OUT)

clean:
	rm -f $(OUT) *.vcd

.PHONY: all compile run clean

