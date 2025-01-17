module UART_Tx (input clock, input i_data_avail, input[7:0] i_data_byte, output reg o_tx);

	//The FPGA clock freq. is 50MHz, the sender will send 9600 bits per second >> 1/9600 * 50MHz = 5208 clocks/bit
	localparam 	CLKS_PER_BIT = 5208;

	localparam IDLE_STATE = 0;
	localparam START_STATE = 1;
	localparam SEND_BIT_STATE = 2; 
	localparam STOP_STATE = 3;

	reg[1:0] state = 0;
	reg[15:0] counter = 0;
	reg[2:0] bit_index = 0;
	reg[7:0] data_byte = 0;
	
	always@(posedge clock)
	begin 
		case(state)
			IDLE_STATE: begin
				o_tx <= 1;
				counter <= 0;
				bit_index <= 0;
				
				if (i_data_avail == 1) begin 
					data_byte <= i_data_byte;
					state <= START_STATE;
				end
				else begin 
					state <= IDLE_STATE;
				end
			end
			
			START_STATE: begin 
				o_tx <= 0;
				
				if (counter < CLKS_PER_BIT - 1) begin 
					counter <= counter + 1;
					state <= START_STATE;
				end
				else begin 
					counter <= 0;
					state <= SEND_BIT_STATE;
				end
			end
			
			SEND_BIT_STATE: begin 
				o_tx <= data_byte[bit_index];
				if (counter < CLKS_PER_BIT - 1) begin 
					counter <= counter + 1;
					state <= SEND_BIT_STATE;
				end
				else begin 
					counter <= 0;
					
					if (bit_index < 7) begin 
						bit_index <= bit_index + 1;
						state <= SEND_BIT_STATE;
					end
					else begin 
						bit_index <= 0;
						state <= STOP_STATE;
					end
				end
			end
			
			STOP_STATE:
			begin 
				o_tx <= 1;
				
				if (counter < CLKS_PER_BIT - 1) begin 
					counter <= counter + 1;
					state <= STOP_STATE;
				end
				else begin 
					state <= IDLE_STATE;
				end
			end
		endcase
	end

endmodule 