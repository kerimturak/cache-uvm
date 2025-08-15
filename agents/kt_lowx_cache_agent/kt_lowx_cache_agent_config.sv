`ifndef KT_LOWX_CACHE_AGENT_CONFIG_SV
  `define KT_LOWX_CACHE_AGENT_CONFIG_SV

  class kt_lowx_cache_agent_config extends uvm_component;

    local kt_cache_vif vif;
    local uvm_active_passive_enum active_passive;
    local bit has_checks;
    local bit has_coverage;
	  local int unsigned stuck_treshold;

    `uvm_component_utils(kt_lowx_cache_agent_config)

      function new(string name = "", uvm_component parent);
        super.new(name, parent);

        active_passive = UVM_ACTIVE;
        has_checks     = 1;
        has_coverage   = 1;
        stuck_treshold = 1000;
      endfunction

    virtual function kt_cache_vif get_vif();
      return vif;
    endfunction

    virtual function void set_vif(kt_cache_vif value);
      if(vif == null) begin
        vif = value;

        set_has_checks(get_has_checks());
      end else begin
        `uvm_fatal("ALGORITHM_ISSUE", "Trying to set the APB virtual interface more than once")
      end
    endfunction

    virtual function uvm_active_passive_enum get_active_passive();
      return active_passive;
    endfunction

    virtual function void set_active_passive(uvm_active_passive_enum value);
        active_passive = value;
    endfunction

     //Getter for the has_coverage control field
    virtual function bit get_has_coverage();
      return has_coverage;
    endfunction

    //Setter for the has_coverage control field
    virtual function void set_has_coverage(bit value);
      has_coverage = value;
    endfunction

    virtual function bit get_has_checks();
      return has_checks;
    endfunction

    virtual function void set_has_checks(bit value);
        has_checks = value;

      if(vif != null)begin
       vif.has_checks = value;
      end
      `uvm_info("CONFIG", $sformatf("HAS_CECKS is changed to value %0d.", value), UVM_LOW)

    endfunction

    virtual function int unsigned get_stuck_treshold();
      return stuck_treshold;
    endfunction

    virtual function void set_stuck_treshold(int unsigned value);
        stuck_treshold = value;
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);

      if(get_vif == null) begin
        `uvm_fatal("ALGORITHM_ISSUE", "The cache virtual interface is not configured at \"Start of simulation \" phase ")
      end else begin
        `uvm_info("CACHE_CONFIG", "The cache virtual interface is configured at \"Start of simulation \" phase ", UVM_LOW)
      end

    endfunction

    virtual task run_phase (uvm_phase phase);
      forever begin
        @(vif.has_checks);

        if(vif.has_checks != get_has_checks()) begin
          `uvm_error("ALGORITHM ISSUE", $sformatf("Cannot change \'has_check\' from cache interface directly - use %0s.set_has_checks()", get_full_name()))
        end
      end
    endtask

    //Task for waiting the reset to start
    virtual task wait_reset_start();
      if(vif.rst_ni !== 0) begin
        @(negedge vif.rst_ni);
      end
    endtask

    //Task for waiting the reset to be finished
    virtual task wait_reset_end();
      while(vif.rst_ni == 0) begin
        @(posedge vif.clk_i);
      end
    endtask

  endclass

`endif