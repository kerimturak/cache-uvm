`ifndef KT_CACHE_IF_SV
`define KT_CACHE_IF_SV

`ifndef XLEN
  `define xlen 32
`endif

`ifndef BLK_SIZE
  `define blk_size 128
`endif

interface kt_cache_if(input clk_i);
    import kt_cache_params::*;

    logic       rst_ni;
    logic       flush_i;
    icache_req_t cache_req_i;
    icache_res_t cache_res_o;
    ilowX_res_t  lowX_res_i;
    ilowX_req_t  lowX_req_o;

    bit has_checks;

    initial begin
      has_checks = 1;
    end

 
    //-------------------------------------------------------------------------
    // Handshaking Rule Assertions
    //-------------------------------------------------------------------------

    // Rule 1: A 'valid' signal must remain high until a 'ready' signal is received.
    property p_cache_req_valid_stays_high;
      @(posedge clk_i) disable iff(!rst_ni && !has_checks)
      (cache_req_i.valid && !cache_req_i.ready) |=> cache_req_i.valid;
    endproperty

    assert_cache_req_valid_stays_high:
      assert property (p_cache_req_valid_stays_high)
        $info("Rule PASS: cache_req_i handshaking is correct.");
      else $error("Assertion Failed: cache_req_i.valid dropped on next cycle without cache_req_i.ready being asserted.");


    // Rule 2: The cache response 'valid' signal must remain high until 'ready' is received.
    property p_cache_res_valid_stays_high;
      @(posedge clk_i) disable iff(!rst_ni && !has_checks)
      (cache_res_o.valid && !cache_res_o.ready) |=> cache_res_o.valid;
    endproperty

    assert_cache_res_valid_stays_high:
      assert property (p_cache_res_valid_stays_high)
        $info("Rule PASS: cache_res_o handshaking is correct.");
      else $error("Assertion Failed: cache_res_o.valid dropped on next cycle without cache_res_o.ready being asserted.");


    // Rule 3: The lowX request 'valid' signal must remain high until a 'ready' is received.
    property p_lowX_req_valid_stays_high;
      @(posedge clk_i) disable iff(!rst_ni && !has_checks)
      (lowX_req_o.valid && !lowX_req_o.ready) |=> lowX_req_o.valid;
    endproperty

    assert_lowX_req_valid_stays_high:
      assert property (p_lowX_req_valid_stays_high)
        $info("Rule PASS: lowX_req_o handshaking is correct.");
      else $error("Assertion Failed: lowX_req_o.valid dropped on next cycle without lowX_req_o.ready being asserted.");


    //-------------------------------------------------------------------------
    // Logical and Data Flow Rule Assertions
    //-------------------------------------------------------------------------

    // Rule 4: A cache miss must trigger a lowX memory request.
    property p_miss_triggers_lowX_req;
      @(posedge clk_i) disable iff(!rst_ni && !has_checks)
      (cache_res_o.valid && cache_res_o.miss) |-> lowX_req_o.valid;
    endproperty

    assert_miss_triggers_lowX_req:
      assert property (p_miss_triggers_lowX_req)
        $info("Rule PASS: Cache miss successfully triggered a lowX request.");
      else $error("Assertion Failed: Cache miss detected but lowX_req_o.valid was not asserted on the next cycle.");


    // Rule 5: A cache cannot have both a hit and a miss at the same time.
    property p_hit_xor_miss;
      @(posedge clk_i) disable iff(!rst_ni && !has_checks)
      !((!cache_res_o.miss && cache_res_o.valid) && (cache_res_o.miss && cache_res_o.valid));
    endproperty

    assert_hit_xor_miss:
      assert property (p_hit_xor_miss)
        $info("Rule PASS: Cache hit and miss states are mutually exclusive.");
      else $error("Assertion Failed: Both cache hit and cache miss were asserted simultaneously.");


    // Rule 6: When a response arrives from the lower memory, the cache must be ready to accept it.
    property p_lowX_res_valid_requires_ready;
      @(posedge clk_i) disable iff(!rst_ni && !has_checks)
      (lowX_res_i.valid) |-> lowX_res_i.ready;
    endproperty

    assert_lowX_res_valid_requires_ready:
      assert property (p_lowX_res_valid_requires_ready)
        $info("Rule PASS: Cache is ready to accept a lowX response.");
      else $error("Assertion Failed: A response from lowX (lowX_res_i.valid) arrived without the cache asserting lowX_res_i.ready.");

endinterface

`endif