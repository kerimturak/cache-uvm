module plru #(
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
