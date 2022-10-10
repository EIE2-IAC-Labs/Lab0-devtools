# Toolchain Test Project

## Checking your tools are setup correctly

To see if you can run all of the required tools correctly, open up a terminal to this folder and run the following:

```bash
iac@host:~/Documents/iac/devtools/autumn/workspace/toolchain$ make tb_verilator
==== Building Verilator test =====
position        tick    value_i value_o
(during tick)   1       42      0
(at +ve edge)   2       42      0
(during tick)   2       43      0
(at +ve edge)   3       43      42
(during tick)   3       44      42
(at +ve edge)   4       44      43
(during tick)   4       45      43
(at +ve edge)   5       45      44
(during tick)   5       46      44
Testbench exiting after reaching MAX_TICKS
```

```bash
iac@host:~/Documents/iac/devtools/autumn/workspace/toolchain$ make tb_toolchain
==== Building Toolchain test =====
obj_dir/tb_toolchain: ELF 32-bit LSB executable, UCB RISC-V, single-float ABI, version 1 (SYSV), statically linked, not stripped
```

If you see the same outputs, your Verilator and riscv-gnu-toolchain are setup correctly!

> To understand what happens when you run `make tb_verilator` and `make tb_toolchain`, take a look at the `tb_verilator:` and `tb_toolchain:` rule located in the [Makefile](./Makefile).
>
> The commands under the `tb_verilator` rule convert [rtl/mod_test.sv](./rtl/mod_test.sv) to a C++ model of the SystemVerilog HDL, using Verilator. 
>
> Finally, the testbench located in [test/tb_verilator.cpp](./test/tb_verilator.cpp) drives the simulation to produce the above output and a [trace.vcd](./trace.vcd) file which records the values of all the Verilog signals at each simulator step.

Once everything works, you can learn how to build your own Verilator testbench from scratch by following the labs.
