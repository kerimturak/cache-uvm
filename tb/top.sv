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
