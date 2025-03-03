`ifndef REGISTER_BANK_SV
`define REGISTER_BANK_SV

`include "common.vh"

module Registers_Bank(
		input reset,
		input clock,
		input V8 r1,
		input V8 r2,

		input write_enable,
		input V8 rw,
		input V32 data,

		output V32 v1,
		output V32 v2,
		input V8 debug
	);

	V32 regs[31:0];

	assign v1 = (!write_enable || (r1 != rw)) ? regs[r1[4:0]] : data;
	assign v2 = (!write_enable || (r2 != rw)) ? regs[r2[4:0]] : data;

	always_ff @(negedge clock) begin
		if (reset) begin
			for (integer i = 0; i < 32; i++) begin
				regs[i] <= 32'h00000000;
			end
		end else if (write_enable) begin
			if (rw[4:0] != 5'b00000) begin
				regs[rw[4:0]] <= data;
			end
		end
	end

	always @(posedge clock) begin
		if (debug == DUMP) begin
			$display("[?] regs dump (non zero values):");
			for (int i = 0; i < 32; i = i + 1) begin
				if (regs[i] != 32'h00000000) begin
					$display("[?] regs[%4d] = %h", i, regs[i]);
				end
			end
		end
	end

	V32 reg_0;
	V32 reg_1;
	V32 reg_2;
	V32 reg_3;
	V32 reg_4;
	V32 reg_5;
	V32 reg_6;
	V32 reg_7;
	V32 reg_8;
	V32 reg_9;
	V32 reg_10;
	V32 reg_11;
	V32 reg_12;
	V32 reg_13;
	V32 reg_14;
	V32 reg_15;
	V32 reg_16;
	V32 reg_17;
	V32 reg_18;
	V32 reg_19;
	V32 reg_20;
	V32 reg_21;
	V32 reg_22;
	V32 reg_23;
	V32 reg_24;
	V32 reg_25;
	V32 reg_26;
	V32 reg_27;
	V32 reg_28;
	V32 reg_29;
	V32 reg_30;
	V32 reg_31;

	assign reg_0 = regs[0];
	assign reg_1 = regs[1];
	assign reg_2 = regs[2];
	assign reg_3 = regs[3];
	assign reg_4 = regs[4];
	assign reg_5 = regs[5];
	assign reg_6 = regs[6];
	assign reg_7 = regs[7];
	assign reg_8 = regs[8];
	assign reg_9 = regs[9];
	assign reg_10 = regs[10];
	assign reg_11 = regs[11];
	assign reg_12 = regs[12];
	assign reg_13 = regs[13];
	assign reg_14 = regs[14];
	assign reg_15 = regs[15];
	assign reg_16 = regs[16];
	assign reg_17 = regs[17];
	assign reg_18 = regs[18];
	assign reg_19 = regs[19];
	assign reg_20 = regs[20];
	assign reg_21 = regs[21];
	assign reg_22 = regs[22];
	assign reg_23 = regs[23];
	assign reg_24 = regs[24];
	assign reg_25 = regs[25];
	assign reg_26 = regs[26];
	assign reg_27 = regs[27];
	assign reg_28 = regs[28];
	assign reg_29 = regs[29];
	assign reg_30 = regs[30];
	assign reg_31 = regs[31];

endmodule

`endif
