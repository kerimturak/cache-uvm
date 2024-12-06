class cache_tb extends uvm_env;

  `uvm_component_utils(cache_tb)

  cache_env cache;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    `uvm_info("MSG", "In the build phase", UVM_HIGH)
    super.build_phase(phase);
    cache = cache_env::type_id::create("cache", this);

  endfunction : build_phase

endclass : cache_tb
