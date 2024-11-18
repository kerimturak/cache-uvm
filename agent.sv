class core_cache_agent extends uvm_agent;
    `uvm_component_utils(core_cache_agent)

    // Interface and communication components
    core_cache_sequencer sequencer; // Sequencer for core_cache_trans
    core_cache_driver driver;       // Driver for core_cache_trans
    core_cache_monitor monitor;

    function new(string name = "core_cache_agent", uvm_component parent = null);
        super.new(name, parent);
        monitor = core_cache_monitor::type_id::create("monitor",this);
        driver = core_cache_driver::type_id::create("driver",this);
        sequencer = core_cache_sequencer::type_id::create("sequencer",this);
    endfunction

    // Connect phase to link the driver and sequencer
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export); // Connect sequencer to driver
    endfunction

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction
endclass

class mem_cache_agent extends uvm_agent;
    `uvm_component_utils(mem_cache_agent)

    // Interface and communication components
    mem_cache_sequencer sequencer; // Sequencer for mem_cache_trans
    mem_cache_driver driver;       // Driver for mem_cache_trans
    mem_cache_monitor monitor;

    function new(string name = "mem_cache_agent", uvm_component parent = null);
        super.new(name, parent);
        monitor = mem_cache_monitor::type_id::create("monitor",this);
        driver = mem_cache_driver::type_id::create("driver",this);
        sequencer = mem_cache_sequencer::type_id::create("sequencer",this);
    endfunction

    // Connect phase to link the driver and sequencer
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export); // Connect sequencer to driver
    endfunction

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction
endclass
