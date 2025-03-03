`ifndef DATA_MEMORY_SV
`define DATA_MEMORY_SV

`include "common.vh"

module Memory_Long(
		input reset,
		input clock,
		input V32 address,

		input V32 input_data,
		output V32 output_data,
		input t_access_type access,

		output busy,
		input V8 debug
	);

	V8 counter;
	t_line memory [511:0];
	logic state; // state = 0 if not the last period of the current access

	initial $readmemh(`DATA, memory, 0, 511);

	genvar i;

	t_line write_slot;

	generate for (i = 0; i < 4; i = i + 1) begin
		assign write_slot[i[1:0]] =
			(address[3:2] == i[1:0])
			? input_data
			: memory[address[31:4]][i[1:0]];
	end endgenerate

	V32 read_slot;

	// fold implementation for read_slot4
	// TODO: efficiency?
	/*V32 read_slot4_select [4:0];
	assign read_slot4_select[4] = 32'h00000000;
	generate for (i = 0; i < 4; i = i + 1) begin
		assign read_slot4_select [i] =
			(address[3:2] == i[1:0])
			? memory[address[31:4]][i[1:0]]
			: read_slot4_select[i + 1];
	end endgenerate
	assign read_slot4 = { {3{32'h00000000}} , read_slot4_select [0] };
	*/
	assign read_slot =
		(address[3:2] == 2'b00) ? memory[address[31:4]][0] :
		(address[3:2] == 2'b01) ? memory[address[31:4]][1] :
		(address[3:2] == 2'b10) ? memory[address[31:4]][2] :
		memory[address[31:4]][3];

	assign busy = state == 1'b0 && access != ACCESS_NONE;

	always @(posedge clock) begin
		if (reset) begin
			counter = 8'h00;
			state = 1'b0;
		end else begin
			if (counter != 8'h00) begin
				if (counter == 8'h01) begin
					if (access == ACCESS_WRITE) begin
						memory[address[11:4]] = write_slot;
					end else if (access == ACCESS_READ) begin
						output_data = read_slot;
					end
					state = 1'b1;
				end else begin
					output_data = 32'h00000000;
				end
				counter = counter - 8'h01;
			end else begin
				state = 1'b0;
		       		if (access == ACCESS_WRITE || access == ACCESS_READ) begin
					counter = 8'h80;
				end
			end
		end
		if (debug == DUMP) begin
			$display("[?] data memory dump (non zero values):");
			for (int i = 0; i < 2048; i = i + 1) begin
				if (memory[i] != 32'h00000000) begin
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
