class c2c_base_seq extends uvm_sequence #(c2c_packet);

  `uvm_object_utils(c2c_base_seq)  // sequences automation

  function new(string name = "c2c_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
`ifdef UVM_VERSION_1_2
    // in UVM1.2, get starting phase from method
    phase = get_starting_phase();
`else
    phase = starting_phase;
`endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
`ifdef UVM_VERSION_1_2
    // in UVM1.2, get starting phase from method
    phase = get_starting_phase();
`else
    phase = starting_phase;
`endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : c2c_base_seq

class c2c_5_packets extends c2c_base_seq;

  `uvm_object_utils(c2c_5_packets)

  function new(string name = "c2c_5_packets");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing c2c_5_packets sequence", UVM_LOW)
    repeat (5) `uvm_do(req)
  endtask

endclass : c2c_5_packets

class c2m_base_seq extends uvm_sequence #(c2m_packet);

  `uvm_object_utils(c2m_base_seq)

  function new(string name = "c2m_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
`ifdef UVM_VERSION_1_2
    phase = get_starting_phase();
`else
    phase = starting_phase;
`endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
`ifdef UVM_VERSION_1_2
    phase = get_starting_phase();
`else
    phase = starting_phase;
`endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : c2m_base_seq

class c2m_5_packets extends c2m_base_seq;

  `uvm_object_utils(c2m_5_packets)

  function new(string name = "c2m_5_packets");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing c2m_5_packets sequence", UVM_LOW)
    repeat (5) `uvm_do(req)
  endtask

endclass : c2m_5_packets
