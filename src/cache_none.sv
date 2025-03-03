`ifndef CACHE_NONE_SV
`define CACHE_NONE_SV

`include "common.vh"
`include "memory_long.sv"

module Data_Cache(
		input reset,
		input clock,
		input V32 address,
		input t_access_type access,
		output V32 read_data,
		input V32 write_data,
		output busy,
		input V8 debug
	);

	Memory_Long u_ml(reset, clock, address, write_data, read_data, access, busy, debug);

endmodule

`endif
