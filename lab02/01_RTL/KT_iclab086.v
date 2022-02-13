module KT(
    clk,
    rst_n,
    in_valid,
    in_x,
    in_y,
    move_num,
    priority_num,
    out_valid,
    out_x,
    out_y,
    move_out
);

input clk,rst_n;
input in_valid;
input [2:0] in_x,in_y;
input [4:0] move_num;
input [2:0] priority_num;

output reg out_valid;
output reg [2:0] out_x,out_y;
output reg [4:0] move_out;

parameter RESET		=	2'd0;
parameter MOVE_1	=	2'd1;
parameter OUT		=	2'd2;

integer i;
integer j;

reg		[1:0]	state;
reg		[1:0]	n_state;
reg				board		[0:4][0:4];
reg				board_ns	[0:4][0:4];
reg		[2:0]	x			[0:24];
reg		[2:0]	x_ns		[0:24];
reg		[2:0]	y			[0:24];
reg		[2:0]	y_ns		[0:24];
reg		[2:0]	rec_priority;
reg		[2:0]	rec_priority_ns;
reg		[4:0]	rec_move_num;
reg		[4:0]	rec_move_num_ns;
reg		[2:0]	dir_counter;
reg		[2:0]	dir_counter_ns;
reg		[4:0]	move_counter;
reg		[4:0]	move_counter_ns;
reg				back_flag;
reg				back_flag_ns;
reg				sucess_flag[0:7];
reg		[2:0]	choose_sucess;
reg		[2:0]	x_cur;
reg		[2:0]	y_cur;
reg		[2:0]	x_a_1;
reg		[2:0]	x_a_2;
reg		[2:0]	x_m_1;
reg		[2:0]	x_m_2;
reg		[2:0]	y_a_1;
reg		[2:0]	y_a_2;
reg		[2:0]	y_m_1;
reg		[2:0]	y_m_2;
reg		[2:0]	x_diff;

//***************************************************//
//Finite State Machine example
//***************************************************//

//FSM current state assignment
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= RESET;
		for (i = 0; i < 5; i = i + 1)
		begin
			for (j = 0; j < 5; j = j + 1)
			begin
				board[i][j] <= 0;
			end
		end
		for (i = 0; i < 25; i = i + 1)
		begin
			x[i] <= 0;
		end
		for (i = 0; i < 25; i = i + 1)
		begin
			y[i] <= 0;
		end
		rec_priority <= 0;
		rec_move_num <= 0;
		dir_counter <= 0;
		move_counter <= 0;
		back_flag <= 0;
	end
	else begin
		state <= n_state;
		for (i = 0; i < 25; i = i + 1)
			x[i] <= x_ns[i];
		for (i = 0; i < 25; i = i + 1)
			y[i] <= y_ns[i];
		for (i = 0; i < 5; i = i + 1)
			for (j = 0; j < 5; j = j + 1)
				board[i][j] <= board_ns[i][j];
		rec_priority <= rec_priority_ns;
		rec_move_num <= rec_move_num_ns;
		dir_counter <= dir_counter_ns;
		move_counter <= move_counter_ns;
		back_flag <= back_flag_ns;
	end
end

//FSM next state assignment
always@(*) begin
	
	n_state = state;
	for (i = 0; i < 25; i = i + 1)
		x_ns[i] = x[i];
	for (i = 0; i < 25; i = i + 1)
		y_ns[i] = y[i];
	for (i = 0; i < 5; i = i + 1)
		for (j = 0; j < 5; j = j + 1)
			board_ns[i][j] = board[i][j];
	rec_priority_ns = rec_priority;
	rec_move_num_ns = rec_move_num;
	dir_counter_ns = dir_counter;
	move_counter_ns = move_counter;
	back_flag_ns = back_flag;
	if (back_flag == 1 && dir_counter == rec_priority)
		back_flag_ns = 1;
	else
		back_flag_ns = 0;

	out_valid = 0;
	out_x = 0;
	out_y = 0;
	move_out = 0;

	for (i = 0; i < 8; i = i + 1)
		sucess_flag[i] = 0;
	x_cur = x[move_counter - 1];
	y_cur = y[move_counter - 1];
	x_a_1 = x_cur + 1;
	x_a_2 = x_cur + 2;
	x_m_1 = x_cur - 1;
	x_m_2 = x_cur - 2;
	y_a_1 = y_cur + 1;
	y_a_2 = y_cur + 2;
	y_m_1 = y_cur - 1;
	y_m_2 = y_cur - 2;
	x_diff = 0;
	choose_sucess = 0;

	// if (x_cur == 0 && y_cur == 0 && board[2][1] == 1 && board[1][2] == 1)
	// 	back_flag_ns = 1;
	// if (x_cur == 4 && y_cur == 0 && board[2][1] == 1 && board[3][2] == 1)
	// 	back_flag_ns = 1;
	// if (x_cur == 0 && y_cur == 4 && board[2][3] == 1 && board[1][2] == 1)
	// 	back_flag_ns = 1;
	// if (x_cur == 4 && y_cur == 4 && board[3][2] == 1 && board[2][3] == 1)
	// 	back_flag_ns = 1;
	
	case(state)
		
		RESET: begin
			if (in_valid)
			begin
				x_ns[move_counter] = in_x;
				y_ns[move_counter] = in_y;
				board_ns[in_x][in_y] = 1;
				if (move_counter == 0)
				begin
					rec_priority_ns = priority_num;
					rec_move_num_ns = move_num;
				end
				dir_counter_ns = rec_priority_ns;
				move_counter_ns = move_counter + 1;
				if (move_counter_ns == rec_move_num_ns)
					n_state = MOVE_1;
			end
		end

		MOVE_1:
		begin
			if (move_counter_ns == 25)
			begin
				n_state = OUT;
				move_counter_ns = 0;
			end
			else
			begin
				if (x_cur != 0 && y_cur < 3 && board[x_m_1][y_a_2] == 0)
					sucess_flag[0] = 1;
				if (x_cur != 4 && y_cur < 3 && board[x_a_1][y_a_2] == 0)
					sucess_flag[1] = 1;
				if (x_cur < 3 && y_cur != 4 && board[x_a_2][y_a_1] == 0)
					sucess_flag[2] = 1;
				if (x_cur < 3 && y_cur != 0 && board[x_a_2][y_m_1] == 0)
					sucess_flag[3] = 1;
				if (x_cur != 4 && y_cur > 1 && board[x_a_1][y_m_2] == 0)
					sucess_flag[4] = 1;
				if (x_cur != 0 && y_cur > 1 && board[x_m_1][y_m_2] == 0)
					sucess_flag[5] = 1;
				if (x_cur > 1 && y_cur != 0 && board[x_m_2][y_m_1] == 0)
					sucess_flag[6] = 1;
				if (x_cur > 1 && y_cur != 4 && board[x_m_2][y_a_1] == 0)
					sucess_flag[7] = 1;

				if (sucess_flag[dir_counter] == 1)
					choose_sucess = dir_counter;
				else if (sucess_flag[(dir_counter + 1)%8] == 1)
					choose_sucess = dir_counter + 1;
				else if (sucess_flag[(dir_counter + 2)%8] == 1)
					choose_sucess = dir_counter + 2;
				else if (sucess_flag[(dir_counter + 3)%8] == 1)
					choose_sucess = dir_counter + 3;
				else if (sucess_flag[(dir_counter + 4)%8] == 1)
					choose_sucess = dir_counter + 4;
				else if (sucess_flag[(dir_counter + 5)%8] == 1)
					choose_sucess = dir_counter + 5;
				else if (sucess_flag[(dir_counter + 6)%8] == 1)
					choose_sucess = dir_counter + 6;
				else if (sucess_flag[(dir_counter + 7)%8] == 1)
					choose_sucess = dir_counter + 7;
				else
					back_flag_ns = 1;

				if (back_flag == 1 && dir_counter > rec_priority)
				begin
					if (choose_sucess < dir_counter && choose_sucess >= rec_priority)
					begin
						back_flag_ns = 1;
					end
				end
				else if (back_flag == 1)
				begin
					if (choose_sucess < dir_counter || choose_sucess >= rec_priority)
					begin
						back_flag_ns = 1;
					end
				end
				
				if (back_flag_ns == 0)
				begin
					case (choose_sucess)
						3'd0:
						begin
							move_counter_ns = move_counter + 1;
							board_ns[x_m_1][y_a_2] = 1;
							x_ns[move_counter] = x_m_1;
							y_ns[move_counter] = y_a_2;
							dir_counter_ns = rec_priority;
						end
						3'd1:
						begin
							move_counter_ns = move_counter + 1;
							board_ns[x_a_1][y_a_2] = 1;
							x_ns[move_counter] = x_a_1;
							y_ns[move_counter] = y_a_2;
							dir_counter_ns = rec_priority;
						end
						3'd2:
						begin
							move_counter_ns = move_counter + 1;
							board_ns[x_a_2][y_a_1] = 1;
							x_ns[move_counter] = x_a_2;
							y_ns[move_counter] = y_a_1;
							dir_counter_ns = rec_priority;
						end
						3'd3:
						begin
							move_counter_ns = move_counter + 1;
							board_ns[x_a_2][y_m_1] = 1;
							x_ns[move_counter] = x_a_2;
							y_ns[move_counter] = y_m_1;
							dir_counter_ns = rec_priority;
						end
						3'd4:
						begin
							move_counter_ns = move_counter + 1;
							board_ns[x_a_1][y_m_2] = 1;
							x_ns[move_counter] = x_a_1;
							y_ns[move_counter] = y_m_2;
							dir_counter_ns = rec_priority;
						end
						3'd5:
						begin
							move_counter_ns = move_counter + 1;
							board_ns[x_m_1][y_m_2] = 1;
							x_ns[move_counter] = x_m_1;
							y_ns[move_counter] = y_m_2;
							dir_counter_ns = rec_priority;
						end
						3'd6:
						begin
							move_counter_ns = move_counter + 1;
							board_ns[x_m_2][y_m_1] = 1;
							x_ns[move_counter] = x_m_2;
							y_ns[move_counter] = y_m_1;
							dir_counter_ns = rec_priority;
						end
						3'd7:
						begin
							move_counter_ns = move_counter + 1;
							board_ns[x_m_2][y_a_1] = 1;
							x_ns[move_counter] = x_m_2;
							y_ns[move_counter] = y_a_1;
							dir_counter_ns = rec_priority;
						end
					endcase
				end
				// Fail and back
				else
				begin
					move_counter_ns = move_counter - 1;
					board_ns[x_cur][y_cur] = 0;
					// dir_counter_ns = origin + 1
					x_diff = x[move_counter_ns] - x[move_counter_ns - 1];
					if (y[move_counter_ns] > y[move_counter_ns - 1])
					begin
						if (x_diff == 1)
							dir_counter_ns = 2;
						if (x_diff == 2)
							dir_counter_ns = 3;
						if (x_diff == 7)
							dir_counter_ns = 1;
						if (x_diff == 6)
							dir_counter_ns = 0;
					end
					else
					begin
						if (x_diff == 1)
							dir_counter_ns = 5;
						if (x_diff == 2)
							dir_counter_ns = 4;
						if (x_diff == 7)
							dir_counter_ns = 6;
						if (x_diff == 6)
							dir_counter_ns = 7;
					end
				end
			end
		end

		OUT:
		begin
			out_valid = 1;
			out_x = x[move_counter];
			out_y = y[move_counter];
			move_counter_ns = move_counter + 1;
			move_out = move_counter_ns;
			if (move_counter == 24)
			begin
				n_state = RESET;
				move_counter_ns = 0;
				for (i = 0; i < 5; i = i + 1)
					for (j = 0; j < 5; j = j + 1)
						board_ns[i][j] =  0;
			end
		end
		
		
		default: begin
			n_state = RESET;
		end
	
	endcase
end 

//Output assignment
/* always@(posedge clk or negedge rst_n) begin */
/* 	if(!rst_n) begin */
		
/* 	end */
/* 	else if( ) begin */
		
/* 	end */
/* 	else begin */
		
/* 	end */
/* end */

endmodule
