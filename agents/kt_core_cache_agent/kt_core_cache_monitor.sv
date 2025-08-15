`ifndef KT_CORE_CACHE_MONITOR_SV
  `define KT_CORE_CACHE_MONITOR_SV

class kt_core_cache_monitor extends uvm_monitor implements kt_cache_reset_handler;

  kt_core_cache_agent_config agent_config;

  uvm_analysis_port #(kt_core_cache_item_mon) output_port;

  protected process process_collect_transactions;

  `uvm_component_utils(kt_core_cache_monitor)

      function new(string name = "", uvm_component parent);
        super.new(name, parent);
        output_port = new("output_port", this);
      endfunction

    virtual task wait_reset_end();
      agent_config.wait_reset_end();
    endtask

  	virtual task run_phase(uvm_phase phase);
      forever begin
        fork
          begin
        	wait_reset_end();
           	collect_transactions();

            disable fork;
          end
        join
      end
    endtask

  protected virtual task collect_transaction();
    kt_cache_vif vif = agent_config.get_vif();
    kt_core_cache_item_mon item = kt_core_cache_item_mon::type_id::create("item");

    while(vif.cache_req_i.valid !== 1) begin
      @(posedge vif.clk_i);
      item.prev_item_delay++;
    end

    item.lowX_res_i.ready       =vif.lowX_res_i.ready     ;
    item.core_req_i.valid 		=vif.cache_req_i.valid 		;
    item.core_req_i.ready		=vif.cache_req_i.ready		;
    item.core_req_i.addr  		=vif.cache_req_i.addr  		;
    item.core_req_i.uncached 	=vif.cache_req_i.uncached ;

    @(posedge vif.clk_i);
    item.length++;

 	//Bu kısmı lox agent bağlanınca açmalıyız
    while(vif.cache_res_o.valid !== 1) begin
      @(posedge vif.clk_i);
      item.length++;

      if(agent_config.get_has_checks()) begin
        if(item.length >= agent_config.get_stuck_treshold()) begin
          `uvm_error("PROTOCOL_ERROR", $sformatf("CORE: The cache response time reached the stuck threshold value of %0d", item.length))
        end
      end
    end

    //item.response = kt_cache_response'(vif); // exception için eklenebilir

    output_port.write(item);
    @(posedge vif.clk_i);

    `uvm_info("DEBUG", $sformatf("Monitored item %0s", item.convert2string()), UVM_NONE)

  endtask

  protected virtual task collect_transactions();
    fork
      begin
        process_collect_transactions = process::self();

    	forever begin
      		collect_transaction();
    	end
      end
    join
  endtask

  virtual function void handle_reset(uvm_phase phase);
       if(process_collect_transactions != null) begin
      process_collect_transactions.kill();

      process_collect_transactions = null;
    end

  endfunction

endclass

`endif