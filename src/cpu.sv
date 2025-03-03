`ifndef CPU_SV
`define CPU_SV

`include "common.vh"
`include "stage_fetch.sv"
`include "stage_decode.sv"
`include "stage_execute.sv"
`include "stage_memory.sv"
`include "stage_wback.sv"
`include "data_hazard.sv"

module CPU(
		input reset,
		input clock,
		output V32 result,
		output logic finished
	);

	t_stage stage_if;
	t_stage stage_id;
	t_stage stage_ex;
	t_stage stage_mem;

	logic data_hazard;
	logic memory_busy;
	logic write_enable;
	logic stall_if;
	logic stall_id;
	logic flush_id;
	logic stall_ex;
	V8 rw;
	V32 data;

	assign stall_if = data_hazard | memory_busy;
	assign flush_id = data_hazard;
	assign stall_id = memory_busy;
	assign stall_ex = memory_busy;

	Stage_Fetch u_if(reset, clock, stall_if, stage_if);
	Stage_Decode u_id(reset, clock, stall_id, flush_id, write_enable, rw, data, stage_if, stage_id);
	Stage_Execute u_ex(reset, clock, stall_ex, stage_id, stage_ex);
	Stage_Memory u_mem(reset, clock, memory_busy, stage_ex, stage_mem);
	Stage_Wback u_wb(reset, clock, write_enable, rw, data, finished, stage_mem);
	Data_Hazard u_dh(stage_if, stage_id, stage_ex, stage_mem, data_hazard);

	assign result = stage_mem.v1;

	/* DEBUG */

	V32 stage_if_ip;// = stage_if.ip;
	V32 stage_if_instruction;
	V8 stage_if_operation;
	V8 stage_if_r1;
	V8 stage_if_r2;
	V8 stage_if_rw;
	V16 stage_if_imm;
	V32 stage_if_v1;
	V32 stage_if_v2;
	V32 stage_if_result;

	V32 stage_id_ip;
	V32 stage_id_instruction;
	V8 stage_id_operation;
	V8 stage_id_r1;
	V8 stage_id_r2;
	V8 stage_id_rw;
	V16 stage_id_imm;
	V32 stage_id_v1;
	V32 stage_id_v2;
	V32 stage_id_result;

	V32 stage_ex_ip;
	V32 stage_ex_instruction;
	V8 stage_ex_operation;
	V8 stage_ex_r1;
	V8 stage_ex_r2;
	V8 stage_ex_rw;
	V16 stage_ex_imm;
	V32 stage_ex_v1;
	V32 stage_ex_v2;
	V32 stage_ex_result;

	V32 stage_mem_ip;
	V32 stage_mem_instruction;
	V8 stage_mem_operation;
	V8 stage_mem_r1;
	V8 stage_mem_r2;
	V8 stage_mem_rw;
	V16 stage_mem_imm;
	V32 stage_mem_v1;
	V32 stage_mem_v2;
	V32 stage_mem_result;

	assign stage_if_ip = stage_if.ip;
	assign stage_if_instruction = stage_if.instruction;
	assign stage_if_operation = stage_if.operation;
	assign stage_if_r1 = stage_if.r1;
	assign stage_if_r2 = stage_if.r2;
	assign stage_if_rw = stage_if.rw;
	assign stage_if_imm = stage_if.imm;
	assign stage_if_v1 = stage_if.v1;
	assign stage_if_v2 = stage_if.v2;
	assign stage_if_result = stage_if.result;

	assign stage_id_ip = stage_id.ip;
	assign stage_id_instruction = stage_id.instruction;
	assign stage_id_operation = stage_id.operation;
	assign stage_id_r1 = stage_id.r1;
	assign stage_id_r2 = stage_id.r2;
	assign stage_id_rw = stage_id.rw;
	assign stage_id_imm = stage_id.imm;
	assign stage_id_v1 = stage_id.v1;
	assign stage_id_v2 = stage_id.v2;
	assign stage_id_result = stage_id.result;

	assign stage_ex_ip = stage_ex.ip;
	assign stage_ex_instruction = stage_ex.instruction;
	assign stage_ex_operation = stage_ex.operation;
	assign stage_ex_r1 = stage_ex.r1;
	assign stage_ex_r2 = stage_ex.r2;
	assign stage_ex_rw = stage_ex.rw;
	assign stage_ex_imm = stage_ex.imm;
	assign stage_ex_v1 = stage_ex.v1;
	assign stage_ex_v2 = stage_ex.v2;
	assign stage_ex_result = stage_ex.result;

	assign stage_mem_ip = stage_mem.ip;
	assign stage_mem_instruction = stage_mem.instruction;
	assign stage_mem_operation = stage_mem.operation;
	assign stage_mem_r1 = stage_mem.r1;
	assign stage_mem_r2 = stage_mem.r2;
	assign stage_mem_rw = stage_mem.rw;
	assign stage_mem_imm = stage_mem.imm;
	assign stage_mem_v1 = stage_mem.v1;
	assign stage_mem_v2 = stage_mem.v2;
	assign stage_mem_result = stage_mem.result;

endmodule

`endif
