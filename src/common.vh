`ifndef COMMON_VH
`define COMMON_VH

`define CODE "obj/code.txt"
`define DATA "obj/data.txt"

`define INIT_PC 32'h00000000

typedef logic [1:0] V2;
typedef logic [2:0] V3;
typedef logic [3:0] V4;
typedef logic [5:0] V6;
typedef logic [7:0] V8;
typedef logic [31:0] V32;
typedef logic [15:0] V16;
typedef V32 [3:0] t_line;

typedef enum V2 {
	ACCESS_NONE = 2'b00,
	ACCESS_READ = 2'b01,
	ACCESS_WRITE = 2'b10
} t_access_type;

/*
typedef enum V2 {
	SIZE_NONE = 2'b00,
	SIZE_LONG = 2'b11
} t_access_size;
*/

typedef enum V8 {
	ADD = 8'h80,
	SUB = 8'h81,
	AND = 8'h82,
	ALO = 8'h83,
	AHI = 8'h84,
	RDL = 8'h90,
	WRL = 8'ha0,
	DUMP = 8'h01,
	FINISHED = 8'hff,
	NOP = 8'h00
} t_instruction;

`define IS_READ(operation) (operation[7:4] == 4'h9)
`define IS_WRITE(operation) (operation[7:4] == 4'ha)

`define GET_READ_SIZE(operation) (`IS_READ(operation) ? operation[1:0] : SIZE_NONE)
`define GET_WRITE_SIZE(operation) (`IS_WRITE(operation) ? operation[1:0] : SIZE_NONE)

typedef struct packed {
	V32 ip;
	V32 instruction;
	V8 operation;
	V8 r1;
	V8 r2;
	V8 rw;
	V16 imm;
	V32 v1;
	V32 v2;
	V32 result;
} t_stage;

`define stage_flush(stage) \
	stage.ip <= 32'h00000000; \
	stage.instruction <= { NOP , 24'h000000 }; \
	stage.operation <= NOP; \
	stage.r1 <= 8'h00; \
	stage.r2 <= 8'h00; \
	stage.rw <= 8'h00; \
	stage.imm <= 16'h0000; \
	stage.v1 <= 32'h00000000; \
	stage.v2 <= 32'h00000000; \
	stage.result <= 32'h00000000;

`define stage_print(tag, stage) \
	$display("%s[%h]:\n  ip=%h\n  instruction=%h\n  operation=%h\n  r1=%h\n  r2=%h\n  rw=%h\n  imm=%h\n  v1=%h\n  v2=%h\n  result=%h\n", \
		tag, stage.ip, stage.ip, stage.instruction, stage.operation, stage.r1, stage.r2, stage.rw, stage.imm, stage.v1, stage.v2, stage.result);

typedef struct packed {
	logic valid;
	V32 tag;
	V32 date;
	t_line data;
} t_cache_entry;

`endif
