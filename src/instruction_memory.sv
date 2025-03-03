`ifndef INSTRUCTION_MEMORY_SV
`define INSTRUCTION_MEMORY_SV

`include "common.vh"

module Instruction_Memory(
		input V32 address,
		output V32 instruction
	);

	V32 memory [2047:0];
	initial $readmemh(`CODE, memory, 0, 2047);
	assign instruction = memory[address[11:2]];

endmodule

`endif
