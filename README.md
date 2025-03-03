## Objective

The objective of this project is to design a simple framework for implementing
and comparing two cache strategies. In order to simplify the comparison, a
5-stage pipeline has been designed. This way, simple programs can be compiled
and executed. Execution time of these programs can then be used as a basis for
the comparison.

## Prerequisites

- Python 3
- Icarus Verilog
- GTKWave

## Processor

The processor is a 5-stage pipeline that supports a small number of classical
instructions. Note that jumps are not implemented.

 | ADD      80 | rw | r1 | r2 | # regs[rw] = regs[r1] + regs[r2]
 | SUB      81 | rw | r1 | r2 | # regs[rw] = regs[r1] - regs[r2]
 | AND      82 | rw | r1 | r2 | # regs[rw] = regs[r1] && regs[r2]

 | ALO      83 | rw | imm     | # regs[rw] = imm
 | AHI      84 | rw | imm     | # regs[rw] = imm << 16

 | RDL      90 | rw | r1 | ?? | # regs[rw] = data[regs[r1]]

 | WRL      a0 | ?? | r1 | r2 | # data[regs[r1]] = regs[r2]

 | DUMP     01 | ?? | ?? | ?? | #
 | FINISHED ff | ?? | ?? | ?? | #

## Cache strategies

The stategies implemented are:

- No cache -- 4-bytes memory accesses;
- Direct mapping -- lines memory accesses;
- Set associative mapping -- line memory accesses.

Data are 4-bytes long. Lines contain 4 elements, i.e., `4*4=16` bytes.
Caches have 8 lines.

## Program generation

Programs are generated using a Python script.
For instance, to simulate sequential memory access, the following program can be useful:

```
    access = list(range(4 * 4 * 4))
    for x in access:
        add(ALO(2, x * 4))
        add(RDL(1, 1))
        add(DUMP())
    add(FINISHED())
```

## Project files

- `src`: verilog source of the processor
  - `cache_none.sv`: implementation of the none strategy
  - `cache_direct.sv`: implementation of the direct mapping strategy
  - `cache_assoc.sv`: implementation of the set associative mapping strategy
- `scr`: scripts
  - `generate_code.py`: Python compiler that generates the instruction memory
  - `generate_data.py`: Python compiler that generates the data memory
- `clean.sh`: delete generated files
- `execute.sh`: compile the project and execute the comparison

## Important note

This project was completed in just a few days for testing purposes and is
therefore far from being an industrial-grade project. If you have any
suggestions for improvement, feel free to share them.
