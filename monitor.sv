// Cache Monitor - Monitors transactions between core and cache
class core_cache_monitor extends uvm_monitor;
    `uvm_component_utils(core_cache_monitor)

    virtual icache_if vif;                  // Cache interface
    uvm_analysis_port #(core_cache_trans) cache_send; // Analysis port to send transactions
    core_cache_trans packet;                    // Transaction object

    // Constructor
    function new(string name = "core_cache_monitor", uvm_component parent = null);
        super.new(name, parent);
        cache_send = new("cache_send", this); // Initialize analysis port
    endfunction

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction

    // Build phase to set up interface
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        packet = core_cache_trans::type_id::create("packet");

        // Retrieve the interface from the UVM configuration database
        if (!uvm_config_db #(virtual icache_if)::get(this, "", "vif", vif)) 
            `uvm_fatal("MON", "Unable to access uvm_config_db to retrieve vif");
    endfunction

    // Run phase to monitor cache responses and send them to the scoreboard
    virtual task run_phase(uvm_phase phase);
        forever begin
            // Wait for a valid cache response signal
            @(posedge vif.cache_res_o.valid);

            // Create a new core_cache_trans and capture cache response data
            packet.cache_res_o = vif.cache_res_o;

            // Send transaction data to the analysis port for the scoreboard
            cache_send.write(packet);

            // Log transaction details sent to the scoreboard
            `uvm_info("CACHE_MON", $sformatf("Cache Monitor sent to Scoreboard: cache_res_o=%0d", packet.cache_res_o), UVM_HIGH);
        end
    endtask
endclass

// LowX Monitor - Monitors transactions between cache and lower hierarchy (e.g., main memory)
class mem_cache_monitor extends uvm_monitor;
    `uvm_component_utils(mem_cache_monitor)

    virtual icache_if vif;                    // Interface for lower hierarchy memory
    uvm_analysis_port #(mem_cache_trans) lowX_send; // Analysis port to send transactions
    mem_cache_trans packet;                       // Transaction object

    // Constructor
    function new(string name = "mem_cache_monitor", uvm_component parent = null);
        super.new(name, parent);
        lowX_send = new("lowX_send", this); // Initialize analysis port
    endfunction

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction

    // Build phase to set up interface
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        packet = mem_cache_trans::type_id::create("packet");

        // Retrieve the interface from the UVM configuration database
        if (!uvm_config_db #(virtual icache_if)::get(this, "", "vif", vif)) 
            `uvm_fatal("MON", "Unable to access uvm_config_db to retrieve vif");
    endfunction

    // Run phase to monitor lower hierarchy responses and send them to the scoreboard
    virtual task run_phase(uvm_phase phase);
        forever begin
            // Wait for a valid lowX response signal
            @(posedge vif.lowX_res_i.valid);

            // Create a new mem_cache_trans and capture lowX response data
            packet.lowX_res_i = vif.lowX_res_i;

            // Send transaction data to the analysis port for the scoreboard
            lowX_send.write(packet);

            // Log transaction details sent to the scoreboard
            `uvm_info("LOWX_MON", $sformatf("LowX Monitor sent to Scoreboard: lowX_res_i=%0d", packet.lowX_res_i), UVM_HIGH);
        end
    endtask
endclass
