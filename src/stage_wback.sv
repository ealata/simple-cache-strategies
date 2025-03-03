`ifndef STAGE_WBACK_SV
`define STAGE_WBACK_SV

`include "common.vh"

module Stage_Wback(
		input logic reset,
		input logic clock,

		output logic write_enable,
		output V8 rw,
		output V32 data,
		output logic finished,

		input t_stage stage_mem
	);

	assign finished = (stage_mem.operation == FINISHED) ? 1'b1 : 1'b0;
	assign rw = stage_mem.rw;
	assign data = stage_mem.result;
	assign write_enable =
		(stage_mem.operation == ALO || stage_mem.operation == AHI ||
		 stage_mem.operation == ADD || stage_mem.operation == SUB ||
		 stage_mem.operation == AND || stage_mem.operation == RDL) ?
		 1'b1 : 1'b0;

endmodule

`endif
