`ifndef KT_LOWX_CACHE_ITEM_MON_SV
  `define KT_LOWX_CACHE_ITEM_MON_SV

class kt_lowx_cache_item_mon extends kt_cache_item_base;

  //kt_cache_response response;

  int unsigned length;

  int unsigned prev_item_delay;

  icache_req_t core_req_i;

  ilowX_res_t lowX_res_i;

  `uvm_object_utils(kt_lowx_cache_item_mon)

    function new(string name = "");
    	super.new(name);
  	endfunction

    virtual function string convert2string();
      string result = super.convert2string();
      result = $sformatf("lowX_res_i.valid: %0x, lowX_res_i.ready: %0x, lowX_res_i.blk: %0x, lenght: %0d, pre_item_delay: %0d", lowX_res_i.valid, lowX_res_i.ready, lowX_res_i.blk, length, prev_item_delay);
    return result;

    endfunction

endclass

`endif