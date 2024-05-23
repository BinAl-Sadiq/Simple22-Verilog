`include "Preprocessors.v"

module IO_Handler (input clk, input UART_RX, output UART_TX);

	wire o_data_avail;
	wire[7:0] o_byte;
	wire o_tx;
	
	assign UART_TX = o_tx;
	
	UART_Tx uart_tx1(clk, o_data_avail, o_byte, o_tx);

	reg[`ISIZE-1:0] new_instruction = 0;
	reg new_instruction_available = 0;
	reg[`RSIZE-1:0] final_pc = -1;
	reg execute = 0;

	Simple22 cpu(clk, new_instruction, final_pc, new_instruction_available, execute, o_data_avail, o_byte);

	wire [7:0] data_byte;
	reg [1:0] index = 0;
	wire data_byte_avail;
	reg[3:0] nibble = 0;

	UART_Rx uart_rx1(clk, UART_RX, data_byte_avail, data_byte);
	
	always @(posedge data_byte_avail) begin 
		if (execute) begin
			execute = 0;
			final_pc = 0;
			index = 0;
			new_instruction_available = 0;
		end
		
		case(index)
			0: new_instruction[7:0] = data_byte;
			1: new_instruction[15:8] = data_byte;
			2: new_instruction[23:16] = data_byte;
			3: new_instruction[31:24] = data_byte;
		endcase
		
		if (index == 3) begin 
			index = 0;
			final_pc = final_pc + 1;
			new_instruction_available = 1;
			execute = (new_instruction[4:0] == `EXIT);
		end
		else begin 
			index = index + 1;
			new_instruction_available = 0;
		end
	end
	
endmodule 