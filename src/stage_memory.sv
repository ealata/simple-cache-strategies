`ifndef STAGE_MEMORY_SV
`define STAGE_MEMORY_SV

`include "common.vh"

module Stage_Memory(
		input logic reset,
		input logic clock,

		output logic memory_busy,

		input t_stage stage_ex,
		output t_stage stage_mem
	);

	logic busy;
	V32 read_data;
	t_access_type access;

	assign access =
		t_access_type'(
			(stage_ex.operation == RDL) ? ACCESS_READ :
			(stage_ex.operation == WRL) ? ACCESS_WRITE :
			ACCESS_NONE
		);

	Data_Cache u_dc(
		reset,
		clock,
		stage_ex.v1,
		access,
		read_data,
		stage_ex.v2,
		busy,
		stage_ex.operation // debug
	);

	assign memory_busy = busy;

	always_ff @(posedge clock) begin
		if (reset || busy) begin
			`stage_flush(stage_mem);
		end else if (!busy) begin
			stage_mem <= stage_ex;
			if (stage_ex.operation == RDL) begin
				stage_mem.result <= read_data;
			end
		end
	end

	always_ff @(negedge clock) begin
		if (!reset) begin
			`stage_print("MEM", stage_mem);
		end
	end

endmodule

`endif
