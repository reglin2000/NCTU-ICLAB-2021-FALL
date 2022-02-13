module MAZE(
    //Input Port
    clk,
    rst_n,
    in_valid,
    in,
    //Output Port
    out_valid,
    out
);

input            clk, rst_n, in_valid, in;
output reg		 out_valid;
output reg [1:0] out;

parameter	IDLE	=	3'd0;
parameter	WALK	=	3'd1;
parameter	BACK	=	3'd2;
parameter	OUTPUT	=	3'd3;

reg	[1:0]	state;
reg	[1:0]	state_ns;
reg	[1:0]	map			[0:16][0:16];
reg	[1:0]	map_ns		[0:16][0:16];
reg	[4:0]	counter_queue_0;
reg	[4:0]	counter_queue_0_ns;
reg	[3:0]	max_queue_0;
reg	[3:0]	max_queue_0_ns;
reg	[4:0]	queue_0		[0:15][0:1];
reg	[4:0]	queue_0_ns	[0:15][0:1];
reg	[4:0]	counter_queue_1;
reg	[4:0]	counter_queue_1_ns;
reg	[3:0]	max_queue_1;
reg	[3:0]	max_queue_1_ns;
reg	[4:0]	queue_1		[0:15][0:1];
reg	[4:0]	queue_1_ns	[0:15][0:1];
reg			select_queue;
reg			select_queue_ns;
reg [1:0]	max_dir;
reg [1:0]	max_dir_ns;
reg [1:0]	max_dir_p_2;

reg	[1:0]	pos_accumulator;
reg [4:0]	cur_x;
reg [4:0]	cur_y;

integer 	i, j;

always @ (*)
begin
	for (i = 0; i < 17; i = i + 1)
		for (j = 0; j < 17; j = j + 1)
			map_ns[i][j]=	map[i][j];
	for (i = 0; i < 17; i = i + 1)
		for (j = 0; j < 2; j = j + 1)
			queue_1_ns[i][j]=	queue_1[i][j];
	for (i = 0; i < 17; i = i + 1)
		for (j = 0; j < 2; j = j + 1)
			queue_0_ns[i][j]=	queue_0[i][j];
	state_ns			=	state;
	counter_queue_0_ns	=	counter_queue_0;
	max_queue_0_ns		=	max_queue_0;
	counter_queue_1_ns	=	counter_queue_1;
	max_queue_1_ns		=	max_queue_1;
	select_queue_ns		=	select_queue;
	max_dir_ns			=	max_dir;
	max_dir_p_2			=	max_dir[1] + 2;

	pos_accumulator		=	0;
	cur_x				=	0;
	cur_y				=	0;
	out_valid			=	0;
	out					=	0;

	case (state)
		IDLE:
		begin
			if (in_valid == 1)
			begin
				if (counter_queue_0 != 16)
					counter_queue_0_ns = counter_queue_0 + 1;
				else
				begin
					counter_queue_1_ns = counter_queue_1 + 1;
					counter_queue_0_ns = 0;
				end
				map_ns[counter_queue_1][counter_queue_0] = in;
				if (counter_queue_0 == 16 && counter_queue_1 == 16)
				begin
					counter_queue_0_ns = 0;
					counter_queue_1_ns = 0;
					queue_0_ns[0][0] = 16;
					queue_0_ns[0][1] = 16;
					max_queue_0_ns = 1;
					max_queue_1_ns = 0;
					map_ns[16][16] = 2;
					max_dir_ns = 1;
					select_queue_ns = 0;
					state_ns = WALK;
				end
			end
		end

		WALK:
		begin
			if (select_queue == 0)
			begin
				cur_x = queue_0[counter_queue_0][0];
				cur_y = queue_0[counter_queue_0][1];
				counter_queue_0_ns = counter_queue_0 + 1;
				
				if (cur_y != 0 && map[cur_x][cur_y - 1] == 1)
				begin
					queue_1_ns[max_queue_1][0] = cur_x;
					queue_1_ns[max_queue_1][1] = cur_y - 1;
					map_ns[cur_x][cur_y - 1] = max_dir_p_2;
					pos_accumulator = pos_accumulator + 1;
				end
				if (cur_x != 0 && map[cur_x - 1][cur_y] == 1)
				begin
					queue_1_ns[max_queue_1 + pos_accumulator][0] = cur_x - 1;
					queue_1_ns[max_queue_1 + pos_accumulator][1] = cur_y;
					map_ns[cur_x - 1][cur_y] = max_dir_p_2;
					pos_accumulator = pos_accumulator + 1;
				end
				if (cur_y != 16 && map[cur_x][cur_y + 1] == 1)
				begin
					queue_1_ns[max_queue_1 + pos_accumulator][0] = cur_x;
					queue_1_ns[max_queue_1 + pos_accumulator][1] = cur_y + 1;
					map_ns[cur_x][cur_y + 1] = max_dir_p_2;
					pos_accumulator = pos_accumulator + 1;
				end
				if (cur_x != 16 && map[cur_x + 1][cur_y] == 1)
				begin
					queue_1_ns[max_queue_1 + pos_accumulator][0] = cur_x + 1;
					queue_1_ns[max_queue_1 + pos_accumulator][1] = cur_y;
					map_ns[cur_x + 1][cur_y] = max_dir_p_2;
					pos_accumulator = pos_accumulator + 1;
				end
				max_queue_1_ns = max_queue_1 + pos_accumulator;

				if (counter_queue_0_ns == max_queue_0)
				begin
					select_queue_ns = 1;
					counter_queue_0_ns = 0;
					max_queue_0_ns = 0;
					
					max_dir_ns = max_dir + 1;
				end

				if (map_ns[0][0] != 1)
				begin
					state_ns = BACK;
					queue_0_ns[0][0] = 0;
					queue_0_ns[0][1] = 0;
					max_dir_ns = max_dir;
				end
			end
			else
			begin
				cur_x = queue_1[counter_queue_1][0];
				cur_y = queue_1[counter_queue_1][1];
				counter_queue_1_ns = counter_queue_1 + 1;
				
				if (cur_y != 0 && map[cur_x][cur_y - 1] == 1)
				begin
					queue_0_ns[max_queue_0][0] = cur_x;
					queue_0_ns[max_queue_0][1] = cur_y - 1;
					map_ns[cur_x][cur_y - 1] = max_dir_p_2;
					pos_accumulator = pos_accumulator + 1;
				end
				if (cur_x != 0 && map[cur_x - 1][cur_y] == 1)
				begin
					queue_0_ns[max_queue_0 + pos_accumulator][0] = cur_x - 1;
					queue_0_ns[max_queue_0 + pos_accumulator][1] = cur_y;
					map_ns[cur_x - 1][cur_y] = max_dir_p_2;
					pos_accumulator = pos_accumulator + 1;
				end
				if (cur_y != 16 && map[cur_x][cur_y + 1] == 1)
				begin
					queue_0_ns[max_queue_0 + pos_accumulator][0] = cur_x;
					queue_0_ns[max_queue_0 + pos_accumulator][1] = cur_y + 1;
					map_ns[cur_x][cur_y + 1] = max_dir_p_2;
					pos_accumulator = pos_accumulator + 1;
				end
				if (cur_x != 16 && map[cur_x + 1][cur_y] == 1)
				begin
					queue_0_ns[max_queue_0 + pos_accumulator][0] = cur_x + 1;
					queue_0_ns[max_queue_0 + pos_accumulator][1] = cur_y;
					map_ns[cur_x + 1][cur_y] = max_dir_p_2;
					pos_accumulator = pos_accumulator + 1;
				end
				max_queue_0_ns = max_queue_0 + pos_accumulator;

				if (counter_queue_1_ns == max_queue_1)
				begin
					select_queue_ns = 0;
					counter_queue_1_ns = 0;
					max_queue_1_ns= 0;
					
					max_dir_ns = max_dir + 1;
				end

				if (map_ns[0][0] != 1)
				begin
					state_ns = BACK;
					queue_0_ns[0][0] = 0;
					queue_0_ns[0][1] = 0;
					max_dir_ns = max_dir;
				end
			end
		end

		BACK:
		begin
			cur_x = queue_0[0][0];
			cur_y = queue_0[0][1];

			if (cur_x == 16 && cur_y == 16)
			begin
				state_ns = IDLE;
				counter_queue_0_ns	=	0;
				max_queue_0_ns		=	0;
				counter_queue_1_ns	=	0;
				max_queue_1_ns		=	0;
				select_queue_ns		=	0;
				max_dir_ns			=	0;
			end
			else
			begin
				out_valid = 1;
				max_dir_ns = max_dir - 1;
				
				// if (max_dir == 3)
				case (max_dir)
					2'd3:
					begin
						if (cur_y != 0 && map[cur_x][cur_y - 1] == 3)
						begin
							out = 2;
							queue_0_ns[0][0] = cur_x;
							queue_0_ns[0][1] = cur_y - 1;
						end
						else if (cur_x != 0 && map[cur_x - 1][cur_y] == 3)
						begin
							out = 3;
							queue_0_ns[0][0] = cur_x - 1;
							queue_0_ns[0][1] = cur_y;
						end
						else if (cur_y != 16 && map[cur_x][cur_y + 1] == 3)
						begin
							out = 0;
							queue_0_ns[0][0] = cur_x;
							queue_0_ns[0][1] = cur_y + 1;
						end
						else if (cur_x != 16 && map[cur_x + 1][cur_y] == 3)
						begin
							out = 1;
							queue_0_ns[0][0] = cur_x + 1;
							queue_0_ns[0][1] = cur_y;
						end
					end
					2'd2:
					begin
						if (cur_y != 0 && map[cur_x][cur_y - 1] == 2)
						begin
							out = 2;
							queue_0_ns[0][0] = cur_x;
							queue_0_ns[0][1] = cur_y - 1;
						end
						else if (cur_x != 0 && map[cur_x - 1][cur_y] == 2)
						begin
							out = 3;
							queue_0_ns[0][0] = cur_x - 1;
							queue_0_ns[0][1] = cur_y;
						end
						else if (cur_y != 16 && map[cur_x][cur_y + 1] == 2)
						begin
							out = 0;
							queue_0_ns[0][0] = cur_x;
							queue_0_ns[0][1] = cur_y + 1;
						end
						else if (cur_x != 16 && map[cur_x + 1][cur_y] == 2)
						begin
							out = 1;
							queue_0_ns[0][0] = cur_x + 1;
							queue_0_ns[0][1] = cur_y;
						end
					end
					2'd1:
					begin
						if (cur_y != 0 && map[cur_x][cur_y - 1] == 2)
						begin
							out = 2;
							queue_0_ns[0][0] = cur_x;
							queue_0_ns[0][1] = cur_y - 1;
						end
						else if (cur_x != 0 && map[cur_x - 1][cur_y] == 2)
						begin
							out = 3;
							queue_0_ns[0][0] = cur_x - 1;
							queue_0_ns[0][1] = cur_y;
						end
						else if (cur_y != 16 && map[cur_x][cur_y + 1] == 2)
						begin
							out = 0;
							queue_0_ns[0][0] = cur_x;
							queue_0_ns[0][1] = cur_y + 1;
						end
						else if (cur_x != 16 && map[cur_x + 1][cur_y] == 2)
						begin
							out = 1;
							queue_0_ns[0][0] = cur_x + 1;
							queue_0_ns[0][1] = cur_y;
						end
					end
					2'd0:
					begin
						if (cur_y != 0 && map[cur_x][cur_y - 1] == 3)
						begin
							out = 2;
							queue_0_ns[0][0] = cur_x;
							queue_0_ns[0][1] = cur_y - 1;
						end
						else if (cur_x != 0 && map[cur_x - 1][cur_y] == 3)
						begin
							out = 3;
							queue_0_ns[0][0] = cur_x - 1;
							queue_0_ns[0][1] = cur_y;
						end
						else if (cur_y != 16 && map[cur_x][cur_y + 1] == 3)
						begin
							out = 0;
							queue_0_ns[0][0] = cur_x;
							queue_0_ns[0][1] = cur_y + 1;
						end
						else if (cur_x != 16 && map[cur_x + 1][cur_y] == 3)
						begin
							out = 1;
							queue_0_ns[0][0] = cur_x + 1;
							queue_0_ns[0][1] = cur_y;
						end
					end
				endcase
					
			end
		end

	endcase
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		for (i = 0; i < 17; i = i + 1)
			for (j = 0; j < 17; j = j + 1)
				map[i][j]	<=	0;
		for (i = 0; i < 17; i = i + 1)
			for (j = 0; j < 2; j = j + 1)
				queue_1[i][j]<=	0;
		for (i = 0; i < 17; i = i + 1)
			for (j = 0; j < 2; j = j + 1)
				queue_0[i][j]<=	0;
		state			<=	0;
		counter_queue_0	<=	0;
		max_queue_0		<=	0;
		counter_queue_1	<=	0;
		max_queue_1		<=	0;
		select_queue	<=	0;
		max_dir			<=	0;
	end
	else
	begin
		for (i = 0; i < 17; i = i + 1)
			for (j = 0; j < 17; j = j + 1)
				map[i][j]<=	map_ns[i][j];
		for (i = 0; i < 17; i = i + 1)
			for (j = 0; j < 2; j = j + 1)
				queue_1[i][j]<=	queue_1_ns[i][j];
		for (i = 0; i < 17; i = i + 1)
			for (j = 0; j < 2; j = j + 1)
				queue_0[i][j]<=	queue_0_ns[i][j];
		state			<=	state_ns;
		counter_queue_0	<=	counter_queue_0_ns;
		max_queue_0		<=	max_queue_0_ns;
		counter_queue_1	<=	counter_queue_1_ns;
		max_queue_1		<=	max_queue_1_ns;
		select_queue	<=	select_queue_ns;
		max_dir			<=	max_dir_ns;
	end
end
    
endmodule
