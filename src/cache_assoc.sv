`ifndef CACHE_NONE_SV
`define CACHE_NONE_SV

`include "common.vh"
`include "memory_line.sv"

module Data_Cache(
		input reset,
		input clock,
		input V32 address,
		input t_access_type access,
		output V32 read_data,
		input V32 write_data,
		output logic busy,
		input V8 debug
	);

	// address:
	// note: the size of a line is 4 * 4 = 16
	// note: the offset needs 4 bits
	// note: as we access 4 bytes data, only the 2 most significant bits of
	//       offset are used
	// note: the number of lines is 8
	// note: lines are grouped in sets, 2 lines per set
	// note: the line_index needs 2 bits
	// note: the tag corresponds to the remain bits (32 - 2 - 4 = 26)
	// tag     | set_index | offset
	// 26 bits | 2 bits    | 4 bits

	t_cache_entry [7:0] cache;

	V4 state;
	V32 date;

	V2 cache_set_index;
	logic cache_line_index;
	V32 cache_tag;
	V2 cache_offset;
	V32 cache_data;
	logic cache_has_data;
	logic cache_entry0_has_data;
	logic cache_entry1_has_data;
	t_cache_entry cache_entry0;
	t_cache_entry cache_entry1;
	t_cache_entry cache_entry;

	t_access_type memory_access;
	V32 memory_address;
	t_line memory_read_line;
	t_line memory_write_line;

	logic memory_busy;

	V32 read_data_aux;
	t_line read_line_aux;

	assign cache_set_index = address[5:4];
	assign cache_tag = {6'b000000, address[31:6]};
	assign cache_offset = address[3:2];
	assign cache_entry0 = cache[{ cache_set_index , 1'b0 }];
	assign cache_entry1 = cache[{ cache_set_index , 1'b1 }];
	assign cache_entry0_has_data = cache_entry0.valid && cache_entry0.tag == cache_tag;
	assign cache_entry1_has_data = cache_entry1.valid && cache_entry1.tag == cache_tag;
	assign cache_has_data = cache_entry0_has_data || cache_entry1_has_data;
	assign cache_data =
		(cache_entry0_has_data) ?
			(	(cache_offset == 2'b00) ? cache_entry0[31:0] :
				(cache_offset == 2'b01) ? cache_entry0[63:32] :
				(cache_offset == 2'b10) ? cache_entry0[95:64] :
				cache_entry0[127:96]
			)
		:	(	(cache_offset == 2'b00) ? cache_entry1[31:0] :
				(cache_offset == 2'b01) ? cache_entry1[63:32] :
				(cache_offset == 2'b10) ? cache_entry1[95:64] :
				cache_entry1[127:96]
			);
	assign memory_write_line =
		(cache_entry0_has_data) ?
			(	(cache_offset == 2'b00) ? { cache_entry0[127:32] , write_data } :
				(cache_offset == 2'b01) ? { cache_entry0[127:64] , write_data , cache_entry0[31:0] } :
				(cache_offset == 2'b10) ? { cache_entry0[127:96] , write_data , cache_entry0[63:0] } :
				{ write_data , cache_entry0[95:0] }
			)
		:	(	(cache_offset == 2'b00) ? { cache_entry1[127:32] , write_data } :
				(cache_offset == 2'b01) ? { cache_entry1[127:64] , write_data , cache_entry1[31:0] } :
				(cache_offset == 2'b10) ? { cache_entry1[127:96] , write_data , cache_entry1[63:0] } :
				{ write_data , cache_entry1[95:0] }
			);

	Memory_Line u_ml(reset, clock, memory_address, memory_write_line, memory_read_line, memory_access, memory_busy, debug);

	`define UPDATE_CACHE(i) \
		begin \
			if	( \
					cache[i].valid == 0 && \
						(	cache[i + 1].valid == 0 || \
							cache[i + 1].tag != cache_tag \
						) || \
					cache[i].valid == 1 && cache[i + 1].valid == 1 && \
						(	cache[i].tag == cache_tag || \
							cache[i + 1].tag != cache_tag && cache[i].date < cache[i + 1].date \
						) \
				) begin \
				$display("update cache line %h", i); \
				cache[i].valid = 1; \
				cache[i].date = date; \
				cache[i].tag = cache_tag; \
				cache[i].data[0] = read_line_aux[0]; \
				cache[i].data[1] = read_line_aux[1]; \
				cache[i].data[2] = read_line_aux[2]; \
				cache[i].data[3] = read_line_aux[3]; \
			end else begin \
				$display("update cache line %h", i + 1); \
				cache[i + 1].valid = 1; \
				cache[i + 1].date = date; \
				cache[i + 1].tag = cache_tag; \
				cache[i + 1].data[0] = read_line_aux[0]; \
				cache[i + 1].data[1] = read_line_aux[1]; \
				cache[i + 1].data[2] = read_line_aux[2]; \
				cache[i + 1].data[3] = read_line_aux[3]; \
			end \
		end

	assign busy = state == 4'b0000 && access != ACCESS_NONE || (state != 4'b0000 && state != 4'b1111);

	always @(posedge clock) begin
		date = date + 1;
		if (reset) begin
			cache = {8{ 1'b0 , 32'h00000000 , 32'h00 , {128{1'b0}} }};
			memory_access = ACCESS_NONE;
			date = 0;
			state = 4'b0000;

		// write and cache has data: just update
		end else if (state == 4'b0000 && access == ACCESS_WRITE && cache_has_data) begin
			memory_access = access;
			memory_address = address;
			state = 4'b0001;
		// write and cache does not have data: read then write!
		end else if (state == 4'b0000 && access == ACCESS_WRITE && !cache_has_data) begin
			memory_access = ACCESS_READ;
			memory_address = address;
			state = 4'b1001;
		end else if (state == 4'b1001 && memory_busy) begin
			memory_access = ACCESS_NONE;
			state = 4'b1010;
		end else if (state == 4'b1010 && !memory_busy) begin
			read_data_aux = memory_read_line[address[3:2]];
			read_line_aux = memory_read_line;
			state = 4'b1011;
		end else if (state == 4'b1011) begin
			read_data = read_data_aux;
			case (cache_set_index)
				2'b00: `UPDATE_CACHE(0)
				2'b01: `UPDATE_CACHE(2)
				2'b10: `UPDATE_CACHE(4)
				2'b11: `UPDATE_CACHE(6)
			endcase
			memory_access = ACCESS_WRITE;
			state = 4'b0001;
		end else if (state == 4'b0000 && access == ACCESS_READ && !cache_has_data) begin
			memory_access = access;
			memory_address = address;
			state = 4'b0001;
		end else if (state == 4'b0000 && access == ACCESS_READ && cache_has_data) begin
			read_data = cache_data;
			state = 4'b1111;
		end else if (state == 4'b0001 && memory_busy) begin
			memory_access = ACCESS_NONE;
			state = 4'b0010;
		end else if (state == 4'b0010 && !memory_busy) begin
			read_line_aux = memory_read_line;
			read_data = memory_read_line[address[3:2]];
			case (cache_set_index)
				2'b00: `UPDATE_CACHE(0)
				2'b01: `UPDATE_CACHE(2)
				2'b10: `UPDATE_CACHE(4)
				2'b11: `UPDATE_CACHE(6)
			endcase
			state = 4'b1111;
		end else if (state == 4'b1111) begin
			// used to let the instruction going from ex to mem.
			// otherwise, this instruction is executed twice...
			state = 4'b0000;
		end
	end

	logic cache_0_valid;
	logic cache_1_valid;
	logic cache_2_valid;
	logic cache_3_valid;
	logic cache_4_valid;
	logic cache_5_valid;
	logic cache_6_valid;
	logic cache_7_valid;

	V32 cache_0_tag;
	V32 cache_1_tag;
	V32 cache_2_tag;
	V32 cache_3_tag;
	V32 cache_4_tag;
	V32 cache_5_tag;
	V32 cache_6_tag;
	V32 cache_7_tag;

	assign cache_0_valid = cache[0].valid;
	assign cache_1_valid = cache[1].valid;
	assign cache_2_valid = cache[2].valid;
	assign cache_3_valid = cache[3].valid;
	assign cache_4_valid = cache[4].valid;
	assign cache_5_valid = cache[5].valid;
	assign cache_6_valid = cache[6].valid;
	assign cache_7_valid = cache[7].valid;

	assign cache_0_tag = cache[0].tag;
	assign cache_1_tag = cache[1].tag;
	assign cache_2_tag = cache[2].tag;
	assign cache_3_tag = cache[3].tag;
	assign cache_4_tag = cache[4].tag;
	assign cache_5_tag = cache[5].tag;
	assign cache_6_tag = cache[6].tag;
	assign cache_7_tag = cache[7].tag;

	t_line cache_0_data;
	t_line cache_1_data;
	t_line cache_2_data;
	t_line cache_3_data;
	t_line cache_4_data;
	t_line cache_5_data;
	t_line cache_6_data;
	t_line cache_7_data;

	genvar i;
	generate for (i = 0; i < 4; i = i + 1) begin
		assign cache_0_data[i] = cache[0].data[i];
		assign cache_1_data[i] = cache[1].data[i];
		assign cache_2_data[i] = cache[2].data[i];
		assign cache_3_data[i] = cache[3].data[i];
		assign cache_4_data[i] = cache[4].data[i];
		assign cache_5_data[i] = cache[5].data[i];
		assign cache_6_data[i] = cache[6].data[i];
		assign cache_7_data[i] = cache[7].data[i];
	end endgenerate

endmodule

`endif
