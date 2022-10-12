export PATH := /opt/riscv/bin:$(PATH)

# Defines that these are Makefile rules and not file names to build.
.PHONY: default clean build test 

default: build tb_toolchain tb_verilator

clean: 
	@rm -rf obj_dir/ && echo "Removing obj_dir/"
	@rm -f *.vcd && echo "Removing waveforms"

build:
	@echo "======= Building ======="
	@verilator -sv -Wall --cc --build --trace --top-module mod_test --timescale 1s/1s rtl/mod_*.sv -Irtl

tb_toolchain:
	@echo "==== Building Toolchain test ====="
	@mkdir -p obj_dir
	@riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 test/tb_toolchain.cpp -o obj_dir/tb_toolchain > /dev/null
	@file obj_dir/tb_toolchain

tb_verilator:
	@echo "==== Building Verilator test ====="
	@verilator -Wall --cc --exe --build --trace --top-module mod_test -o tb_verilator --timescale 1s/1s -Irtl test/tb_verilator.cpp rtl/*.sv > /dev/null
	@./obj_dir/tb_verilator
