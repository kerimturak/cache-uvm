`ifndef KT_CACHE_ITEM_BASE_SV
  `define KT_CACHE_ITEM_BASE_SV

class kt_cache_item_base extends uvm_sequence_item;

  rand icache_req_t core_req;
	rand ilowX_res_t  lowx_res;
  // rand kt_cache_dir dir;

  `uvm_object_utils(kt_cache_item_base)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual function string convert2string();
      string result = $sformatf("valid: %0x, ready: %0x, addr: %0x, uncached: %0x",
                                core_req.valid, core_req.ready, core_req.addr, core_req.uncached);

    return result;

  endfunction

endclass


`endif