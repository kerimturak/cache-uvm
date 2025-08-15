`ifndef KT_CORE_CACHE_SEQUENCE_SIMPLE_SV
  `define KT_CORE_CACHE_SEQUENCE_SIMPLE_SV

class kt_core_cache_sequence_simple extends kt_cache_sequence_base #(kt_core_cache_item_drv, kt_core_cache_sequencer);

  rand kt_core_cache_item_drv item;

  `uvm_object_utils(kt_core_cache_sequence_simple)

  function new(string name = "");
    super.new(name);
    item = kt_core_cache_item_drv::type_id::create("item");
  endfunction

  virtual task body();
    `uvm_send(item);
  endtask

endclass

`endif