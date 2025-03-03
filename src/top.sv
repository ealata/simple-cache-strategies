`include "cpu.sv"

module Testbench;

	logic reset;
	logic clock = 0;
	logic finished;
	V32 result;

	CPU u_cpu(reset, clock, result, finished);

	always #1 clock <= ~clock;

	initial begin
		//$dumpfile("test.vcd");
		$dumpfile(`VCD);
		$dumpvars(0, u_cpu);

		reset <= 1; #10
		reset <= 0; //#64
		while (!finished) begin #1; end
		$stop;
	end

endmodule
