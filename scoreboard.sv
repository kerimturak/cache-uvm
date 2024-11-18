class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    // Analysis ports for Cache and LowX transactions
    uvm_analysis_port #(core_cache_trans) core_cache_mon;
    uvm_analysis_port #(mem_cache_trans) mem_cache_mon;

    // Transaction objects to store incoming transactions
    core_cache_trans cache_transaction;
    mem_cache_trans lowX_transaction;

    // Transaction counters
    int cache_count;
    int lowX_count;

    // Constructor
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
        cache_count = 0;
        lowX_count = 0;
        core_cache_mon = new("core_cache_mon", this); // Instantiate the analysis port for core_cache_trans
        mem_cache_mon = new("mem_cache_mon", this);   // Instantiate the analysis port for mem_cache_trans
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cache_transaction = core_cache_trans::type_id::create("cache_transaction");
        lowX_transaction = mem_cache_trans::type_id::create("lowX_transaction");
    endfunction

    // Cache transaction handler
    virtual function void write_cache_transaction(core_cache_trans tc);
        cache_transaction = tc;
        cache_count++;

        `uvm_info("SCOREBOARD", $sformatf("Received Cache Transaction: req: %0d, res: %0d", tc.cache_req_i, tc.cache_res_o), UVM_HIGH);

        // Example validation logic
        if (tc.icache_miss_o) begin
            `uvm_info("SCOREBOARD", "Cache Miss Detected", UVM_HIGH);
        end else begin
            `uvm_info("SCOREBOARD", "Cache Hit Detected", UVM_HIGH);
        end
    endfunction

    // LowX transaction handler
    virtual function void write_lowX_transaction(mem_cache_trans tc);
        lowX_transaction = tc;
        lowX_count++;

        `uvm_info("SCOREBOARD", $sformatf("Received LowX Transaction: req: %0d, res: %0d", tc.lowX_req_o, tc.lowX_res_i), UVM_HIGH);

        // Example validation check (could compare to cache transaction or other checks)
    endfunction

    // Report results function
    virtual function void report_results();
        `uvm_info("SCOREBOARD", $sformatf("Total Cache Transactions: %0d", cache_count), UVM_HIGH);
        `uvm_info("SCOREBOARD", $sformatf("Total LowX Transactions: %0d", lowX_count), UVM_HIGH);
    endfunction

endclass
