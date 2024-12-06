
class c2c_driver extends uvm_driver #(c2c_packet);

  virtual interface icache_if vif;

  `uvm_component_utils(c2c_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual icache_if)::get(this, "", "vif", vif)) `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);  // Sequence'den yeni istek al

      // Cache'e istek gönder
      vif.cache_req_i.valid <= req.cache_req.valid;
      vif.cache_req_i.ready <= req.cache_req.ready;
      vif.cache_req_i.addr <= req.cache_req.addr;
      vif.cache_req_i.uncached <= req.cache_req.uncached;

      wait (vif.cache_res_o.valid);  // Yanıt bekle
      `uvm_info(get_type_name(), "Cache response received", UVM_LOW);

      vif.cache_req_i.valid <= 0;  // İstek bitti
      @(posedge vif.clk_i);
      seq_item_port.item_done();
    end
  endtask : run_phase

endclass : c2c_driver

class c2m_driver extends uvm_driver #(c2m_packet);

  virtual interface icache_if vif;

  `uvm_component_utils(c2m_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual icache_if)::get(this, "", "vif", vif)) `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);  // Sequence'den yeni istek al
      if (vif.lowX_req_o.valid) begin
        `uvm_info(get_type_name(), "LowX request received", UVM_LOW);
        repeat ($urandom_range(3, 10)) @(posedge vif.clk_i);
        vif.lowX_res_i.valid <= req.lowX_res.valid;
        vif.lowX_res_i.ready <= req.lowX_res.ready;
        vif.lowX_res_i.blk   <= req.lowX_res.blk;
        seq_item_port.item_done();
        @(posedge vif.clk_i);
        vif.lowX_res_i.valid <= 0;
      end
      @(posedge vif.clk_i);
    end
  endtask : run_phase

endclass : c2m_driver
