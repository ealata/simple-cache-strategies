`ifndef INSTRUCTION_POINTER_SV
`define INSTRUCTION_POINTER_SV

`include "common.vh"

module Instruction_Pointer(
		input reset,
		input clock,
		input stall,
		output V32 ip
	);

	V32 ip_reg;
	assign ip = ip_reg;

	always @(posedge clock) begin
		if (reset) begin
			ip_reg <= `INIT_PC;
		end else if (!stall) begin
			ip_reg <= ip_reg + 4;
		end
	end
endmodule

`endif
