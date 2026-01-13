import riscv_pkg::*;

module RV32I #(
  parameter RESET_PC = 32'h0000
)(
  input logic clk,
  input logic reset_n,

  // instruction memory interface
  output logic imem_req,
  output logic [31:0] imem_addr,
  input logic [31:0] imem_data,

  // data memory interface
  output logic dmem_req,
  output logic dmem_wr_en,
  output mem_size_t dmem_size,
  output logic dmem_zero_extend,
  output logic [31:0] dmem_addr,
  output logic [31:0] dmem_wr_data,
  input logic [31:0] dmem_rd_data
);

logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic r_type, i_type, s_type, b_type, u_type, j_type;

logic pc_sel, op1_sel, op2_sel;
alu_op_t alu_op;
wb_src_t rf_wr_data_sel;
logic rf_wr_en;

/*
Datapath
*/
datapath #(
  .RESET_PC(RESET_PC)
) u_datapath (
  .clk(clk),
  .reset_n(reset_n),
  .imem_req(imem_req),
  .imem_addr(imem_addr),
  .imem_data(imem_data),
  .dmem_addr(dmem_addr),
  .dmem_wr_data(dmem_wr_data),
  .dmem_rd_data(dmem_rd_data),
  .pc_sel(pc_sel),
  .op1_sel(op1_sel),
  .op2_sel(op2_sel),
  .alu_op(alu_op),
  .rf_wr_data_sel(rf_wr_data_sel),
  .rf_wr_en(rf_wr_en),
  .r_type(r_type),
  .i_type(i_type),
  .s_type(s_type),
  .b_type(b_type),
  .u_type(u_type),
  .j_type(j_type),
  .opcode(opcode),
  .funct3(funct3),
  .funct7(funct7)
);

/*
Control unit
*/
control u_control (
  .r_type (r_type),
  .i_type(i_type),
  .s_type(s_type),
  .b_type(b_type),
  .u_type(u_type),
  .j_type(j_type),
  .funct3(funct3),
  .funct7(funct7),
  .opcode(opcode),
  .pc_sel(pc_sel),
  .op1_sel(op1_sel),
  .op2_sel(op2_sel),
  .alu_op(alu_op),
  .rf_wr_data_sel(rf_wr_data_sel),
  .dmem_req(dmem_req),
  .dmem_size(dmem_size),
  .dmem_wr_en(dmem_wr_en),
  .dmem_zero_extend(dmem_zero_extend),
  .rf_wr_en(rf_wr_en)
);

endmodule
