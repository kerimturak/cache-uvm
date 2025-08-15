`ifndef KT_CACHE_TYPES_SV
  `define KT_CACHE_TYPES_SV

  typedef virtual kt_cache_if kt_cache_vif;

  // Only dcache
  typedef enum bit {KT_CACHE_READ = 0, KT_CACHE_WRITE = 1} kt_cache_dir;

  typedef struct packed {
    logic               valid;
    logic               ready;
    logic [`xlen - 1:0] addr;
    logic               uncached;
  } icache_req_t;

// We define two different same struct because sending uncached info to lower hierarcy in some design is not necessary, or getting from core.

  typedef struct packed {
    logic               valid;
    logic               ready;
    logic [`xlen - 1:0] addr;
    logic               uncached;
  } ilowX_req_t;

  typedef struct packed {
    logic                   valid;
    logic                   ready;
    logic                   miss;
    logic [`blk_size - 1:0] blk;
  } icache_res_t;

  typedef struct packed {
    logic                   valid;
    logic                   ready;
    logic [`blk_size - 1:0] blk;
  } ilowX_res_t;

`endif