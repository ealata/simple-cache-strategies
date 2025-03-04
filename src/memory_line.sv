`ifndef DATA_MEMORY_SV
`define DATA_MEMORY_SV

`include "common.vh"

module Memory_Line(
		input reset,
		input clock,

		input V32 address,
		input t_line input_line,
		output t_line output_line,
		input t_access_type access,

		output logic busy,
		input V8 debug
	);

	V8 counter;
	t_line memory [511:0];
	logic state;

	V32 save_address;
	t_line save_input_line;
	t_access_type save_access;

	initial $readmemh(`DATA, memory, 0, 511);

	assign busy = state == 1'b1;

	always @(posedge clock) begin
		if (reset) begin
			counter = 8'h00;
			state = 1'b0;
		end else if (counter != 8'h00) begin
			if (counter == 8'h01) begin
				if (save_access == ACCESS_WRITE) begin
					memory[address[12:4]] = input_line;
					output_line = input_line;
				end else if (save_access == ACCESS_READ) begin
					output_line = memory[address[12:4]];
				end
				state = 1'b0;
				save_address = 32'h00000000;
				save_input_line = {4{32'h00000000}};
				save_access = ACCESS_NONE;
			end
			counter = counter - 8'h01;
		end else if (access != ACCESS_NONE) begin
			state = 1'b1;
			counter = 8'h80;
			save_address = address;
			save_input_line = input_line;
			save_access = access;
		end
		if (debug == DUMP) begin
			$display("[?] data memory dump (non zero values):");
			for (int i = 0; i < 2048; i = i + 1) begin
				if (memory[i] != {4{32'h00000000}}) begin
					$display("[?] data_memory[%4d] = %h", i, memory[i]);
				end
			end
		end
	end

	t_line line_0;
	t_line line_1;
	t_line line_2;
	t_line line_3;
	t_line line_4;
	t_line line_5;
	t_line line_6;
	t_line line_7;
	t_line line_8;
	t_line line_9;
	t_line line_10;
	t_line line_11;
	t_line line_12;
	t_line line_13;
	t_line line_14;
	t_line line_15;

	assign line_0 = memory[0];
	assign line_1 = memory[1];
	assign line_2 = memory[2];
	assign line_3 = memory[3];
	assign line_4 = memory[4];
	assign line_5 = memory[5];
	assign line_6 = memory[6];
	assign line_7 = memory[7];
	assign line_8 = memory[8];
	assign line_9 = memory[9];
	assign line_10 = memory[10];
	assign line_11 = memory[11];
	assign line_12 = memory[12];
	assign line_13 = memory[13];
	assign line_14 = memory[14];
	assign line_15 = memory[15];


endmodule

`endif
