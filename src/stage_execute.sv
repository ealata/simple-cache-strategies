`ifndef STAGE_EXECUTE_SV
`define STAGE_EXECUTE_SV

`include "common.vh"
`include "ual.sv"

module Stage_Execute(
		input logic reset,
		input logic clock,
		input logic stall,

		input t_stage stage_id,
		output t_stage stage_ex
	);

	V32 result;

	UAL u_ual(
		stage_id.v1,
		stage_id.v2,
		stage_id.operation,
		result
	);

	always_ff @(posedge clock) begin
		if (reset) begin
			`stage_flush(stage_ex);
		end else if (!stall) begin
			stage_ex <= stage_id;
			casex (stage_id.operation)
				ADD, SUB, AND:	stage_ex.result <= result;
				ALO:		stage_ex.result <= { 16'h0000 , stage_id.imm };
				AHI:		stage_ex.result <= { stage_id.imm , 16'h0000 };
				WRL:		stage_ex.result <= stage_id.v2;
				default:	stage_ex.result <= stage_id.v2;
			endcase
		end
	end

	always_ff @(negedge clock) begin
		if (!reset) begin
			`stage_print("EX", stage_ex);
		end
	end

endmodule

`endif
