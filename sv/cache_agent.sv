class c2c_agent extends uvm_agent;

  c2c_monitor   monitor;
  c2c_sequencer sequencer;
  c2c_driver    driver;

  `uvm_component_utils_begin(c2c_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = c2c_monitor::type_id::create("monitor", this);
    if (is_active == UVM_ACTIVE) begin
      sequencer = c2c_sequencer::type_id::create("sequencer", this);
      driver = c2c_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE) driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : c2c_agent

class c2m_agent extends uvm_agent;

  c2m_monitor   monitor;
  c2m_sequencer sequencer;
  c2m_driver    driver;

  `uvm_component_utils_begin(c2m_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = c2m_monitor::type_id::create("monitor", this);
    if (is_active == UVM_ACTIVE) begin
      sequencer = c2m_sequencer::type_id::create("sequencer", this);
      driver = c2m_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE) driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : c2m_agent
