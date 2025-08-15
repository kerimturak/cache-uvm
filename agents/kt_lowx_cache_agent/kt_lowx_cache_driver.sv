`ifndef KT_LOWX_CACHE_DRIVER_SV
  `define KT_LOWX_CACHE_DRIVER_SV

class kt_lowx_cache_driver extends uvm_driver#(.REQ(kt_lowx_cache_item_drv)) implements kt_cache_reset_handler;

  kt_lowx_cache_agent_config agent_config;

  protected process process_drive_transactions;

  `uvm_component_utils(kt_lowx_cache_driver)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task wait_reset_end();
    agent_config.wait_reset_end();
  endtask

  virtual task run_phase(uvm_phase phase);
    forever begin
      fork
        begin
        wait_reset_end();
        drive_transactions();
          disable fork;
        end
      join
    end
  endtask

  protected virtual task drive_transaction(kt_lowx_cache_item_drv item);
    kt_cache_vif vif = agent_config.get_vif();

    `uvm_info("DEBUG", $sformatf("Driving lowX \"%0s\": %0s", item.get_full_name(), item.convert2string()), UVM_NONE)

    for(int i = 0; i<item.pre_drive_delay; i++) begin
      @(posedge vif.clk_i);
    end

    while(vif.lowX_req_o.ready !== 1) begin
      @(posedge vif.clk_i);
    end

    vif.lowX_res_i <= item.lowx_res;
    @(posedge vif.clk_i);


    vif.lowX_res_i.ready        <= 1;
    vif.lowX_res_i.valid 		<= 0;
    vif.lowX_res_i.blk      	<= 0;


    for(int i = 0; i<item.post_drive_delay; i++) begin
      @(posedge vif.clk_i);
    end

  endtask

  protected virtual task drive_transactions();
    fork
      begin
        process_drive_transactions = process::self();

    	forever begin
	    	kt_lowx_cache_item_drv item;

    		seq_item_port.get_next_item(item);

    		drive_transaction(item);

    		seq_item_port.item_done();
        end
      end
    join

  endtask

  virtual function void handle_reset(uvm_phase phase);
	kt_cache_vif vif = agent_config.get_vif();

    if(process_drive_transactions != null) begin
      process_drive_transactions.kill();

      process_drive_transactions = null;
    end

    // Initialize the input signals
    vif.lowX_res_i.ready        <= 1;
    vif.lowX_res_i.valid 		<= 0;
    vif.lowX_res_i.blk      	<= 0;
  endfunction

  endclass

`endif