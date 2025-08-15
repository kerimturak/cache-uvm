`ifndef  KT_CACHE_SV
  `define KT_CACHE_SV
`timescale 1ns / 1ps

// kt_cache modülü: Hem komut (icache) hem de veri (dcache) önbelleği olarak çalışabilir.
module kt_cache
  import kt_cache_params::*;
#(
    // Modülün icache mi (1) yoksa dcache mi (0) olduğunu belirleyen parametre.
    parameter      IS_ICACHE   = 1,
    // Gelen istek ve giden cevap tipleri.
    parameter type cache_req_t = logic,
    parameter type cache_res_t = logic,
    // Alt bellekten (lowX) gelen cevap ve giden istek tipleri.
    parameter type lowX_res_t  = logic,
    parameter type lowX_req_t  = logic,
    // Önbellek boyutu, blok boyutu ve yol sayısı gibi parametreler.
    parameter      CACHE_SIZE  = 1024,
    parameter      BLK_SIZE    = kt_cache_params::BLK_SIZE,
    parameter      XLEN        = kt_cache_params::XLEN,
    parameter      NUM_WAY     = 4
) (
    input  logic       clk_i,          // Saat sinyali.
    input  logic       rst_ni,         // Asenkron reset (aktif-düşük).
    input  logic       flush_i,        // Temizleme isteği.
    input  cache_req_t cache_req_i,    // Önbellek isteği.
    output cache_res_t cache_res_o,    // Önbellek cevabı.
    input  lowX_res_t  lowX_res_i,     // Alt bellekten gelen cevap.
    output lowX_req_t  lowX_req_o      // Alt belleğe giden istek.
);

  // COMMON SIGNALS & Parameters (Ortak Sinyaller ve Parametreler)
  // Önbellek boyutu, yol sayısı ve blok boyutu kullanılarak set sayısını hesaplar.
  localparam NUM_SET = (CACHE_SIZE / BLK_SIZE) / NUM_WAY;
  // Set index'i için gerekli bit sayısını hesaplar.
  localparam IDX_WIDTH = $clog2(NUM_SET) == 0 ? 1 : $clog2(NUM_SET);
  // Bayt ofseti (byte offset) için gerekli bit sayısını hesaplar.
  localparam BOFFSET = $clog2(BLK_SIZE / 8);
  // Kelime ofseti (word offset) için gerekli bit sayısını hesaplar.
  localparam WOFFSET = $clog2(BLK_SIZE / 32);
  // Tag (etiket) boyutu için gerekli bit sayısını hesaplar.
  localparam TAG_SIZE = XLEN - IDX_WIDTH - BOFFSET;

  // Common registers and wires (Ortak register'lar ve kablolar)
  // Temizleme işleminin devam ettiğini gösteren bayrak.
  logic                       flush;
  // Temizleme sırasında hangi set'in işlendiğini tutan index.
  logic       [IDX_WIDTH-1:0] flush_index;
  // Gelen önbellek isteğini bir döngü gecikmeli tutan register.
  cache_req_t                 cache_req_q;
  // Okuma işlemi için set index'i.
  logic       [IDX_WIDTH-1:0] rd_idx;
  // Yazma işlemi için set index'i.
  logic       [IDX_WIDTH-1:0] wr_idx;
  // Memory'ye erişim için kullanılan nihai index.
  logic       [IDX_WIDTH-1:0] cache_idx;
  // Önbellek miss (isabetsizlik) durumu.
  logic                       cache_miss;
  // Önbellek hit (isabet) durumu.
  logic                       cache_hit;
  // PLRU (Pseudo-Least Recently Used) algoritması için güncellenen node değeri.
  logic       [  NUM_WAY-2:0] updated_node;
  // Her bir yolun geçerli (valid) olup olmadığını gösteren vektör.
  logic       [  NUM_WAY-1:0] cache_valid_vec;
  // Her bir yolda isabet olup olmadığını gösteren vektör.
  logic       [  NUM_WAY-1:0] cache_hit_vec;
  // PLRU algoritmasına göre dışarı atılacak (evict) yol.
  logic       [  NUM_WAY-1:0] evict_way;
  // Önbellekten okunan seçilen veri bloğu.
  logic       [ BLK_SIZE-1:0] cache_select_data;
  // Önbelleğe yazılacak verinin hangi yola yazılacağını belirten vektör.
  logic       [  NUM_WAY-1:0] cache_wr_way;
  // Önbellek yazma etkinleştirme sinyali.
  logic                       cache_wr_en;
  // Alt belleğe yapılan isteğin kabul edildiğini gösteren sinyal.
  logic                       lookup_ack;

  // Shared memory structures (Ortak bellek yapıları)
  // Veri SRAM'i için kullanılan struct.
  typedef struct packed {
    logic [IDX_WIDTH-1:0]             idx;
    logic [NUM_WAY-1:0]               way;
    logic [BLK_SIZE-1:0]              wdata;
    logic [NUM_WAY-1:0][BLK_SIZE-1:0] rdata;
  } dsram_t;

  // Etiket (tag) SRAM'i için kullanılan struct.
  typedef struct packed {
    logic [IDX_WIDTH-1:0]           idx;
    logic [NUM_WAY-1:0]             way;
    logic [TAG_SIZE:0]              wtag;
    logic [NUM_WAY-1:0][TAG_SIZE:0] rtag;
  } tsram_t;

  // PLRU node SRAM'i için kullanılan struct.
  typedef struct packed {
    logic [IDX_WIDTH-1:0] idx;
    logic                 rw_en;
    logic [NUM_WAY-2:0]   wnode;
    logic [NUM_WAY-2:0]   rnode;
  } nsram_t;

  dsram_t dsram;
  tsram_t tsram;
  nsram_t nsram;

  // Dcache için kirli (dirty) bit SRAM'i.
  typedef struct packed {
    logic [IDX_WIDTH-1:0] idx;
    logic [NUM_WAY-1:0]   way;
    logic                 rw_en;
    logic                 wdirty;
    logic [NUM_WAY-1:0]   rdirty;
  } drsram_t;

  drsram_t                drsram;

  // Additional wires for dcache writeback, mask data, etc. (Dcache'e özel ek sinyaller)
  // Yazma işlemi sırasında veriyi maskelemek için kullanılır.
  logic    [BLK_SIZE-1:0] mask_data;
  // Veri SRAM'ine yazma etkinleştirme sinyali.
  logic                   data_array_wr_en;
  // Veri yazmadan önce ön hazırlık (maskeleme) için kullanılır.
  logic    [BLK_SIZE-1:0] data_wr_pre;
  // Tag SRAM'ine yazma etkinleştirme sinyali.
  logic                   tag_array_wr_en;
  // Kelime ofseti için kullanılır.
  logic    [ WOFFSET-1:0] word_idx;
  // Alt belleğe geri yazma (write-back) işlemi durumu.
  logic                   write_back;
  // Dışarı atılacak bloğun tag'i.
  logic    [TAG_SIZE-1:0] evict_tag;
  // Dışarı atılacak bloğun verisi.
  logic    [BLK_SIZE-1:0] evict_data;

  // Common non-memory logic (Bellek dışı ortak mantık)
  // cache_req_q register'ının yönetimi.
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      cache_req_q <= '0; // Reset'te isteği sıfırla.
    end else if (flush) begin
      // Temizleme devam ediyorsa, tüm istekleri sıfırla.
      cache_req_q <= '0;
    end else begin
      // Yeni bir isteği almaya hazır olduğumuzda veya bir cache miss durumu çözüldüğünde
      if ((cache_res_o.ready && cache_res_o.valid) || (!cache_req_q.valid)) begin
        cache_req_q <= cache_req_i.ready ? cache_req_i : '0;
      end
      // Aksi halde (işlem devam ederken), mevcut isteği koru.
      else begin
        cache_req_q <= cache_req_q;
      end
    end
  end

  // Flush işleminin yönetimi.
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      flush_index <= '0; // Reset'te index'i sıfırla.
      flush       <= 1'b1; // Reset'te temizleme işlemini başlat.
    end else if (flush) begin
      // Temizleme işlemi devam ederken
      if (flush_index == NUM_SET - 1) begin
        // Son sete ulaşıldı, temizleme bitti.
        flush_index <= '0;
        flush       <= 1'b0;
      end else begin
        // Bir sonraki seti temizle.
        flush_index <= flush_index + 1'b1;
      end
    end else begin
      // Temizleme aktif değilken, flush_i ile yeni bir temizleme isteği başlat.
      flush_index <= '0;
      flush       <= flush_i;
    end
  end

  // Memory instantiation (Bellek örneklendirme): Veri ve tag dizileri
  // Her bir yol için ayrı bir Veri SRAM'i örneği oluşturulur.
  for (genvar i = 0; i < NUM_WAY; i++) begin : data_array
    sp_bram #(
        .DATA_WIDTH(BLK_SIZE),
        .NUM_SETS  (NUM_SET)
    ) data_array (
        .clk    (clk_i),
        .chip_en(1'b1),
        .addr   (dsram.idx),
        .wr_en  (dsram.way[i]),
        .wr_data(dsram.wdata),
        .rd_data(dsram.rdata[i])
    );
  end

  // Her bir yol için ayrı bir Etiket (Tag) SRAM'i örneği oluşturulur.
  for (genvar i = 0; i < NUM_WAY; i++) begin : tag_array
    sp_bram #(
        .DATA_WIDTH(TAG_SIZE + 1), // Tag ve valid bitini içerir.
        .NUM_SETS  (NUM_SET)
    ) tag_array (
        .clk    (clk_i),
        .chip_en(1'b1),
        .addr   (tsram.idx),
        .wr_en  (tsram.way[i]),
        .wr_data(tsram.wtag),
        .rd_data(tsram.rtag[i])
    );
  end

  // PLRU node'larını tutmak için SRAM örneği.
  sp_bram #(
      .DATA_WIDTH(NUM_WAY - 1),
      .NUM_SETS  (NUM_SET)
  ) node_array (
      .clk    (clk_i),
      .chip_en(1'b1),
      .addr   (nsram.idx),
      .wr_en  (nsram.rw_en),
      .wr_data(nsram.wnode),
      .rd_data(nsram.rnode)
  );

  // PLRU functions (PLRU fonksiyonları)
  // Her zaman çalışan bir always bloğu.
  always_comb begin
    // PLRU node'unu hit durumuna göre güncelle.
    updated_node = update_node(nsram.rnode, cache_hit_vec);
    // PLRU node'una göre dışarı atılacak yolu belirle.
    evict_way    = compute_evict_way(nsram.rnode);
  end

  // Common tag and data selection logic (Ortak tag ve veri seçimi mantığı)
  always_comb begin
    // Her bir yol için döngü.
    for (int i = 0; i < NUM_WAY; i++) begin
      // Tag SRAM'inden valid bitini oku.
      cache_valid_vec[i] = tsram.rtag[i][TAG_SIZE];
      // Okunan tag ile gelen adresin tag kısmını karşılaştır.
      cache_hit_vec[i]   = tsram.rtag[i][TAG_SIZE-1:0] == cache_req_q.addr[XLEN-1:IDX_WIDTH+BOFFSET];
    end

    // Seçilecek veriyi varsayılan olarak sıfırla.
    cache_select_data = '0;
    // Hit olan yoldaki veriyi seç.
    for (int i = 0; i < NUM_WAY; i++) begin
      if (cache_hit_vec[i]) cache_select_data = dsram.rdata[i];
    end

    // cache miss ve hit durumlarını belirle.
    cache_miss = cache_req_q.valid && !flush && !(|(cache_valid_vec & cache_hit_vec));
    cache_hit = cache_req_q.valid && !flush && (|(cache_valid_vec & cache_hit_vec));

    // Okuma ve yazma indexlerini belirle.
    rd_idx = cache_req_i.addr[IDX_WIDTH+BOFFSET-1:BOFFSET];
    wr_idx = flush ? flush_index : (cache_miss ? cache_req_q.addr[IDX_WIDTH+BOFFSET-1:BOFFSET] : rd_idx);

    // Yazma etkinleştirme sinyalini belirle.
    cache_wr_en = (cache_miss && lowX_res_i.valid && !cache_req_q.uncached) || flush;
    // Bellek erişimi için nihai index'i seç.
    cache_idx = cache_wr_en ? wr_idx : rd_idx;

    // Yazma yapılacak yolu belirle: Hit durumunda ilgili yolu, miss durumunda atılacak yolu kullan.
    cache_wr_way = cache_hit ? cache_hit_vec : evict_way;
  end

  // Generate block: i-cache ve d-cache farklılıkları
  if (IS_ICACHE) begin : icache_impl
    // i-cache (komut önbelleği) mantığı
    always_comb begin
      // nsram'e yazma etkinleştirme ve node değerini belirle.
      nsram.rw_en = cache_wr_en || cache_hit;
      nsram.wnode = flush ? '0 : updated_node;
      nsram.idx   = cache_idx;

      // tsram'e yazma mantığı.
      tsram.way   = '0;
      tsram.idx   = cache_idx;
      tsram.wtag  = flush ? '0 : {1'b1, cache_req_q.addr[XLEN-1 : IDX_WIDTH+BOFFSET]};
      for (int i = 0; i < NUM_WAY; i++) tsram.way[i] = flush ? '1 : cache_wr_way[i] && cache_wr_en;

      // dsram'e yazma mantığı.
      dsram.way   = '0;
      dsram.idx   = cache_idx;
      dsram.wdata = lowX_res_i.blk;
      for (int i = 0; i < NUM_WAY; i++) dsram.way[i] = cache_wr_way[i] && cache_wr_en;
    end

    // i-cache için alt bellek isteği ve önbellek cevabı.
    always_comb begin
      // Alt bellek isteğinin geçerli olduğu durumlar.
      lowX_req_o.valid    = !lookup_ack && cache_miss;
      lowX_req_o.ready    = !flush && cache_miss;
      lowX_req_o.addr     = cache_req_q.addr;
      lowX_req_o.uncached = cache_req_q.uncached;
      // Önbellek cevabının geçerli olduğu durumlar.
      cache_res_o.miss    = cache_miss;
      cache_res_o.valid   = cache_req_i.ready && (cache_hit || (cache_miss && lowX_req_o.ready && lowX_res_i.valid));
      cache_res_o.ready   = (!cache_miss || lowX_res_i.valid) && !flush;
      // Önbellek cevabı olarak verinin seçilmesi.
      cache_res_o.blk     = (cache_miss && lowX_res_i.valid) ? lowX_res_i.blk : cache_select_data;
    end

  end else begin : dcache_impl
    // d-cache (veri önbelleği) mantığı
    // Kirli (dirty) bitleri tutmak için SRAM örneği.
    for (genvar i = 0; i < NUM_WAY; i++) begin : dirty_array
      sp_bram #(
          .DATA_WIDTH(1),
          .NUM_SETS  (NUM_SET)
      ) dirty_array (
          .clk    (clk_i),
          .chip_en(1'b1),
          .addr   (drsram.idx),
          .wr_en  (drsram.way[i]),
          .wr_data(drsram.wdirty),
          .rd_data(drsram.rdirty[i])
      );
    end

    // d-cache için ek mantık: veri maskeleme, geri yazma (writeback) vs.
    always_comb begin
      // Veri yazma öncesinde maskeleme işlemi.
      mask_data   = cache_hit ? cache_select_data : lowX_res_i.data;
      data_wr_pre = mask_data;
      // Gelen rw_size'a göre maskeleme ve veri yazma.
      case (cache_req_q.rw_size)
        2'b11: data_wr_pre[cache_req_i.addr[BOFFSET-1:2]*32+:32] = cache_req_q.data;
        2'b10: data_wr_pre[cache_req_i.addr[BOFFSET-1:1]*16+:16] = cache_req_q.data;
        2'b01: data_wr_pre[cache_req_i.addr[BOFFSET-1:0]*8+:8] = cache_req_q.data;
        2'b00: data_wr_pre = '0;
      endcase

      word_idx = cache_req_i.addr[(WOFFSET+2)-1:2];
      // Geri yazma (write-back) durumunu belirle: miss ve kirli blok varsa.
      write_back = cache_miss && (|(drsram.rdirty & evict_way & cache_valid_vec));

      // Veri ve tag SRAM'lerine yazma etkinleştirme sinyallerini belirle.
      data_array_wr_en = ((cache_hit && cache_req_q.rw) ||
           (cache_miss && lowX_res_i.valid && !cache_req_q.uncached)) && !write_back;
      tag_array_wr_en = (cache_miss && lowX_res_i.valid && !cache_req_q.uncached) && !write_back;

      // dcache'e özgü belleklerin güncellenmesi.
      drsram.wdirty = flush ? '0 : (write_back ? '0 : (cache_req_q.rw ? '1 : '0));
      drsram.rw_en  = (cache_req_q.rw && (cache_hit || (cache_miss && lowX_res_i.valid))) ||
                        (write_back && lowX_res_i.valid);
      drsram.idx    = cache_idx;
      for (int i = 0; i < NUM_WAY; i++) drsram.way[i] = flush ? '1 : (cache_wr_way[i] && drsram.rw_en) || flush;

      nsram.rw_en = flush || data_array_wr_en;
      nsram.wnode = flush ? '0 : updated_node;
      nsram.idx   = cache_idx;

      tsram.way   = '0;
      tsram.idx   = cache_idx;
      tsram.wtag  = flush ? '0 : {1'b1, cache_req_q.addr[XLEN-1:IDX_WIDTH+BOFFSET]};
      for (int i = 0; i < NUM_WAY; i++) tsram.way[i] = flush ? '1 : (cache_wr_way[i] && tag_array_wr_en);

      dsram.way   = '0;
      dsram.idx   = cache_idx;
      dsram.wdata = cache_req_q.rw ? data_wr_pre : lowX_res_i.data;
      for (int i = 0; i < NUM_WAY; i++) dsram.way[i] = cache_wr_way[i] && data_array_wr_en;

      // Atılacak (evict) bloğun tag ve verisini al.
      evict_tag  = '0;
      evict_data = '0;
      for (int i = 0; i < NUM_WAY; i++) begin
        if (evict_way[i]) begin
          evict_tag  = tsram.rtag[i][TAG_SIZE-1:0];
          evict_data = dsram.rdata[i];
        end
      end
    end

    // d-cache için alt bellek isteği ve önbellek cevabı.
    always_comb begin
      // Alt bellek isteği mantığı.
      lowX_req_o.valid = !lookup_ack && cache_miss;
      lowX_req_o.ready = !flush && cache_miss;
      lowX_req_o.uncached = write_back ? '0 : cache_req_q.uncached;
      // Adres seçimi: write-back yapılıyorsa evict adresi, yoksa gelen adres.
      lowX_req_o.addr = write_back ? {evict_tag, rd_idx, {BOFFSET{1'b0}}} : {cache_req_q.addr[31:BOFFSET], {BOFFSET{1'b0}}};
      // İşlem türü: write-back ise yazma, yoksa okuma.
      lowX_req_o.rw = write_back ? '1 : '0;
      lowX_req_o.rw_size = write_back ? 2'b11 : cache_req_q.rw_size;
      // Veri seçimi: write-back ise evict verisi, yoksa '0'.
      lowX_req_o.data = write_back ? evict_data : '0;

      // Önbellek cevap sinyalleri.
      cache_res_o.valid   = !cache_req_q.rw ? (!write_back && cache_req_q.valid &&
                              (cache_hit || (cache_miss && lowX_req_o.ready && lowX_res_i.valid))) :
                              (!write_back && cache_req_q.valid && cache_req_i.ready &&
                              (cache_hit || (cache_miss && lowX_req_o.ready && lowX_res_i.valid)));
      cache_res_o.ready   = !cache_req_q.rw ? (!write_back && (!cache_miss || lowX_res_i.valid) && !flush && !tag_array_wr_en) :
                              (!write_back && !tag_array_wr_en && lowX_req_o.ready &&
                              lowX_res_i.valid && !flush);
      cache_res_o.miss = cache_miss;
      // Cevap verisi.
      cache_res_o.data = (cache_miss && lowX_res_i.valid) ? lowX_res_i.data[word_idx*32+:32] : cache_select_data[word_idx*32+:32];
    end
  end

  // Final lookup_ack logic (Son lookup_ack mantığı)
  // lookup_ack sinyali, alt bellekten gelen cevabın işlenip işlenmediğini izler.
  always_ff @(posedge clk_i) begin
    if (!rst_ni || flush) begin
      lookup_ack <= '0;
    end else begin
      lookup_ack <= lowX_res_i.valid ? !lowX_req_o.ready : (!lookup_ack ? lowX_req_o.valid && lowX_res_i.ready : lookup_ack);
    end
  end

  // Fonksiyon: PLRU node güncellemesi
  // Bir isabet (hit) durumunda PLRU ağacındaki ilgili node'ları günceller.
  function automatic [NUM_WAY-2:0] update_node(input logic [NUM_WAY-2:0] node_in, input logic [NUM_WAY-1:0] hit_vec);
    logic [NUM_WAY-2:0] node_tmp;
    int idx_base, shift;
    node_tmp = node_in;
    for (int unsigned i = 0; i < NUM_WAY; i++) begin
      if (hit_vec[i]) begin
        for (int unsigned lvl = 0; lvl < $clog2(NUM_WAY); lvl++) begin
          idx_base = (2 ** lvl) - 1;
          shift = $clog2(NUM_WAY) - lvl;
          // Güncelleme: ilgili bit, en az kullanılan yolu temsil edecek şekilde tersleniyor.
          node_tmp[idx_base+(i>>shift)] = ~((i >> (shift - 1)) & 1'b1);
        end
      end
    end
    return node_tmp;
  endfunction

  // Fonksiyon: PLRU evict_way belirleme
  // PLRU ağacına göre dışarı atılacak (evict) yolu belirler.
  function automatic [NUM_WAY-1:0] compute_evict_way(input logic [NUM_WAY-2:0] node_in);
    logic [NUM_WAY-1:0] way;
    int idx_base, shift;
    for (int unsigned i = 0; i < NUM_WAY; i++) begin
      logic en;
      en = 1'b1;
      for (int unsigned lvl = 0; lvl < $clog2(NUM_WAY); lvl++) begin
        idx_base = (2 ** lvl) - 1;
        shift = $clog2(NUM_WAY) - lvl;
        if (((i >> (shift - 1)) & 1'b1) == 1'b1) en &= node_in[idx_base+(i>>shift)];
        else en &= ~node_in[idx_base+(i>>shift)];
      end
      way[i] = en;
    end
    return way;
  endfunction

endmodule
`endif