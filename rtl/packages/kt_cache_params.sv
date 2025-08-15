// TCORE RISC-V Processor
// Copyright (c) 2024 Kerim TURAK
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Kerim TURAK - kerimturak@hotmail.com                       //
//                                                                            //
// Additional contributions by:                                               //
//                 --                                                         //
//                                                                            //
// Design Name:    tcore_param                                                //
// Project Name:   TCORE                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    tcore_param                                                //
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
package kt_cache_params;
  localparam XLEN = 32;
  localparam BLK_SIZE = 128;

  localparam IC_WAY = 4;
  localparam DC_WAY = 8;
  localparam IC_CAPACITY = 512 * 8; //8 * (2 ** 10) * 8;
  localparam DC_CAPACITY = 8 * (2 ** 10) * 8;
  localparam BUFFER_CAPACITY = 8 * BLK_SIZE;

  typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] r2_addr;
    logic [4:0] r1_addr;
    logic [2:0] funct3;
    logic [4:0] rd_addr;
    logic [6:0] opcode;
  } inst_t;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
  } icache_req_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic                miss;
    logic [BLK_SIZE-1:0] blk;
  } icache_res_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [BLK_SIZE-1:0] blk;
  } ilowX_res_t;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
  } ilowX_req_t;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
    logic            rw;
    logic [1:0]      rw_size;
    logic [31:0]     data;
  } dcache_req_t;

  typedef struct packed {
    logic        valid;
    logic        miss;
    logic        ready;
    logic [31:0] data;
  } dcache_res_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [BLK_SIZE-1:0] data;
  } dlowX_res_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [XLEN-1:0]     addr;
    logic [1:0]          rw_size;
    logic                rw;
    logic [BLK_SIZE-1:0] data;
    logic                uncached;
  } dlowX_req_t;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
  } cache_req_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [BLK_SIZE-1:0] blk;
  } cache_res_t;

  typedef struct packed {
    logic                valid;
    logic                ready;
    logic [BLK_SIZE-1:0] blk;
  } lowX_res_t;

  typedef struct packed {
    logic            valid;
    logic            ready;
    logic [XLEN-1:0] addr;
    logic            uncached;
  } lowX_req_t;


  typedef struct packed {
    logic                 valid;
    logic                 ready;
    logic [15:0]          rw;
    logic [XLEN-1:0]      addr;
    logic [BLK_SIZE -1:0] data;
  } iomem_req_t;


  typedef struct packed {
    logic                 valid;
    logic                 ready;
    logic [BLK_SIZE -1:0] data;
  } iomem_res_t;

endpackage