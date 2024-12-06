class c2c_monitor extends uvm_monitor;

  virtual interface icache_if vif;

  `uvm_component_utils(c2c_monitor)

  uvm_analysis_port #(c2c_packet) cache_send;
  c2c_packet                      packet;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cache_send = new("cache_send", this);  // Initialize analysis port
  endfunction : new

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual icache_if)::get(this, "", "vif", vif)) `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
  endfunction : connect_phase

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    packet = c2c_packet::type_id::create("packet");
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM);
    forever begin
      @(posedge vif.clk_i);
      if (vif.cache_res_o.valid) begin
        `uvm_info(get_type_name(), "Cache response captured", UVM_LOW);
        packet.cache_res = vif.cache_res_o;
        cache_send.write(packet);
      end
    end
  endtask : run_phase

endclass : c2c_monitor

class c2m_monitor extends uvm_monitor;

  `uvm_component_utils(c2m_monitor)

  virtual icache_if               vif;
  uvm_analysis_port #(c2m_packet) lowX_send;
  c2m_packet                      packet;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    lowX_send = new("lowX_send", this);
  endfunction : new

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual icache_if)::get(this, "", "vif", vif)) `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
  endfunction : connect_phase

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    packet = c2m_packet::type_id::create("packet");
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM);
    forever begin
      @(posedge vif.clk_i);
      if (vif.lowX_res_i.valid) begin
        packet.lowX_res = vif.lowX_res_i;
        lowX_send.write(packet);
      end
    end
  endtask : run_phase

endclass : c2m_monitor
