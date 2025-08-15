`ifndef KT_CORE_CACHE_AGENT_SV
  `define KT_CORE_CACHE_AGENT_SV

  class kt_core_cache_agent extends uvm_agent implements kt_cache_reset_handler;

    // Agent Configuration Handler
    kt_core_cache_agent_config agent_config;

    kt_core_cache_sequencer sequencer;

    kt_core_cache_driver driver;

    kt_core_cache_monitor monitor;

    kt_core_cache_coverage coverage;

    `uvm_component_utils(kt_core_cache_agent)

    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      agent_config = kt_core_cache_agent_config::type_id::create("agent_config", this);

      monitor = kt_core_cache_monitor::type_id::create("monitor", this);

      if(agent_config.get_has_coverage()) begin
        coverage = kt_core_cache_coverage::type_id::create("coverage", this);
      end

      if(agent_config.get_active_passive() == UVM_ACTIVE) begin
        sequencer = kt_core_cache_sequencer::type_id::create("sequencer", this);
        driver = kt_core_cache_driver::type_id::create("driver", this);
      end

    endfunction

    virtual function void connect_phase(uvm_phase phase);
      kt_cache_vif vif;

      super.connect_phase(phase);

      if(uvm_config_db#(kt_cache_vif)::get(this, "", "vif", vif) == 0) begin
        `uvm_fatal("CACHE_NO_VIF", "Could not get from the database the cache virtual interface")
      end else begin
        agent_config.set_vif(vif);
      end

      monitor.agent_config = agent_config;

      if(agent_config.get_has_coverage()) begin
        coverage.agent_config = agent_config;

        monitor.output_port.connect(coverage.item_port);
      end

      if(agent_config.get_active_passive() == UVM_ACTIVE) begin
        driver.agent_config = agent_config;
        driver.seq_item_port.connect(sequencer.seq_item_export);
      end

    endfunction

    virtual function void handle_reset(uvm_phase phase);
      uvm_component children[$];

      get_children(children);

      foreach(children[idx]) begin
        kt_cache_reset_handler reset_handler;

        if($cast(reset_handler, children[idx])) begin
          reset_handler.handle_reset(phase);
        end
      end

    endfunction

    virtual task wait_reset_start();
      agent_config.wait_reset_start();
    endtask

    virtual task wait_reset_end();
      agent_config.wait_reset_end();
    endtask

    virtual task run_phase(uvm_phase phase);
      forever begin
        wait_reset_start();
        handle_reset(phase);
        wait_reset_end();
      end
    endtask

  endclass

`endif