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

class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  cache_tb tb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_int::set(this, "*", "recording_detail", 1);
    tb = cache_tb::type_id::create("tb", this);
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase

  function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction

endclass : base_test

class new_test extends base_test;

  `uvm_component_utils(new_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_wrapper::set(this, "tb.cache.core_agent.sequencer.run_phase", "default_sequence", c2c_5_packets::get_type());
    uvm_config_wrapper::set(this, "tb.cache.lowX_agent.sequencer.run_phase", "default_sequence", c2m_5_packets::get_type());
  endfunction : build_phase

endclass : new_test

import uvm_pkg::*;
`include "uvm_macros.svh"
import cache_pkg::*;
module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

icache_if vif ();

  icache i_icache (
      .clk_i        (vif.clk_i),
      .rst_ni       (vif.rst_ni),
      .cache_req_i  (vif.cache_req_i),
      .cache_res_o  (vif.cache_res_o),
      .icache_miss_o(vif.icache_miss_o),
      .lowX_res_i   (vif.lowX_res_i),
      .lowX_req_o   (vif.lowX_req_o)
  );

  initial begin
    uvm_config_db#(virtual icache_if)::set(null, "*", "vif", vif);
    run_test();
  end

  initial begin
    vif.clk_i = 0;
    vif.rst_ni = 0;
    vif.cache_req_i.valid = '0;
    vif.cache_req_i.ready = '0;
    vif.cache_req_i.addr = '0;
    vif.cache_req_i.uncached = '0;
    vif.lowX_res_i.valid = '0;
    vif.cache_req_i.ready = '0;
    #20 vif.rst_ni = 1;
    #10000;
    $stop;
  end

  always #10 vif.clk_i = ~vif.clk_i;

endmodule : top
