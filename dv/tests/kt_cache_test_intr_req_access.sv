`ifndef KT_CACHE_TEST_REG_ACCES_SV
  `define KT_CACHE_TEST_REG_ACCES_SV

  class kt_cache_test_intr_req_access extends kt_cache_test_base;

    `uvm_component_utils(kt_cache_test_intr_req_access)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);  
    endfunction
    
    function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      
      uvm_top.print_topology();
    endfunction
    
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this, "TEST_DONE");
      
      `uvm_info("UVM_DEBUG", "start of test", UVM_LOW)
      #100;
      
      fork
     
        begin
          kt_cache_vif vif = env.core_agent.agent_config.get_vif();
          
          repeat(3) begin
            @(posedge vif.clk_i);
          end
          
          #3ns;
           
          vif.rst_ni <= 0;
          
          repeat(4) begin
            @(posedge vif.clk_i);
          end
          
          vif.rst_ni <= 1;
         end
     
        begin
          kt_core_cache_sequence_simple seq_simple = kt_core_cache_sequence_simple::type_id::create("seq_simple");

          void'(seq_simple.randomize() with {
            item.core_req.addr == 'h222;
            item.core_req.valid == '1;
          });

          seq_simple.start(env.core_agent.sequencer);
        end
/*
        begin
          kt_cache_sequence_rw seq_rw = kt_cache_sequence_rw::type_id::create("seq_rw");

          void'(seq_rw.randomize() with {
            core_req.addr == 'h4;
          });

          seq_rw.start(env.cache_agent.sequencer);
        end

        begin
          kt_cache_sequence_random seq_random = kt_cache_sequence_random::type_id::create("seq_random");

          void'(seq_random.randomize() with {
            num_items == 3;
          });  

          seq_random.start(env.cache_agent.sequencer);
        end
        */
        
        begin
          kt_lowx_cache_sequence_simple lowx_seq_simple = kt_lowx_cache_sequence_simple::type_id::create("lowx_seq_simple");

          void'(lowx_seq_simple.randomize() with {
            item.lowx_res.valid == '1;
          });

          lowx_seq_simple.start(env.lowx_agent.sequencer);
        end
      join
   
      fork
        begin
          for(int i = 0; i < 10; i++) begin
            kt_core_cache_sequence_simple seq_simple = kt_core_cache_sequence_simple::type_id::create("seq_simple");

              void'(seq_simple.randomize() with {
                item.core_req.valid == '1;
                item.core_req.ready == '1;
              });

              seq_simple.start(env.core_agent.sequencer);
          end
        end
         begin
           for(int i = 0; i < 10; i++) begin
          kt_lowx_cache_sequence_simple lowx_seq_simple = kt_lowx_cache_sequence_simple::type_id::create("lowx_seq_simple");

          void'(lowx_seq_simple.randomize() with {
            item.lowx_res.valid == '1;
          });

          lowx_seq_simple.start(env.lowx_agent.sequencer);
          end
        end
      join
      `uvm_info("UVM_DEBUG", "end of test", UVM_LOW)
	
      #1000ns;
      phase.drop_objection(this, "TEST_DONE");

    endtask

  endclass

`endif