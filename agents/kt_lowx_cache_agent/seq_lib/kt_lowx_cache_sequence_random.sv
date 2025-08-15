`ifndef KT_LOWX_CACHE_SEQUENCE_RANDOM_SV
  `define KT_LOWX_CACHE_SEQUENCE_RANDOM_SV

class kt_lowx_cache_sequence_random extends kt_cache_sequence_base;

  rand int unsigned num_items;

  constraint num_item_default {
    soft num_items inside {[1:10]};
  }
  rand ilowX_res_t lowx_res;


  `uvm_object_utils(kt_lowx_cache_sequence_random)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    repeat(num_items) begin
/*
      kt_cache_sequence_simple seq = kt_cache_sequence_simple::type_id::create("seq");
      void'(seq.randomize());
      seq.start(m_sequencer, this);
*/
      kt_lowx_cache_sequence_simple seq;
      `uvm_do(seq)
    end

  endtask

endclass

`endif