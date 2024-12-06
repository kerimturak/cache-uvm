class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)

  uvm_analysis_port #(c2c_packet) c2c_mon;
  uvm_analysis_port #(c2m_packet) c2m_mon;

  c2c_packet c2c_transaction;
  c2m_packet c2m_transaction;

  int cache_count;
  int lowX_count;

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    cache_count = 0;
    lowX_count = 0;
    c2c_mon = new("c2c_mon", this);
    c2m_mon = new("c2m_mon", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    c2c_transaction = c2c_packet::type_id::create("c2c_transaction");
    c2m_transaction = c2m_packet::type_id::create("c2m_transaction");
  endfunction

  virtual function void write_cache_transaction(c2c_packet tc);
    c2c_transaction = tc;
    cache_count++;
    if (tc.icache_miss) begin
      `uvm_info("SCOREBOARD", "Cache Miss Detected", UVM_HIGH);
    end else begin
      `uvm_info("SCOREBOARD", "Cache Hit Detected", UVM_HIGH);
    end
  endfunction

  virtual function void write_lowX_transaction(c2m_packet tc);
    c2m_transaction = tc;
    lowX_count++;
  endfunction

  virtual function void report_results();
    `uvm_info("SCOREBOARD", $sformatf("Total Cache Transactions: %0d", cache_count), UVM_HIGH);
    `uvm_info("SCOREBOARD", $sformatf("Total LowX Transactions: %0d", lowX_count), UVM_HIGH);
  endfunction

endclass
