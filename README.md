# RISC-V (RV32I)

Implementacao simples de um core RV32I em SystemVerilog.

## Arquitetura
O design esta organizado em dois blocos principais:

- `datapath.sv`: contem PC, fetch, decode, register file, branch control, ALU e o mux de writeback.
- `control.sv`: gera os sinais de controle (selecao de operando, operacao da ALU, writeback e sinais de memoria).

O modulo `RV32I.sv` integra o `datapath` com o `control` e expoe as interfaces de memoria.
O `top.sv` instancia as memorias de instrucoes e dados e conecta ao core.

## Topo
```
             +------------------------------------+
             |                top                 |
             |                                    |
             |  imem_req/imem_addr   imem_data    |
             |    +----------------------------+  |
             |    |   instruction_memory       |  |
             |    +-------------+--------------+  |
             |                  |                 |
             |                  v                 |
             |            +-----------+           |
             |            |   RV32I   |           |
             |            |           |           |
             |  control ->| control   |           |
             |            +-----+-----+           |
             |                  |                 |
             |   pc/op/alu/wb   |                 |
             |                  v                 |
             |            +-----------+           |
             | dmem_* <-> | datapath  | <-> dmem  |
             |            +-----------+           |
             |                  |                 |
             |                  v                 |
             |            +-----------+           |
             |            | data_mem  |           |
             |            +-----------+           |
             +------------------------------------+
```

Sinais principais no topo:
- Instrucao: `imem_req`, `imem_addr`, `imem_data`
- Dados: `dmem_req`, `dmem_wr_en`, `dmem_size`, `dmem_zero_extend`, `dmem_addr`, `dmem_wr_data`, `dmem_rd_data`

Sinais internos (control -> datapath):
- `pc_sel`, `op1_sel`, `op2_sel`
- `alu_op`, `rf_wr_data_sel`, `rf_wr_en`

Sinais internos (datapath -> control):
- `opcode`, `funct3`, `funct7`
- `r_type`, `i_type`, `s_type`, `b_type`, `u_type`, `j_type`

## Arquivos
- `alu.sv`: implementa as operacoes da ULA.
- `branch_control.sv`: decide se um branch eh tomado com base em `funct3`.
- `control.sv`: gera sinais de controle a partir do opcode/functs.
- `data_memory.sv`: memoria de dados com acesso por byte/half/word.
- `datapath.sv`: caminho de dados com PC, fetch, decode, RF, ALU e writeback.
- `decode.sv`: separa campos da instrucao e gera imediatos.
- `fetch.sv`: solicita a instrucao na memoria de instrucoes.
- `instruction_memory.sv`: memoria de instrucoes inicializada por arquivo `.mem`.
- `register_file.sv`: banco de registradores x0..x31 com escrita sincrona.
- `riscv_pkg.sv`: tipos, enums e constantes do ISA.
- `RV32I.sv`: integra `control` + `datapath` e expoe interfaces de memoria.
- `test_bench.sv`: testbench basico para simulacao.
- `top.sv`: conecta o core RV32I as memorias.

## Como simular (Icarus Verilog)
make run

Observacao: o Icarus pode gerar alertas sobre blocos `always_comb` no `control.sv` sem sinais de entrada. Sugerimos simular no ModelSim/Questa para evitar esses avisos.

## Interfaces de memoria
- Instrucao: `imem_req`, `imem_addr`, `imem_data`
- Dados: `dmem_req`, `dmem_wr_en`, `dmem_size`, `dmem_zero_extend`, `dmem_addr`, `dmem_wr_data`, `dmem_rd_data`
