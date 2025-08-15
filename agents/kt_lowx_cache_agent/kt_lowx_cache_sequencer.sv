`ifndef KT_LOWX_CACHE_SEQUENCER_SV
  `define KT_LOWX_CACHE_SEQUENCER_SV

class kt_lowx_cache_sequencer extends uvm_sequencer#(.REQ(kt_lowx_cache_item_drv)) implements kt_cache_reset_handler;

  `uvm_component_utils(kt_lowx_cache_sequencer)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void handle_reset(uvm_phase phase);
  	int objection_count;

    stop_sequences();

    objection_count = uvm_test_done.get_objection_count(this);

    if(objection_count > 0) begin
      uvm_test_done.drop_objection(this, $sformatf("Dropping %0d objections at reset", objection_count));
    end

    start_phase_sequence(phase);
  endfunction

  endclass

`endif