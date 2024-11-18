class env extends uvm_env;
    `uvm_component_utils(env)

    // Agentlar
    core_cache_agent cache_agent; // core_cache_agent örneği
    mem_cache_agent lowX_agent;  // mem_cache_agent örneği
    scoreboard sb;

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase: Agentları oluştur
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // core_cache_agent ve mem_cache_agent ajanlarını oluştur
        cache_agent = core_cache_agent::type_id::create("cache_agent", this);
        lowX_agent = mem_cache_agent::type_id::create("lowX_agent", this);
        sb = scoreboard::type_id::create("sb", this);
    endfunction

    // Connect phase: Agentlar arasında bağlantı kurulur
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cache_agent.monitor.cache_send.connect(sb.core_cache_mon);
        lowX_agent.monitor.lowX_send.connect(sb.mem_cache_mon);
    endfunction

    function void start_of_simulation_phase (uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation ", get_full_name()},UVM_HIGH);
    endfunction
endclass
