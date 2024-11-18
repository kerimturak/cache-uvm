`timescale 1ns / 1ps
package tcore_param;
  localparam XLEN = 32;
  localparam BLK_SIZE = 128;

  localparam IC_WAY = 8;
  localparam IC_CAPACITY = 8 * (2 ** 10) * 8;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
  } icache_req_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [BLK_SIZE-1:0] blk;
  } icache_res_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [BLK_SIZE-1:0] blk;
  } ilowX_res_t;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
  } ilowX_req_t;

endpackage



module icache import tcore_param::*; #(
    parameter CACHE_SIZE = IC_CAPACITY,
    parameter BLK_SIZE = tcore_param::BLK_SIZE,
    parameter XLEN = tcore_param::XLEN,
    parameter NUM_WAY = IC_WAY
) (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  icache_req_t cache_req_i,
    output icache_res_t cache_res_o,
    output logic        icache_miss_o,
    input  ilowX_res_t  lowX_res_i,
    output ilowX_req_t  lowX_req_o
);

  localparam NUM_SET = (CACHE_SIZE / BLK_SIZE) / NUM_WAY;
  localparam IDX_WIDTH = $clog2(NUM_SET);
  localparam BOFFSET = $clog2(BLK_SIZE / 8);
  localparam WOFFSET = (BLK_SIZE / 32);
  localparam TAG_SIZE = XLEN - IDX_WIDTH - BOFFSET;

  logic                 uncached_q;
  logic                 cache_miss;
  logic                 cache_hit;
  logic [IDX_WIDTH-1:0] rd_idx;
  logic [IDX_WIDTH-1:0] wr_idx;
  logic                 cache_wr_en;
  logic [ BLK_SIZE-1:0] data_rd_line      [NUM_WAY];
  logic [  NUM_WAY-1:0] evict_way;
  logic [  NUM_WAY-1:0] data_write_way;
  logic [   TAG_SIZE:0] cache_rd_tag      [NUM_WAY];
  logic                 flush;
  logic [IDX_WIDTH-1:0] flush_index;
  logic [IDX_WIDTH-1:0] cache_idx;
  logic [   TAG_SIZE:0] cache_wr_tag;
  logic [  NUM_WAY-1:0] tag_write_way;
  logic [  NUM_WAY-1:0] cache_valid_vec;
  logic [  NUM_WAY-1:0] cache_hit_vec;
  logic                 node_wr_en;
  logic [  NUM_WAY-2:0] updated_node;
  logic [  NUM_WAY-2:0] cache_wr_node;
  logic [  NUM_WAY-2:0] cache_rd_node;
  logic [ BLK_SIZE-1:0] cache_select_data;
  logic                 cpu_valid_q;
  logic [     XLEN-1:0] addr_q;

  for (genvar i = 0; i < NUM_WAY; i++) begin : idata_array
    sp_bram #(
        .DATA_WIDTH(BLK_SIZE),
        .NUM_SETS  (NUM_SET)
    ) data_array (
        .clk    (clk_i),
        .chip_en(1'b1),
        .addr   (cache_idx),
        .wr_en  (data_write_way[i]),
        .wr_data(lowX_res_i.blk),
        .rd_data(data_rd_line[i])
    );
  end

  for (genvar i = 0; i < NUM_WAY; i++) begin : itag_array
    sp_bram #(
        .DATA_WIDTH(TAG_SIZE + 1),
        .NUM_SETS  (NUM_SET)
    ) tag_array (
        .clk    (clk_i),
        .chip_en(1'b1),
        .addr   (cache_idx),
        .wr_en  (tag_write_way[i]),
        .wr_data(cache_wr_tag),
        .rd_data(cache_rd_tag[i])
    );
  end

  sp_bram #(
      .DATA_WIDTH(NUM_WAY - 1),
      .NUM_SETS  (NUM_SET)
  ) node_array (
      .clk    (clk_i),
      .chip_en(1'b1),
      .addr   (cache_idx),
      .wr_en  (node_wr_en),
      .wr_data(cache_wr_node),
      .rd_data(cache_rd_node)
  );

  plru #(
      .NUM_WAY(NUM_WAY)
  ) iplru (
      .node_i     (cache_rd_node),
      .hit_vec_i  (cache_hit_vec),
      .evict_way_o(evict_way),
      .node_o     (updated_node)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      cpu_valid_q <= '0;
      addr_q      <= '0;
      uncached_q  <= '0;
      flush_index <= '0;
      flush       <= '1;
    end else begin
      cpu_valid_q <= cache_req_i.valid && !cache_res_o.valid;
      addr_q <= cache_req_i.addr;
      uncached_q <= cache_req_i.uncached;
      if (flush && flush_index != 2 ** IDX_WIDTH - 1) begin
        flush_index <= flush_index + 1'b1;
      end else begin
        flush_index <= 1'b0;
        flush       <= 1'b0;
      end
    end
  end

  always_comb begin
    for (int i = 0; i < NUM_WAY; i++) begin
      cache_valid_vec[i] = cache_rd_tag[i][TAG_SIZE];
      cache_hit_vec[i]   = cache_rd_tag[i][TAG_SIZE-1:0] == addr_q[XLEN-1 : IDX_WIDTH+BOFFSET];
    end

    cache_wr_tag = flush ? '0 : {1'b1, addr_q[XLEN-1 : IDX_WIDTH+BOFFSET]};
    cache_wr_node = flush ? '0 : updated_node;

    cache_select_data = '0;
    for (int i = 0; i < NUM_WAY; i++) begin
      if (cache_hit_vec[i]) cache_select_data = data_rd_line[i];
    end

    rd_idx    = cache_req_i.addr[IDX_WIDTH + BOFFSET-1:BOFFSET];
    wr_idx    = flush ? flush_index : addr_q[IDX_WIDTH + BOFFSET-1:BOFFSET];

    cache_miss = cpu_valid_q && !flush && !(|(cache_valid_vec & cache_hit_vec));
    cache_hit  = cpu_valid_q && !flush &&  (|(cache_valid_vec & cache_hit_vec));

    cache_wr_en = cache_miss && lowX_res_i.valid && !uncached_q || flush;
    cache_idx = cache_wr_en ? wr_idx : rd_idx;

    node_wr_en = cache_wr_en || cache_hit ;

    tag_write_way  = '0;
    data_write_way = '0;
    for (int i = 0; i < NUM_WAY; i++) tag_write_way[i] = flush ? '1 : evict_way[i] && cache_wr_en;
    for (int i = 0; i < NUM_WAY; i++) data_write_way[i] = evict_way[i] && cache_wr_en;
  end

  always_comb begin
    lowX_req_o.valid    = cache_miss;
    lowX_req_o.ready    = !flush;
    lowX_req_o.addr     = addr_q;
    lowX_req_o.uncached = uncached_q;
    icache_miss_o       = cache_miss;
    cache_res_o.valid   = cache_req_i.ready && (cache_hit || (cache_miss && lowX_req_o.ready && lowX_res_i.valid));
    cache_res_o.ready   = (!cache_miss || lowX_res_i.valid) && !flush;
    cache_res_o.blk     = (cache_miss && lowX_res_i.valid) ? lowX_res_i.blk : cache_select_data;
  end

endmodule



module plru import tcore_param::*; #(
    parameter NUM_WAY = 4
) (
    input  logic [NUM_WAY-2:0] node_i,
    input  logic [NUM_WAY-1:0] hit_vec_i,
    output logic [NUM_WAY-1:0] evict_way_o,
    output logic [NUM_WAY-2:0] node_o
);

  always_comb begin : plru_replacement
    node_o = node_i;
    for (int unsigned i = 0; i < NUM_WAY; i++) begin
      automatic int unsigned idx_base, shift, new_index;
      if (hit_vec_i[i]) begin
        for (int unsigned lvl = 0; lvl < $clog2(NUM_WAY); lvl++) begin
          idx_base = $unsigned((2 ** lvl) - 1);
          shift = $clog2(NUM_WAY) - lvl;
          new_index = ~((i >> (shift - 1)) & 32'b1);
          node_o[idx_base+(i>>shift)] = new_index[0];
        end
      end
    end

    evict_way_o = '0;
    for (int unsigned i = 0; i < NUM_WAY; i += 1) begin
      automatic int unsigned idx_base, shift, new_index;
      automatic logic en;
      en = 1'b1;
      for (int unsigned lvl = 0; lvl < $clog2(NUM_WAY); lvl++) begin
        idx_base = $unsigned((2 ** lvl) - 1);
        shift = $clog2(NUM_WAY) - lvl;
        new_index = (i >> (shift - 1)) & 32'b1;
        if (new_index[0]) begin
          en &= node_i[idx_base+(i>>shift)];
        end else begin
          en &= ~node_i[idx_base+(i>>shift)];
        end
      end
      evict_way_o[i] = en;
    end
  end
endmodule



module sp_bram import tcore_param::*; #(
    parameter DATA_WIDTH = 32,   // Veri genişliği
    parameter NUM_SETS   = 1024  // Set sayısı
) (
    input  logic                        clk,      // Clock sinyali
    input  logic                        chip_en,
    input  logic [$clog2(NUM_SETS)-1:0] addr,     // Adres sinyali
    input  logic                        wr_en,    // Yazma işlemi enable sinyali
    input  logic [      DATA_WIDTH-1:0] wr_data,  // Yazılacak veri
    output logic [      DATA_WIDTH-1:0] rd_data   // Okunan veri
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