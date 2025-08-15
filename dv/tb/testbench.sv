`include "kt_cache_test_pkg.sv"

module testbench;

  import uvm_pkg::*;
  import kt_cache_params::*;
  import kt_cache_test_pkg::*;

  // Clock Generate Logic
  reg clk_i;
  reg rst_ni;

  // Instance of the BUS interface
  kt_cache_if vif (.clk_i(clk_i));

  // ===== Local sinyaller (struct alanlarını ayrı tanımlıyoruz) =====
  // cache_req_i
  logic                cache_req_valid;
  logic                cache_req_ready;
  logic [    XLEN-1:0] cache_req_addr;
  logic                cache_req_uncached;

  // cache_res_o
  logic                cache_res_valid;
  logic                cache_res_ready;
  logic                cache_res_miss;
  logic [BLK_SIZE-1:0] cache_res_blk;

  // lowX_res_i
  logic                lowX_res_valid;
  logic                lowX_res_ready;
  logic [BLK_SIZE-1:0] lowX_res_blk;

  // lowX_req_o
  logic                lowX_req_valid;
  logic                lowX_req_ready;
  logic [    XLEN-1:0] lowX_req_addr;
  logic                lowX_req_uncached;

  // ================================================================

  // Clock generation
  initial begin
    clk_i = 0;
    forever clk_i = #5 ~clk_i;
  end

  // Reset generation
  initial begin
    vif.rst_ni  = 1;
    vif.flush_i = 0;

    // #3ns; vif.rst_ni = 0;
    // #30ns; vif.rst_ni = 1;
  end

  // UVM & Dump setup
  initial begin
    uvm_test_done.set_drain_time(null, 1000ns);
    $dumpfile("dump.vcd");
    $dumpvars;

    uvm_config_db#(virtual kt_cache_if)::set(null, "uvm_test_top.env.core_agent", "vif", vif);
    uvm_config_db#(virtual kt_cache_if)::set(null, "uvm_test_top.env.lowx_agent", "vif", vif);

    // Run Test Start Point
    run_test("");
  end

  // Instantiate DUT
  kt_cache #(
      .IS_ICACHE  (1),
      .cache_req_t(icache_req_t),
      .cache_res_t(icache_res_t),
      .lowX_req_t (ilowX_req_t),
      .lowX_res_t (ilowX_res_t),
      .CACHE_SIZE (IC_CAPACITY),
      .BLK_SIZE   (BLK_SIZE),
      .XLEN       (XLEN),
      .NUM_WAY    (IC_WAY)
  ) icache (
      .clk_i      (clk_i),
      .rst_ni     (vif.rst_ni),
      .flush_i    (vif.flush_i),
      .cache_req_i(vif.cache_req_i),
      .cache_res_o(vif.cache_res_o),
      .lowX_res_i (vif.lowX_res_i),
      .lowX_req_o (vif.lowX_req_o)
  );

  // ===== Struct alanlarını local sinyallere bağlama =====
  // cache_req_i
  assign cache_req_valid    = vif.cache_req_i.valid;
  assign cache_req_ready    = vif.cache_req_i.ready;
  assign cache_req_addr     = vif.cache_req_i.addr;
  assign cache_req_uncached = vif.cache_req_i.uncached;

  // cache_res_o
  assign cache_res_valid    = vif.cache_res_o.valid;
  assign cache_res_ready    = vif.cache_res_o.ready;
  assign cache_res_miss     = vif.cache_res_o.miss;
  assign cache_res_blk      = vif.cache_res_o.blk;

  // lowX_res_i
  assign lowX_res_valid     = vif.lowX_res_i.valid;
  assign lowX_res_ready     = vif.lowX_res_i.ready;
  assign lowX_res_blk       = vif.lowX_res_i.blk;

  // lowX_req_o
  assign lowX_req_valid     = vif.lowX_req_o.valid;
  assign lowX_req_ready     = vif.lowX_req_o.ready;
  assign lowX_req_addr      = vif.lowX_req_o.addr;
  assign lowX_req_uncached  = vif.lowX_req_o.uncached;
  // ======================================================

  // Monitor
  /*
  initial begin
    #100; // biraz bekle
    $monitor("REQ: valid=%0b ready=%0b addr=0x%08h uncached=%0b | RES: valid=%0b ready=%0b miss=%0b",
             cache_req_valid,
             cache_req_ready,
             cache_req_addr,
             cache_req_uncached,
             cache_res_valid,
             cache_res_ready,
             cache_res_miss
    );
  end
*/

  initial begin
    #750ns;
    $stop;
  end
endmodule
