# Makefile for QuestaSim & Xcelium (UVM environment)

# ------------------------------
# Tool selection
# ------------------------------
TOOL ?= questa  # veya xcelium

# ------------------------------
# Directories
# ------------------------------
AGENTS_DIR   = agents
ENV_DIR      = dv/env
TESTS_DIR    = dv/tests
TB_DIR       = dv/tb
RTL_DIR      = rtl

# ------------------------------
# Source files
# ------------------------------
# RTL
RTL_SV = $(RTL_DIR)/packages/*.sv \
         $(RTL_DIR)/design.sv \
         $(RTL_DIR)/kt_cache.sv \
         $(RTL_DIR)/sp_bram.sv

# Agents
COMMON_AGENT_SV = $(AGENTS_DIR)/common/*.sv
CORE_AGENT_SV   = $(AGENTS_DIR)/kt_core_cache_agent/*.sv $(AGENTS_DIR)/kt_core_cache_agent/seq_lib/*.sv
LOWX_AGENT_SV   = $(AGENTS_DIR)/kt_lowx_cache_agent/*.sv $(AGENTS_DIR)/kt_lowx_cache_agent/seq_lib/*.sv

# Environment
ENV_SV = $(ENV_DIR)/*.sv $(ENV_DIR)/seq_lib/*.sv

# Testbench
TB_SV = $(TB_DIR)/*.sv

# Tests
TEST_SV = $(TESTS_DIR)/*.sv

# All sources
ALL_SV = $(RTL_SV) $(COMMON_AGENT_SV) $(CORE_AGENT_SV) $(LOWX_AGENT_SV) $(ENV_SV) $(TB_SV) $(TEST_SV)

# Top-level testbench
TOP_TB = testbench

# ------------------------------
# QuestaSim targets
# ------------------------------
.PHONY: all clean compile elaborate run sim

all: sim

# Compile stage
compile:
ifeq ($(TOOL),questa)
	@echo "=== Compiling sources with QuestaSim ==="
	if [ ! -d work ]; then \
		vlib work; vmap work work; \
	fi
	vlog -sv $(ALL_SV)
endif

# Elaboration stage
elaborate:
ifeq ($(TOOL),questa)
	@echo "=== Elaborating design ==="
	vsim -c -do "elaborate $(TOP_TB); quit"
endif

# Run stage
run:
ifeq ($(TOOL),questa)
	@echo "=== Running simulation ==="
	vsim -c -do "run -all; quit" $(TOP_TB)
endif

# Combined sim: compile → elaborate → run
sim: compile elaborate run

clean:
	@echo "Cleaning simulation files..."
ifeq ($(TOOL),questa)
	rm -rf work transcript vsim.wlf csrc
endif
ifeq ($(TOOL),xcelium)
	rm -rf csrc xcelium.d simv.daidir waves.shm waves.f* xrun.log
endif
