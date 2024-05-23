`include "Preprocessors.v"

module Simple22(
	input clk, 
	input[`ISIZE-1:0] new_instruction, 
	input[`RSIZE-1:0] final_pc,
	input new_instruction_available,
	input execute,
	output reg o_data_avail = 0, 
	output reg[7:0] o_byte
);
	
	/*Buffer holds the output bytes*/
	localparam 	CLKS_PER_BYTE = 52080-1;
	reg[15:0] counter = 0;
	reg[7:0] outputBuffer[0:6];
	reg[3:0] outputByteIndex = 6;
	reg SendWordINT = 0;
	reg[7:0] intType = 0;

	/*DATA & INSTRUCTIONS MEMORIES*/
	reg[`ISIZE-1:0] instructions[0:`IMEMSIZE-1];
	reg[`WSIZE-1:0] RAM[0:`RAMSIZE-1];
	
	/*SPECIAL REGISTERS*/
	reg[`RSIZE-1:0] pc = 0;//program counter >> pointer for instructions memory
	reg[`RSIZE-1:0] sp = 0;//stack pointer >> pointer for RAM memory
	
	/*GENERAL PURPOSE REGISTERS >> GPRs*/
	reg[`RSIZE-1:0] GPRs[0:7];

	reg[`ISIZE-1:0] instruction = 0;
	always@(posedge clk) begin
		SendWordINT = 0;
		if (execute) begin
			if (final_pc >= pc && outputByteIndex == 6) begin
				instruction = instructions[pc];
				case(instruction[4:0])
					`ADD: GPRs[instruction[7:5]] = GPRs[instruction[10:8]] + GPRs[instruction[13:11]];
					`SUB: GPRs[instruction[7:5]] = GPRs[instruction[10:8]] - GPRs[instruction[13:11]];
					`MUL: GPRs[instruction[7:5]] = GPRs[instruction[10:8]] * GPRs[instruction[13:11]];
					`DIV: GPRs[instruction[7:5]] = GPRs[instruction[10:8]] / GPRs[instruction[13:11]];
					`STORE: RAM[sp] = GPRs[instruction[7:5]];
					`LOAD: GPRs[instruction[7:5]] = RAM[sp];
					`SET: GPRs[instruction[7:5]] = instruction[31:8];
					`INT: begin
						if (instruction[31:5] == 0 || instruction[31:5] == 1) begin
							intType = instruction[12:5];
							SendWordINT = 1;
						end
						else begin end
					end
					`SPECIAL_GET: begin
						if (instruction[8] == 0) GPRs[instruction[7:5]] = sp;
						else GPRs[instruction[7:5]] = pc;
					end
					`SPECIAL_SET: begin
						if (instruction[8] == 0) sp = GPRs[instruction[7:5]];
						else pc = GPRs[instruction[7:5]];
					end
					default: begin end
				endcase
				pc = pc + 1;
			end
		end
		else begin
			pc <= 0;
			sp <= 0;
			GPRs[3'b000] <= 0;
			GPRs[3'b001] <= 0;
			GPRs[3'b010] <= 0;
			GPRs[3'b011] <= 0;
			GPRs[3'b100] <= 0;
			GPRs[3'b101] <= 0;
			GPRs[3'b110] <= 0;
			GPRs[3'b111] <= 0;
		end
	end
	
	always@(posedge clk, posedge SendWordINT) begin
		if (SendWordINT) begin
			outputByteIndex <= 0;
		end
		else begin
			outputBuffer[0] <= intType;
			outputBuffer[1] <= GPRs[0][7:0];
			outputBuffer[2] <= GPRs[0][15:8];
			outputBuffer[3] <= GPRs[0][23:16];
			outputBuffer[4] <= GPRs[0][31:24];
			if (outputByteIndex < 6) begin
				if (counter < CLKS_PER_BYTE) 
					counter <= counter + 1;
				else begin
					if (outputByteIndex < 5)
						o_byte <= outputBuffer[outputByteIndex];
					outputByteIndex <= outputByteIndex + 1;
					counter <= 0;
					o_data_avail <= 1;
				end
			end
			else o_data_avail <= 0;
		end
	end
	
	always@(posedge new_instruction_available) instructions[final_pc] <= new_instruction;

endmodule 