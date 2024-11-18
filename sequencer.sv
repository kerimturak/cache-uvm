// Sequencer Classes
// These sequencers manage the flow of transactions for each interface:
// core-to-cache and cache-to-lower memory hierarchy.

class core_cache_sequencer extends uvm_sequencer #(core_cache_trans);
    `uvm_component_utils(core_cache_sequencer)

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent); // Call base constructor with name and parent
    endfunction

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction
endclass

class mem_cache_sequencer extends uvm_sequencer #(mem_cache_trans);
    `uvm_component_utils(mem_cache_sequencer)

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent); // Call base constructor with name and parent
    endfunction

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction
endclass
