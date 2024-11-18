class core_cache_sequence extends uvm_sequence #(core_cache_trans);
    `uvm_object_utils(core_cache_sequence)

    function new(string name = "core_cache_sequence");
        super.new(name);
    endfunction

    // Transaction object to hold the core-to-cache request
    core_cache_trans core_cache_tx;

    // Main sequence body
    virtual task body();
        `uvm_info("SEQUENCE_INFO", "Starting core_cache_sequence", UVM_HIGH); // Log sequence start

        // Create a transaction object for the core-to-cache interface
        core_cache_tx = core_cache_trans::type_id::create("core_cache_tx");

        // Begin the sequence item, randomize it, and send it to the sequencer
        start_item(core_cache_tx); // Start the transaction
        core_cache_tx.randomize(); // Randomize the transaction fields
        `uvm_info("SEQUENCE_INFO", $sformatf("Transaction Randomized: req: %0d, res: %0d", 
            core_cache_tx.cache_req_i, core_cache_tx.cache_res_o), UVM_HIGH); // Log randomized transaction
        finish_item(core_cache_tx); // Finish and send the transaction

        `uvm_info("SEQUENCE_INFO", "Finished core_cache_sequence", UVM_HIGH); // Log sequence end
    endtask
endclass

class mem_cache_sequence extends uvm_sequence #(mem_cache_trans);
    `uvm_object_utils(mem_cache_sequence)

    function new(string name = "mem_cache_sequence");
        super.new(name);
    endfunction

    // Transaction object to hold the cache-to-memory request
    mem_cache_trans mem_cache_tx;

    // Main sequence body
    virtual task body();
        `uvm_info("SEQUENCE_INFO", "Starting mem_cache_sequence", UVM_HIGH); // Log sequence start

        // Create a transaction object for the cache-to-memory interface
        mem_cache_tx = mem_cache_trans::type_id::create("mem_cache_tx");

        // Begin the sequence item, randomize it, and send it to the sequencer
        start_item(mem_cache_tx); // Start the transaction
        mem_cache_tx.randomize(); // Randomize the transaction fields
        `uvm_info("SEQUENCE_INFO", $sformatf("Transaction Randomized: req: %0d, res: %0d", 
            mem_cache_tx.lowX_req_o, mem_cache_tx.lowX_res_i), UVM_HIGH); // Log randomized transaction
        finish_item(mem_cache_tx); // Finish and send the transaction

        `uvm_info("SEQUENCE_INFO", "Finished mem_cache_sequence", UVM_HIGH); // Log sequence end
    endtask
endclass
