import riscv_pkg::*;

module top #(
  parameter RESET_PC = 32'h0000)(
  input logic clk,
  input logic reset_n
);

/*
instruction memory signals
*/
logic imem_req;
logic [31:0] imem_addr, imem_data;

/*
data memory signals
*/
logic dmem_req, dmem_wr_en, dmem_zero_extend;
mem_size_t dmem_size;
logic [31:0] dmem_addr, dmem_wr_data, dmem_rd_data;

/*
Instruction Memory
*/
instruction_memory u_instruction_memory (
 .imem_req (imem_req),
 .imem_addr( imem_addr),
 .imem_data (imem_data)
);

/*
Data Memory
*/
data_memory u_data_memory (
  .clk(clk),
  .dmem_req (dmem_req),
  .dmem_wr_en (dmem_wr_en),
  .dmem_data_size(dmem_size),
  .dmem_addr(dmem_addr),
  .dmem_wr_data(dmem_wr_data),
  .dmem_zero_extend(dmem_zero_extend),
  .dmem_rd_data(dmem_rd_data)
);

/*
Core
*/
RV32I #(
  .RESET_PC(RESET_PC)
) u_rv32i (
  .clk(clk),
  .reset_n(reset_n),
  .imem_req(imem_req),
  .imem_addr(imem_addr),
  .imem_data(imem_data),
  .dmem_req(dmem_req),
  .dmem_wr_en(dmem_wr_en),
  .dmem_size(dmem_size),
  .dmem_zero_extend(dmem_zero_extend),
  .dmem_addr(dmem_addr),
  .dmem_wr_data(dmem_wr_data),
  .dmem_rd_data(dmem_rd_data)
);

endmodule
