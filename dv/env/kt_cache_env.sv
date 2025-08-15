`ifndef KT_CACHE_ENV_SV
  `define KT_CACHE_ENV_SV

  class kt_cache_env extends uvm_env;

    kt_core_cache_agent core_agent;
    kt_lowx_cache_agent lowx_agent;

    `uvm_component_utils(kt_cache_env)

    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      core_agent = kt_core_cache_agent::type_id::create("core_agent", this);
      lowx_agent = kt_lowx_cache_agent::type_id::create("lowx_agent", this);
    endfunction

  endclass

`endif