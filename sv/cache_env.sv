class cache_env extends uvm_env;

  c2c_agent  core_agent;
  c2m_agent  lowX_agent;
  scoreboard sb;

  `uvm_component_utils(cache_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    core_agent = c2c_agent::type_id::create("core_agent", this);
    lowX_agent = c2m_agent::type_id::create("lowX_agent", this);
    sb = scoreboard::type_id::create("sb", this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    core_agent.monitor.cache_send.connect(sb.c2c_mon);
    lowX_agent.monitor.lowX_send.connect(sb.c2m_mon);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : cache_env
