class core_cache_driver extends uvm_driver #(core_cache_trans);
    `uvm_component_utils(core_cache_driver)

    core_cache_trans packet;             // Transaction object
    virtual icache_if vif;               // Interface for cache interactions

    function new(string name = "core_cache_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction

    // Build phase to initialize interface
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Instantiate a core_cache_trans object
        packet = core_cache_trans::type_id::create("packet");

        // Retrieve the interface from the UVM configuration database
        if (!uvm_config_db #(virtual icache_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Unable to access uvm_config_db to retrieve vif");
    endfunction

    // Run phase to continually process transactions
    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(packet); // Fetch the next transaction

            // Apply transaction data to the cache request signal
            vif.cache_req_i <= packet.cache_req_i;

            // Log the transaction being driven
            `uvm_info("DRIVER_INFO", $sformatf("Driving Transaction: cache_req_i=%0d, cache_res_o=%0d, icache_miss_o=%0d",
                        packet.cache_req_i, packet.cache_res_o, packet.icache_miss_o), UVM_HIGH);

            seq_item_port.item_done(); // Mark transaction as complete
            #10;  // Delay for simulation stability (adjust as needed)
        end
    endtask
endclass

class mem_cache_driver extends uvm_driver #(mem_cache_trans);
    `uvm_component_utils(mem_cache_driver)

    mem_cache_trans packet;              // Transaction object
    virtual icache_if vif;               // Interface for lower hierarchy memory

    function new(string name = "mem_cache_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation", get_full_name()},UVM_HIGH);
    endfunction

    // Build phase to initialize interface
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Instantiate a mem_cache_trans object
        packet = mem_cache_trans::type_id::create("packet");

        // Retrieve the interface from the UVM configuration database
        if (!uvm_config_db #(virtual icache_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Unable to access uvm_config_db to retrieve vif");
    endfunction

    // Run phase to continually process transactions
    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(packet); // Fetch the next transaction

            // Apply transaction data to the lower memory response signal
            vif.lowX_res_i <= packet.lowX_res_i;

            // Log the transaction being driven
            `uvm_info("DRIVER_INFO", $sformatf("Driving Transaction: lowX_req_o=%0d, lowX_res_i=%0d",
                        packet.lowX_req_o, packet.lowX_res_i), UVM_HIGH);

            seq_item_port.item_done(); // Mark transaction as complete
            #10;  // Delay for simulation stability (adjust as needed)
        end
    endtask
endclass
