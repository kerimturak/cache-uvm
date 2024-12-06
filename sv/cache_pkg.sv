`include "tcore_param.sv"

package cache_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import tcore_param::*;
  typedef uvm_config_db#(virtual icache_if) cache_vif_config;

  `include "cache_packet.sv"
  `include "cache_seqs.sv"
  `include "cache_sequencer.sv"
  `include "cache_driver.sv"
  `include "cache_monitor.sv"
  `include "cache_scoreboard.sv"
  `include "cache_agent.sv"
  `include "cache_env.sv"


  `include "cache_tb.sv"
  `include "cache_test_lib.sv"

endpackage
