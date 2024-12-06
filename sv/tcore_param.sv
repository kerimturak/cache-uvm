package tcore_param;
  localparam XLEN = 32;
  localparam BLK_SIZE = 128;

  localparam IC_WAY = 8;
  localparam IC_CAPACITY = 8 * (2 ** 10) * 8;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
  } icache_req_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [BLK_SIZE-1:0] blk;
  } icache_res_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [BLK_SIZE-1:0] blk;
  } ilowX_res_t;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
  } ilowX_req_t;

endpackage
