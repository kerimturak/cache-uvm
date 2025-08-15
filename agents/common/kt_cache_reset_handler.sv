`ifndef KT_CACHE_RESET_HANDLER_SV
  `define KT_CACHE_RESET_HANDLER_SV

  interface class kt_cache_reset_handler;

    pure virtual function void handle_reset(uvm_phase phase);

  endclass

`endif