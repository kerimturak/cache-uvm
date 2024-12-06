
class c2c_sequencer extends uvm_sequencer #(c2c_packet);

  `uvm_component_utils(c2c_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);     // important!!
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : c2c_sequencer

class c2m_sequencer extends uvm_sequencer #(c2m_packet);

  `uvm_component_utils(c2m_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : c2m_sequencer