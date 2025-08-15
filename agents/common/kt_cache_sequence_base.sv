class kt_cache_sequence_base #(type REQ = uvm_sequence_item,
                               type SEQR = uvm_sequencer#(REQ))
  extends uvm_sequence#(REQ);

  `uvm_declare_p_sequencer(SEQR)

  `uvm_object_param_utils(kt_cache_sequence_base#(REQ, SEQR))

  function new(string name = "");
    super.new(name);
  endfunction

endclass
