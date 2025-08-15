// Environmnet package
`ifndef KT_CACHE_PKG_SV
  `define KT_CACHE_PKG_SV

	`include "uvm_macros.svh"

	`include "kt_cache_if.sv"

	package kt_cache_pkg;
		import uvm_pkg::*;

		`include "kt_cache_types.sv"
		`include "kt_cache_reset_handler.sv"
		`include "kt_cache_item_base.sv"
		`include "kt_core_cache_item_drv.sv"
		`include "kt_core_cache_item_mon.sv"
		`include "kt_core_cache_agent_config.sv"
		`include "kt_core_cache_sequencer.sv"
		`include "kt_core_cache_driver.sv"
		`include "kt_core_cache_monitor.sv"
		`include "kt_core_cache_coverage.sv"
		`include "kt_core_cache_agent.sv"

		`include "kt_cache_sequence_base.sv"
		`include "kt_core_cache_sequence_simple.sv"
		`include "kt_core_cache_sequence_rw.sv"
		`include "kt_core_cache_sequence_random.sv"

		`include "kt_lowx_cache_item_drv.sv"
		`include "kt_lowx_cache_item_mon.sv"
		`include "kt_lowx_cache_agent_config.sv"
		`include "kt_lowx_cache_sequencer.sv"
		`include "kt_lowx_cache_driver.sv"
		`include "kt_lowx_cache_monitor.sv"
		`include "kt_lowx_cache_agent.sv"

		`include "kt_lowx_cache_sequence_simple.sv"
		`include "kt_lowx_cache_sequence_rw.sv"
		`include "kt_lowx_cache_sequence_random.sv"

		`include "kt_cache_env.sv"


	endpackage

`endif