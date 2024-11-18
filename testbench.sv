`timescale 1ns / 1ps

import uvm_pkg::*;
import tcore_param::*;

`include "cache_if.sv"
`include "transaction.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "env.sv"
`include "test.sv"

module tb_icache();

  icache_if vif();

  icache i_icache(
    .clk_i(vif.clk_i),
    .rst_ni(vif.rst_ni),
    .cache_req_i(vif.cache_req_i),
    .cache_res_o(vif.cache_res_o),
    .icache_miss_o(vif.icache_miss_o),
    .lowX_res_i(vif.lowX_res_i),
    .lowX_req_o(vif.lowX_req_o)
  );

  initial begin
        // VCD dosyası ayarları
        $dumpfile("dump.vcd"); // VCD dosya adı
        $dumpvars(0, tb_icache); // Testbench içindeki tüm sinyalleri dök

        // UVM test ortamı için virtual interface ayarı
        uvm_config_db #(virtual icache_if)::set(null, "*", "vif", vif);

        // Testi çalıştır
        run_test("test");
  end

  // Saat sinyali üretimi
  initial begin
        vif.clk_i = 0;
        vif.rst_ni = 1; // Reset durumu
        #5 vif.rst_ni = 0; // Reset'i kaldır
        #10000; // Test süresi
        $stop; // Simülasyonu durdur
  end

  // Saat sinyali oluşturma
  always #10 vif.clk_i = ~vif.clk_i;

endmodule
