`ifndef KT_LOWX_CACHE_MONITOR_SV
  `define KT_LOWX_CACHE_MONITOR_SV

class kt_lowx_cache_monitor extends uvm_monitor implements kt_cache_reset_handler;

  kt_lowx_cache_agent_config agent_config;

  uvm_analysis_port #(kt_lowx_cache_item_mon) output_port;

  protected process process_collect_transactions;

  `uvm_component_utils(kt_lowx_cache_monitor)

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
    kt_lowx_cache_item_mon item = kt_lowx_cache_item_mon::type_id::create("item");

    while(vif.lowX_res_i.valid !== 1) begin
      @(posedge vif.clk_i);
      item.prev_item_delay++;
    end

    item.lowX_res_i.ready       =vif.lowX_res_i.ready     ;
    item.lowX_res_i.valid 		=vif.lowX_res_i.valid 		;
    item.lowX_res_i.blk      	=vif.lowX_res_i.blk ;

    @(posedge vif.clk_i);
    item.length++;

// Bu kısmı lox agent bağlanınca açmalıyız
    while(vif.cache_res_o.valid !== 0) begin // or lowx_req_o.valid
      @(posedge vif.clk_i);
      item.length++;

      if(agent_config.get_has_checks()) begin
        if(item.length >= agent_config.get_stuck_treshold()) begin
          `uvm_error("PROTOCOL_ERROR", $sformatf("LOWX: The cache response time reached the stuck threshold value of %0d", item.length))
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