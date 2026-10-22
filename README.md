# Parameterized Dual-Port SRAM in Verilog

A small synchronous RAM design written in Verilog, with one write port and one read port. The read and write operations can occur in the same clock cycle, using independent addresses.

> This is a **simple dual-port RAM (1 write port + 1 read port)**, not a true dual-port RAM with two independently configurable read/write ports.

## Features

- Parameterized data width and address width
- Synchronous write on the rising edge of `clk`
- Synchronous read on the rising edge of `clk`
- Shared enable (`en`) and independent write/read controls (`we`, `re`)
- Testbench checks for writes, reads, simultaneous read/write at different addresses, and output hold while disabled

## Files

| File | Description |
|---|---|
| `dual_port_sram.v` | Synthesizable RTL module |
| `dual_port_sram_tb.v` | Simulation testbench with pass/fail checks |

## Parameters

| Parameter | Default | Meaning |
|---|---:|---|
| `DATA_WIDTH` | 8 | Number of bits per memory word |
| `ADDR_WIDTH` | 4 | Number of address bits; memory depth is (2^{ADDR\_WIDTH}) |

With the defaults, the memory contains 16 words × 8 bits.

## Interface

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | Clock |
| `en` | Input | Enables read/write operations |
| `we` | Input | Write enable |
| `re` | Input | Read enable |
| `waddr` | Input | Write address |
| `raddr` | Input | Read address |
| `din` | Input | Write data |
| `dout` | Output | Registered read data |

When `en=0`, neither a write nor a read occurs, and `dout` retains its previous value. When `en=1`, `we` and `re` independently select writing and reading.

## Run the simulation

Using Icarus Verilog:

```bash
iverilog -g2012 -o sram_sim dual_port_sram.v dual_port_sram_tb.v
vvp sram_sim
```

- `iverilog` compiles the RTL and testbench into the simulation executable `sram_sim`.
- `-g2012` enables SystemVerilog-2012 language support (the design itself is Verilog-compatible).
- `-o sram_sim` names the output executable.
- `vvp sram_sim` runs the compiled simulation.

The testbench prints PASS/FAIL for each check and a final summary.

## Design notes

- The read is synchronous: `dout` updates only on a rising clock edge when `en && re` is true.
- Nonblocking assignments (`<=`) model clocked storage.
- The testbench performs simultaneous read and write to **different addresses**. Read/write collisions at the same address can have device-specific behavior when inferred as FPGA block RAM; consult the target FPGA's memory documentation.
- Actual FPGA mapping to block RAM or distributed RAM depends on the FPGA family, synthesis tool, and coding/configuration choices.


4. Add assertions for boundary addresses and additional enable combinations.
