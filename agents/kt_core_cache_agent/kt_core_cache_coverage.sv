`ifndef KT_CORE_CACHE_COVERAGE_SV
  `define KT_CORE_CACHE_COVERAGE_SV

// This declaration is necessary to implement the analysis port's write function.
`uvm_analysis_imp_decl(_item)

virtual class kt_core_cache_cover_index_wrapper_base extends uvm_component;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Function used to sample the information
  pure virtual function void sample (int unsigned value);

  // Function to print the coverage information.
  pure virtual function string coverage2string();

endclass


class kt_core_cache_cover_index_wrapper #(
    int unsigned MAX_VALUE_PLUS_1 = 16
) extends kt_core_cache_cover_index_wrapper_base;

  `uvm_component_param_utils(kt_core_cache_cover_index_wrapper#(MAX_VALUE_PLUS_1))

  covergroup cover_index with function sample (int unsigned value);
    option.per_instance = 1;
    index: coverpoint value {
      option.comment = "Index";
      bins values[MAX_VALUE_PLUS_1] = {[0 : MAX_VALUE_PLUS_1 - 1]};
    }
  endgroup

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    cover_index = new();
    cover_index.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_index"));
  endfunction

  virtual function string coverage2string();
    string result = $sformatf("\n   cover_index: %03.2f%%", cover_index.get_inst_coverage());
    return result;
  endfunction

      //Function used to sample the information
    virtual function void sample(int unsigned value);
      cover_index.sample(value);
    endfunction
endclass


class kt_core_cache_coverage extends uvm_component;

  // Pointer to the agent configuration object to access settings
  kt_core_cache_agent_config agent_config;

  // Analysis port to receive transactions from the monitor
  uvm_analysis_imp_item #(kt_core_cache_item_mon, kt_core_cache_coverage) item_port;

  kt_core_cache_cover_index_wrapper #(32) wrap_cover_addr_0;
  kt_core_cache_cover_index_wrapper #(32) wrap_cover_addr_1;

  `uvm_component_utils(kt_core_cache_coverage)

  // Covergroup to collect coverage data
  covergroup cover_item with function sample (kt_core_cache_item_mon item);
    option.per_instance = 1;

    uncached_cp: coverpoint item.core_req_i.uncached {
      option.comment = "Uncached access";
      bins uncached_bin = {1};
      bins cached_bin   = {0};
    }

    response_length_cp: coverpoint item.length {
      bins low_latency   = {2};
      bins medium_latency= {[3 : 10]};
      bins high_latency  = {[11 : 100]};
      bins stuck_latency = {[101 : $]};
    }

    prev_item_delay_cp: coverpoint item.prev_item_delay {
      bins back_to_back = {0};
      bins small_delay  = {[1 : 5]};
      bins large_delay  = {[6 : $]};
    }

    lowx_response_valid_cp: coverpoint item.lowX_res_i.valid {
      bins valid_bin   = {1};
      bins invalid_bin = {0};
    }

    uncached_x_length_cp : cross uncached_cp, response_length_cp;

  endgroup

    covergroup cover_reset with function sample(bit req_at_reset);
  option.per_instance = 1;

  access_ongoing : coverpoint req_at_reset {
    option.comment = "A cache request was ongoing at reset";
    bins idle = {0};
    bins active = {1};
  }
endgroup

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    item_port = new("item_port", this);

    cover_item = new();
    cover_item.set_inst_name($sformatf("%s_cover_item", get_full_name()));

    cover_reset = new();
    over_reset.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_reset"));
  endfunction

  virtual function void write_item(kt_core_cache_item_mon item);
    cover_item.sample(item);
    `uvm_info("COVERAGE",
              $sformatf("Sampled cache item. Length: %0d, Uncached: %0d",
                         item.length, item.core_req_i.uncached),
              UVM_LOW)
    `uvm_info("DEBUG",
              $sformatf("Coverage: %0s", coverage2string()),
              UVM_NONE)

    for (int i = 0; i < 32; i++) begin
      if (item.core_req_i.addr[i])
        wrap_cover_addr_1.sample(i);
      else
        wrap_cover_addr_0.sample(i);
    end
  endfunction

  virtual function string coverage2string();
    string result = $sformatf("\n   cover_item: %03.2f%%",
                              cover_item.get_inst_coverage());
    uvm_component children[$];
    get_children(children);

    foreach (children[idx]) begin
      kt_core_cache_cover_index_wrapper_base wrapper;
      if ($cast(wrapper, children[idx])) begin
        result = { result,
                   $sformatf("\n\nChild component: %0s%0s",
                             wrapper.get_name(),
                             wrapper.coverage2string()) };
      end
    end

    return result;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wrap_cover_addr_0 = kt_core_cache_cover_index_wrapper #(32)::type_id::create("wrap_cover_addr_0", this);
    wrap_cover_addr_1 = kt_core_cache_cover_index_wrapper #(32)::type_id::create("wrap_cover_addr_1", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    kt_cache_vif vif = agent_config.get_vif(); // Ortamdan VIF al

    forever begin
      @(negedge vif.rst_ni); // aktif-low reset düşerken sample
      cover_reset.sample(vif.cache_req_i.valid);
    end
  endtask

endclass

`endif
