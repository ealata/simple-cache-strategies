`ifndef STAGE_DECODE_SV
`define STAGE_DECODE_SV

`include "common.vh"
`include "registers_bank.sv"

module Stage_Decode(
		input logic reset,
		input logic clock,
		input logic stall,
		input logic flush,

		input write_enable,
		input V8 rw,
		input V32 data,

		input t_stage stage_if,
		output t_stage stage_id
	);

	V32 instruction;
	V8 instruction_operation;
	V8 instruction_r1;
	V8 instruction_r2;
	V8 instruction_rw;
	V16 instruction_imm;
	V32 v1;
	V32 v2;

	assign instruction = stage_if.instruction;
	assign instruction_operation = instruction[31:24];
	assign instruction_r1 = instruction[15:8];
	assign instruction_r2 = instruction[7:0];
	assign instruction_rw = stage_if.instruction[23:16];
	assign instruction_imm = stage_if.instruction[15:0];

	Registers_Bank u_rb(
		reset,
		clock,
		instruction_r1,
		instruction_r2,
		write_enable,
		rw,
		data,
		v1,
		v2,
		instruction_operation
	);

	always_ff @(posedge clock) begin
		if (reset) begin
			`stage_flush(stage_id);
		end else if (!stall && !flush) begin
			stage_id <= stage_if;
			stage_id.operation <= instruction_operation;
			stage_id.r1 <= instruction_r1;
			stage_id.r2 <= instruction_r2;
			stage_id.rw <= instruction_rw;
			stage_id.imm <= instruction_imm;
			casex (instruction_operation)
				ADD, SUB, AND, WRL, RDL:
					begin
						stage_id.v1 <= v1;
						stage_id.v2 <= v2;
					end
				default:
					begin
						stage_id.v1 <= instruction_r1;
						stage_id.v2 <= instruction_r2;
					end
			endcase
		end else if (!stall) begin
			`stage_flush(stage_id);
		end
	end

	always_ff @(negedge clock) begin
		if (!reset) begin
			`stage_print("ID", stage_id);
		end
	end

endmodule

`endif
