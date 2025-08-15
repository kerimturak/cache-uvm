`ifndef KT_LOWX_CACHE_SEQUENCE_SIMPLE_SV
`define KT_LOWX_CACHE_SEQUENCE_SIMPLE_SV

class kt_lowx_cache_sequence_simple
  extends kt_cache_sequence_base#(kt_lowx_cache_item_drv, kt_lowx_cache_sequencer);

  rand kt_lowx_cache_item_drv item;

  `uvm_object_utils(kt_lowx_cache_sequence_simple)

  function new(string name = "");
    super.new(name);
    item = kt_lowx_cache_item_drv::type_id::create("item");
  endfunction

  virtual task body();
    start_item(item);
    assert(item.randomize() with { lowx_res.valid == 1; });
    finish_item(item);
  endtask

endclass

`endif
