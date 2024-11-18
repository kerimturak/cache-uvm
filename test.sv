class test extends uvm_test;
    `uvm_component_utils(test)
    core_cache_sequence core_cache_seqs;  // Cache için sequence
    mem_cache_sequence mem_cache_seqs;    // LowX için sequence
    env environment;               // Test çevresi

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        core_cache_seqs = core_cache_sequence::type_id::create("core_cache_seqs", this);
        mem_cache_seqs = mem_cache_sequence::type_id::create("mem_cache_seqs", this);
        environment = env::type_id::create("environment", this);
        `uvm_info("MSG_TEST", "Test build phase executed", UVM_HIGH);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        fork
          core_cache_seqs.start(environment.cache_agent.sequencer);
        join_none
        fork
            mem_cache_seqs.start(environment.lowX_agent.sequencer);
        join_none
        #50; // Testin 50 zaman birimi kadar çalışması sağlanır
        phase.drop_objection(this);
    endtask

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction
endclass