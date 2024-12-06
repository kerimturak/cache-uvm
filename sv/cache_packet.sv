class c2c_packet extends uvm_sequence_item;
  rand icache_req_t cache_req;
  icache_res_t      cache_res;
  bit               icache_miss;

  function new(input string name = "c2c_packet");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(c2c_packet)
    `uvm_field_int(cache_req, UVM_DEFAULT)
    `uvm_field_int(cache_res, UVM_DEFAULT)
    `uvm_field_int(icache_miss, UVM_DEFAULT)
  `uvm_object_utils_end

  constraint valid_ready {
    cache_req.valid == 1'b1;
    cache_req.ready == 1'b1;
  }

endclass : c2c_packet

class new_c2c_packet extends c2c_packet;

  `uvm_object_utils(new_c2c_packet)

  function new(string name = "new_c2c_packet");
    super.new(name);
  endfunction : new

endclass : new_c2c_packet

class c2m_packet extends uvm_sequence_item;
  ilowX_req_t lowX_req;
  rand ilowX_res_t lowX_res;

  function new(input string name = "c2m_packet");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(c2m_packet)
    `uvm_field_int(lowX_req, UVM_DEFAULT)
    `uvm_field_int(lowX_res, UVM_DEFAULT)
  `uvm_object_utils_end

  constraint valid_ready {
    lowX_res.valid == 1'b1;
    lowX_res.ready == 1'b1;
  }

endclass : c2m_packet

class new_c2m_packet extends c2m_packet;

  `uvm_object_utils(new_c2m_packet)

  function new(string name = "new_c2m_packet");
    super.new(name);
  endfunction : new

endclass : new_c2m_packet
