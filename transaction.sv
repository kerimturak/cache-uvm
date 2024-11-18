// Transaction Classes
// In UVM (Universal Verification Methodology), transactions represent 
// data packets or operations exchanged between different components 
// in a testbench, such as requests and responses. 
// They abstract communication details, making verification reusable and scalable.

class core_cache_trans extends uvm_sequence_item;
    rand icache_req_t cache_req_i;       // Cache request input from the core
    icache_res_t cache_res_o;            // Cache response output to the core
    bit icache_miss_o;                   // Cache miss status flag

    // Constructor
    function new(input string name = "core_cache_trans");
        super.new(name);
    endfunction

    // Macros for UVM field automation
    `uvm_object_utils_begin(core_cache_trans)
        `uvm_field_int(cache_req_i, UVM_DEFAULT)
        `uvm_field_int(cache_res_o, UVM_DEFAULT)
        `uvm_field_int(icache_miss_o, UVM_DEFAULT)
    `uvm_object_utils_end
endclass

class mem_cache_trans extends uvm_sequence_item;
    ilowX_req_t lowX_req_o;              // Low hierarchy request output
    rand ilowX_res_t lowX_res_i;         // Low hierarchy response input

    // Constructor
    function new(input string name = "mem_cache_trans");
        super.new(name);
    endfunction

    // Macros for UVM field automation
    `uvm_object_utils_begin(mem_cache_trans)
        `uvm_field_int(lowX_req_o, UVM_DEFAULT)
        `uvm_field_int(lowX_res_i, UVM_DEFAULT)
    `uvm_object_utils_end
endclass
