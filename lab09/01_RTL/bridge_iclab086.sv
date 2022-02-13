module bridge(input clk, INF.bridge_inf inf);

//================================================================
// logic 
//================================================================
logic	[63:0]	data_w_reg;
logic			C_out_valid_ns;
logic	[7:0]	addr;
typedef	enum	logic	[2:0]	{IN=3'd0, AR=3'd1, R=3'd2, AW=3'd3, W=3'd4, OUT=3'd5}	STATE;
STATE state;
STATE state_ns;

//================================================================
// design 
//================================================================

always_comb
begin
	state_ns = state;
	inf.AR_VALID = 0;
	if (state == IN)
	begin
		inf.AR_ADDR = 0;
		inf.AW_ADDR = 0;
		inf.W_DATA = 0;
	end
	else
	begin
		inf.AR_ADDR = addr * 8 + 65536;
		inf.AW_ADDR = addr * 8 + 65536;
		inf.W_DATA = data_w_reg;
	end
	inf.R_READY = 0;
	inf.AW_VALID = 0;
	inf.W_VALID = 0;
	inf.B_READY = 0;
	C_out_valid_ns = 0;
	inf.C_data_r = 0;
	if (inf.C_out_valid)
	begin
		inf.C_data_r = data_w_reg;
	end
	case (state)
		IN:
		begin
			if (inf.C_in_valid)
			begin
				if (inf.C_r_wb)
				begin
					state_ns = AR;
				end
				else
				begin
					state_ns = AW;
				end
			end
		end
		AR:
		begin
			inf.AR_VALID = 1;
			if (inf.AR_READY)
				state_ns = R;
		end
		R:
		begin
			inf.R_READY = 1;
			if (inf.R_VALID)
			begin
				C_out_valid_ns = 1;
				state_ns = OUT;
			end
		end
		AW:
		begin
			inf.AW_VALID = 1;
			if (inf.AW_READY)
			begin
				state_ns = W;
			end
		end
		W:
		begin
			inf.W_VALID = 1;
			inf.B_READY = 1;
			if (inf.B_VALID)
			begin
				C_out_valid_ns = 1;
				state_ns = OUT;
			end
		end
		OUT:
		begin
			state_ns = IN;
		end
	endcase
end

always_ff @ (posedge clk or negedge inf.rst_n)
begin
	if (!inf.rst_n)
	begin
		data_w_reg <= 0;
	end
	else if (inf.R_VALID)
	begin
		data_w_reg <= inf.R_DATA;
	end
	else if (!inf.C_r_wb)
	begin
		data_w_reg <= inf.C_data_w;
	end
end

always_ff @ (posedge clk or negedge inf.rst_n)
begin
	if (!inf.rst_n)
	begin
		state <= IN;
		addr <= 0;
		inf.C_out_valid <= 0;
	end
	else
	begin
		state <= state_ns;
		addr <= inf.C_addr;
		inf.C_out_valid <= C_out_valid_ns;
	end
end

endmodule
