import riscv_pkg::*;

module datapath #(
  parameter RESET_PC = 32'h0000
)(
  input logic clk,
  input logic reset_n,

  // instruction memory interface
  output logic imem_req,
  output logic [31:0] imem_addr,
  input logic [31:0] imem_data,

  // data memory interface
  output logic [31:0] dmem_addr,
  output logic [31:0] dmem_wr_data,
  input logic [31:0] dmem_rd_data,

  // control interface
  input logic pc_sel,
  input logic op1_sel,
  input logic op2_sel,
  input alu_op_t alu_op,
  input wb_src_t rf_wr_data_sel,
  input logic rf_wr_en,

  // decode outputs
  output logic r_type, i_type, s_type, b_type, u_type, j_type,
  output logic [6:0] opcode,
  output logic [2:0] funct3,
  output logic [6:0] funct7
);

logic [31:0] pc, pc_next, next_seq_pc;
logic reset_seen;

logic [31:0] instruction;

logic [4:0] rs1_addr, rs2_addr, rd_addr;
logic [31:0] rs1_data, rs2_data, wr_data;
logic [31:0] immediate;

logic [31:0] alu_a, alu_b, alu_res;
logic branch_taken;

/*
PC register
*/
always_ff @( posedge clk or negedge reset_n ) begin
  if ( !reset_n )
    reset_seen <= 1'b0;
  else
    reset_seen <= 1'b1;
end

assign next_seq_pc = pc + 32'd4;
assign pc_next = (branch_taken | pc_sel ) ? {alu_res[31:1],1'b0} : next_seq_pc;

always_ff @(posedge clk or negedge reset_n) begin
  if (!reset_n)
    pc <= RESET_PC;
  else if (reset_seen)
    pc <= pc_next;
end

/*
Fetch
*/
fetch u_fetch (
  .clk (clk),
  .reset_n (reset_n),
  .pc(pc),
  .imem_req(imem_req),
  .imem_addr(imem_addr),
  .imem_data(imem_data),
  .instruction(instruction)
);

/*
Decode
*/
decode u_decode(
  .instruction(instruction),
  .rs1_addr(rs1_addr),
  .rs2_addr(rs2_addr),
  .rd_addr(rd_addr),
  .opcode(opcode),
  .funct3(funct3),
  .funct7(funct7),
  .r_type(r_type),
  .i_type(i_type),
  .s_type(s_type),
  .b_type(b_type),
  .u_type(u_type),
  .j_type(j_type),
  .immediate(immediate)
);

/*
Writeback mux
*/
always_comb begin
  wr_data = 32'd0;
  case (rf_wr_data_sel)
    WB_SRC_ALU : wr_data = alu_res;
    WB_SRC_MEM : wr_data = dmem_rd_data;
    WB_SRC_IMM : wr_data = immediate;
    WB_SRC_PC : wr_data = next_seq_pc;
    default: wr_data = 32'd0;
  endcase
end

register_file u_register_file (
 .clk(clk),
 .reset_n(reset_n),
 .rs1_addr(rs1_addr),
 .rs2_addr(rs2_addr),
 .rd_addr(rd_addr),
 .rf_wr_en(rf_wr_en),
 .wr_data(wr_data),
 .rs1_data(rs1_data),
 .rs2_data(rs2_data)
);

/*
Branch control
*/
branch_control u_branch_control (
  .opr_a (rs1_data),
  .opr_b (rs2_data),
  .is_b_type(b_type),
  .funct3(funct3),
  .branch_taken(branch_taken)
);

/*
ALU
*/
assign alu_a = op1_sel ? pc : rs1_data;
assign alu_b = op2_sel ? immediate : rs2_data;

alu u_alu (
  .alu_a(alu_a),
  .alu_b(alu_b),
  .alu_op(alu_op),
  .alu_res(alu_res)
);

/*
Data memory interface
*/
assign dmem_addr = alu_res;
assign dmem_wr_data  = rs2_data;

endmodule
