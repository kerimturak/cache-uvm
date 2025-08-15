#!/bin/bash
# create_lowrisc_env.sh
# LowRISC UVM klasör yapısı oluşturma scripti

# Ana dizinler
mkdir -p agents/kt_core_cache_agent/seq_lib
mkdir -p agents/kt_lowx_cache_agent/seq_lib

mkdir -p dv/env/seq_lib
mkdir -p dv/tests
mkdir -p dv/tb
mkdir -p rtl

echo "Klasör yapısı oluşturuldu:"
tree agents dv rtl
