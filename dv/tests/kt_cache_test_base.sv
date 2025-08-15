`ifndef KT_CACHE_TEST_BASE_SV
  `define KT_CACHE_TEST_BASE_SV

  class kt_cache_test_base extends uvm_test;

    kt_cache_env env;
    
    `uvm_component_utils(kt_cache_test_base)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);  
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      env = kt_cache_env::type_id::create("env", this);
    endfunction
    
  endclass

`endif