`ifndef KT_CORE_CACHE_ITEM_MON_SV
  `define KT_CORE_CACHE_ITEM_MON_SV

class kt_core_cache_item_mon extends kt_cache_item_base;

  //kt_cache_response response;

  int unsigned length;

  int unsigned prev_item_delay;

  icache_req_t core_req_i;

  ilowX_res_t lowX_res_i;

  `uvm_object_utils(kt_core_cache_item_mon)

    function new(string name = "");
    	super.new(name);
  	endfunction

    virtual function string convert2string();
      string result = super.convert2string();
      result = $sformatf("core_req_i.valid: %0x, core_req_i.ready: %0x, core_req_i.addr: %0x, core_req_i.uncached: %0x, lenght: %0d, pre_item_delay: %0d", core_req_i.valid, core_req_i.ready, core_req_i.addr, core_req_i.uncached, length, prev_item_delay);
    return result;

    endfunction

endclass


`endif