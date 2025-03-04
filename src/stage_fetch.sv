`ifndef STAGE_FETCH_SV
`define STAGE_FETCH_SV

`include "common.vh"
`include "instruction_pointer.sv"
`include "instruction_memory.sv"

module Stage_Fetch(
		input logic reset,
		input logic clock,
		input logic stall,
		output t_stage stage_if
	);

	V32 ip;
	V32 instruction;

	Instruction_Pointer u_ip(
		.reset(reset),
		.clock(clock),
		.stall(stall),
		.ip(ip)
	);

	Instruction_Memory u_im(
		.address(ip),
		.instruction(instruction)
	);

	always_ff @(posedge clock) begin
		if (reset) begin
			`stage_flush(stage_if);
		end else if (!stall) begin
			stage_if.ip <= ip;
			stage_if.instruction <= instruction;
			// The next assignments are needed for hazard processing
			stage_if.operation <= instruction[31:24];
			stage_if.r1 <= instruction[15:8];
			stage_if.r2 <= instruction[7:0];
		end
	end

	always_ff @(negedge clock) begin
		if (!reset) begin
			`stage_print("IF", stage_if);
		end
	end

endmodule

`endif
