class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  cache_tb tb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_int::set(this, "*", "recording_detail", 1);
    tb = cache_tb::type_id::create("tb", this);
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase

  function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction

endclass : base_test

class new_test extends base_test;

  `uvm_component_utils(new_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_wrapper::set(this, "tb.cache.core_agent.sequencer.run_phase", "default_sequence", c2c_5_packets::get_type());
    uvm_config_wrapper::set(this, "tb.cache.lowX_agent.sequencer.run_phase", "default_sequence", c2m_5_packets::get_type());
  endfunction : build_phase

endclass : new_test

