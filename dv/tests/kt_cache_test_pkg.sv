`ifndef KT_CACHE_TEST_PKG_SV
  `define KT_CACHE_TEST_PKG_SV

	`include "uvm_macros.svh"
	`include "kt_cache_pkg.sv"

	package kt_cache_test_pkg;
		import uvm_pkg::*;
		import kt_cache_pkg::*; // Give access test class on environment package

		`include "kt_cache_test_base.sv"
		`include "kt_cache_test_intr_req_access.sv"

	endpackage

`endif