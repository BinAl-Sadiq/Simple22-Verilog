module UART_Rx (input clock, input i_rx, output o_data_avail, output[7:0] o_data_byte);

	//The FPGA clock freq. is 50MHz, the sender will send 9600 bits per second >> 1/9600 * 50MHz = 5208 clocks/bit
	localparam 	CLKS_PER_BIT = 5208;

	localparam IDLE_STATE = 0;
	localparam START_STATE = 1;
	localparam GET_BIT_STATE = 2; 
	localparam STOP_STATE = 3;

	reg rx_buffer = 1'b1;
	reg rx = 1'b1;

	reg[1:0] state = 0;
	reg[15:0] counter = 0;
	reg[2:0] bit_index = 0;
	reg data_avail = 0;
	reg[7:0] data_byte = 0;


	assign o_data_avail = data_avail;
	assign o_data_byte = data_byte;

	always@(posedge clock) begin 
		rx_buffer <= i_rx;
		rx <= rx_buffer;
	end

	always@(posedge clock) begin 
		case(state)
			IDLE_STATE: begin 
				data_avail <= 0;
				counter <= 0;
				bit_index <= 0;
				if (rx == 0) state <= START_STATE;
				else state <= IDLE_STATE;
			end
				
			START_STATE: begin 
				if (counter == (CLKS_PER_BIT - 1) / 2) begin 
					if (rx == 0) begin 
						counter <= 0;
						state <= GET_BIT_STATE;
					end 
					else state <= IDLE_STATE;
				end
				else begin 
					counter <= counter + 1;
					state <= START_STATE;
				end
			end
			
			GET_BIT_STATE: begin 
				if (counter < CLKS_PER_BIT - 1) begin 
					counter <= counter + 1;
					state <= GET_BIT_STATE;
				end
				else begin 
					counter <= 0;
					data_byte[bit_index] <= rx;
					if (bit_index < 7) begin 
						bit_index <= bit_index + 1;
						state <= GET_BIT_STATE;
					end
					else begin 
						bit_index <= 0;
						state <= STOP_STATE;
					end
				end
			end
			
			STOP_STATE: begin 
				if (counter < CLKS_PER_BIT - 1) begin 
					counter <= counter + 1;
					state <= STOP_STATE;
				end
				else begin 
					data_avail <= 1;
					counter <= 0;
					state <= IDLE_STATE;
				end
			end
			
			default:
				state <= IDLE_STATE;
		endcase
	end

endmodule 