`ifndef DATA_HAZARD_SV
`define DATA_HAZARD_SV

`include "common.vh"

module Data_Hazard(
		input t_stage stage_if,
		input t_stage stage_id,
		input t_stage stage_ex,
		input t_stage stage_mem,
		output data_hazard
	);

	logic if_read;
	logic id_write;
	logic ex_write;

	assign if_read = 
		(stage_if.operation == ADD || stage_if.operation == SUB ||
		 stage_if.operation == AND || stage_if.operation == WRL ||
		 stage_if.operation == RDL) ?
		 1'b1 : 1'b0;
	assign id_write = 
		(stage_id.operation == ALO || stage_id.operation == AHI ||
		 stage_id.operation == ADD || stage_id.operation == SUB ||
		 stage_id.operation == AND || stage_id.operation == RDL) ?
		 1'b1 : 1'b0;
	assign ex_write = 
		(stage_ex.operation == ALO || stage_ex.operation == AHI ||
		 stage_ex.operation == ADD || stage_ex.operation == SUB ||
		 stage_ex.operation == AND || stage_ex.operation == RDL) ?
		 1'b1 : 1'b0;
	assign data_hazard =
		(if_read && id_write && (stage_if.r1 == stage_id.rw || stage_if.r2 == stage_id.rw) ||
		 if_read && ex_write && (stage_if.r1 == stage_ex.rw || stage_if.r2 == stage_ex.rw))
		 ? 1'b1 : 1'b0;

endmodule

`endif
