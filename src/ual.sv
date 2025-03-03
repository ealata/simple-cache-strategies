`ifndef UAL_SV
`define UAL_SV

`include "common.vh"

module UAL(
		input V32 v1,
		input V32 v2,
		input V8 operation,
		output V32 out
	);

	V32 out_add;
	V32 out_sub;
	V32 out_and;

	assign out_add = v1 + v2;
	assign out_sub = v1 - v2;
	assign out_and = v1 & v2;

	assign out =
		(operation == ADD) ? out_add :
		(operation == SUB) ? out_sub :
		(operation == AND) ? out_and :
		32'h00000000;

endmodule

`endif
