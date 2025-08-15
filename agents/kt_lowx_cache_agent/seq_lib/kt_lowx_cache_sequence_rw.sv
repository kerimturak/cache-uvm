`ifndef KT_LOWX_CACHE_SEQUENCE_RW_SV
  `define KT_LOWX_CACHE_SEQUENCE_RW_SV

class kt_lowx_cache_sequence_rw extends kt_cache_sequence_base;

  rand ilowX_req_t lowx_res;

  `uvm_object_utils(kt_lowx_cache_sequence_rw)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    /*
    kt_cache_item_drv item = kt_cache_item_drv::type_id::create("item");
    // When use core_req variable name instead of req randomization constraint does not work in test class
    void'(item.randomize() with {
      core_req.valid    == local::core_req.valid;
      core_req.ready    == local::core_req.ready;
      core_req.addr     == local::core_req.addr;
      core_req.uncached == local::core_req.uncached;

    });

    start_item(item);
    finish_item(item);
*/

    repeat(2) begin
      kt_lowx_cache_item_drv item;
      `uvm_do_with(item, {
        lowx_res.valid    == local::lowx_res.valid;
        lowx_res.ready    == local::lowx_res.ready;
        //lowx_res.blk      == local::lowx_res.blk;
      })
    end
  endtask

endclass

`endif