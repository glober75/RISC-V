import riscv_pkg::*;

module data_memory #(
  parameter int ADDR_WIDTH = 16,   // quantidade de bits de endereço em bytes
  parameter int DATA_WIDTH = 8     // byte
)(
  input  logic        clk,
  input  logic        dmem_req,
  input  logic        dmem_wr_en,
  input  mem_size_t   dmem_data_size,
  input  logic [31:0] dmem_addr,
  input  logic [31:0] dmem_wr_data,
  input  logic        dmem_zero_extend,

  output logic [31:0] dmem_rd_data
);

logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

logic [ADDR_WIDTH-1:0] addr;
logic [7:0]  b0, b1, b2, b3;

assign addr = dmem_addr[ADDR_WIDTH-1:0];

// =========================
// ESCRITA (sincrona)
// =========================
always_ff @(posedge clk) begin
  if (dmem_req && dmem_wr_en) begin
    case (dmem_data_size)
      BYTE: begin
        mem[addr] <= dmem_wr_data[7:0];
      end

      HALF_WORD: begin
        mem[addr]     <= dmem_wr_data[7:0];
        mem[addr + 1] <= dmem_wr_data[15:8];
      end

      WORD: begin
        mem[addr]     <= dmem_wr_data[7:0];
        mem[addr + 1] <= dmem_wr_data[15:8];
        mem[addr + 2] <= dmem_wr_data[23:16];
        mem[addr + 3] <= dmem_wr_data[31:24];
      end

      default: ;
    endcase
  end
end

// =========================
// LEITURA (combinacional)
// =========================

always @* begin
  b0 = mem[addr];
  b1 = mem[addr + 1];
  b2 = mem[addr + 2];
  b3 = mem[addr + 3];

  dmem_rd_data = 32'd0;

  if (dmem_req && !dmem_wr_en) begin
    case (dmem_data_size)
      BYTE: begin
        dmem_rd_data = dmem_zero_extend ? {24'd0, b0} : {{24{b0[7]}}, b0};
      end

      HALF_WORD: begin
        dmem_rd_data = dmem_zero_extend ? {16'd0, b1, b0} : {{16{b1[7]}}, b1, b0};
      end

      WORD: begin
        dmem_rd_data = {b3, b2, b1, b0};
      end

      default: dmem_rd_data = 32'd0;
    endcase
  end
end

endmodule
