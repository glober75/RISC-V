# RISC-V (RV32I)

Implementacao simples de um core RV32I em SystemVerilog.

## Arquitetura
O design esta organizado em dois blocos principais:

- `datapath.sv`: contem PC, fetch, decode, register file, branch control, ALU e o mux de writeback.
- `control.sv`: gera os sinais de controle (selecao de operando, operacao da ALU, writeback e sinais de memoria).

O modulo `RV32I.sv` integra o `datapath` com o `control` e expoe as interfaces de memoria.
O `top.sv` instancia as memorias de instrucoes e dados e conecta ao core.

## Estrutura
- datapath.sv
- RV32I.sv
- control.sv
- top.sv
- alu.sv
- branch_control.sv
- decode.sv
- fetch.sv
- instruction_memory.sv
- data_memory.sv
- register_file.sv
- riscv_pkg.sv
- test_bench.sv

## Como simular (Icarus Verilog)
make run

Observacao: o Icarus pode gerar alertas sobre blocos `always_comb` no `control.sv` sem sinais de entrada. Sugerimos simular no ModelSim/Questa para evitar esses avisos.

## Interfaces de memoria
- Instrucao: `imem_req`, `imem_addr`, `imem_data`
- Dados: `dmem_req`, `dmem_wr_en`, `dmem_size`, `dmem_zero_extend`, `dmem_addr`, `dmem_wr_data`, `dmem_rd_data`
