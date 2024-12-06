module sp_bram #(
    parameter DATA_WIDTH = 32,
    parameter NUM_SETS   = 1024
) (
    input  logic                        clk,
    input  logic                        chip_en,
    input  logic [$clog2(NUM_SETS)-1:0] addr,
    input  logic                        wr_en,
    input  logic [      DATA_WIDTH-1:0] wr_data,
    output logic [      DATA_WIDTH-1:0] rd_data
);

  logic [DATA_WIDTH-1:0] bram[NUM_SETS-1:0];

  always @(posedge clk) begin
    if (chip_en) begin
      if (wr_en) begin
        bram[addr] <= wr_data;
        rd_data    <= wr_data;
      end else begin
        rd_data <= bram[addr];
      end
    end
  end

endmodule
