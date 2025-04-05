module median_filter #(
	parameter R_WIDTH = 8,
	parameter N = 3,
	parameter P_WIDTH = $clog2(N+1))
	(
	input				srst,
	input				clk,

	input  wire [R_WIDTH-1:0]	X,
	output wire [R_WIDTH-1:0]	Y,
	output wire         valid
	);

wire [R_WIDTH-1:0] 	R_out [N+1:0];
wire [P_WIDTH-1:0] 	P_out [N+1:0];
wire			Z_out [N:0];
wire			T_out [N:0];

reg  [P_WIDTH:0]	cnt;
wire                    incre_en [N-1:0];

assign R_out[0] = R_out[1];
assign P_out[0] = P_out[1];

assign R_out[N+1] = {R_WIDTH{1'b0}};
assign P_out[N+1] = {P_WIDTH{1'b0}};

assign Z_out[0] = 1'b0;
assign T_out[0] = 1'b0;

always@(posedge clk)
begin
	if (srst)
		cnt <= {P_WIDTH{1'b0}};
	else if (cnt < (N+1)*2)
		cnt <= cnt + 1;
end
assign valid = (cnt >= (N+1)*2) ? 1'b1 : 1'b0;
genvar i;
generate
	for(i=1;i<=N;i=i+1) begin: unit_cell_gen
		unit_cell #(
			.R_WIDTH 		(R_WIDTH),
			.N 			(N),
			.P_WIDTH		(P_WIDTH))
		unit_cell(
			.srst			(srst),
			.clk			(clk),
			.incre_en		(incre_en[i-1]),
			.X			(X),
			.R_from_plus1		(R_out[i+1]),
			.R_from_minus1		(R_out[i-1]),
			.P_from_plus1		(P_out[i+1]),
			.P_from_minus1		(P_out[i-1]),
			.Z_from_minus1		(Z_out[i-1]),
			.T_from_minus1		(T_out[i-1]),
			.R_to_plus1minus1	(R_out[i]),
			.P_to_plus1minus1	(P_out[i]),
			.Z_to_plus1		(Z_out[i]),
			.T_to_plus1		(T_out[i])
		);
		
		assign incre_en[i-1] = cnt[P_WIDTH:0] > ((i-1) << 1);
	end
endgenerate

assign Y =  R_out[(N+1)/2];

endmodule
