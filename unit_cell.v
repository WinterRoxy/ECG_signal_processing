module unit_cell #(
	parameter R_WIDTH = 8,
	parameter N = 3,
	parameter P_WIDTH = $clog2(N+1))
	(
	input				srst,
	input				clk,

	input				incre_en,
	input [R_WIDTH-1:0]		X,
	input [R_WIDTH-1:0]		R_from_plus1,
	input [R_WIDTH-1:0]		R_from_minus1,
	input [P_WIDTH-1:0]		P_from_plus1,
	input [P_WIDTH-1:0]		P_from_minus1,
	input 				Z_from_minus1,
	input				T_from_minus1,

	output wire [R_WIDTH-1:0]	R_to_plus1minus1,
	output wire [P_WIDTH-1:0]	P_to_plus1minus1,
	output wire			Z_to_plus1,
	output reg			T_to_plus1
	);

reg [R_WIDTH-1:0]	R;
reg [P_WIDTH-1:0]	P; 

reg [R_WIDTH-1:0]	R_next;
reg [P_WIDTH-1:0]	P_next;
wire			T;
wire			Z;
reg			s1;
reg			s2;
reg			bit_cnt;

always@(posedge clk)
begin
	if (srst)
		R <= {R_WIDTH{1'b0}};
	else if (!bit_cnt & incre_en) begin
		if (Z_to_plus1)
			R <= R_next;
	end			
	else if (bit_cnt)
		R <= R_next;
end

always@(posedge clk)
begin
	if (srst)
		P <= {P_WIDTH{1'b0}};
	else if (!incre_en)
		P <= 0;
	else if (!bit_cnt & incre_en) begin
		if (Z_to_plus1)
			P <= P_next + 1;
		else
			P <= P + 1;
	end
	else
		P <= P_next;
end

always@(posedge clk)
begin
	if (srst)
		bit_cnt <= 1'b0;
	else
		bit_cnt <= !bit_cnt;
end

assign T = (R < X);
assign Z = !bit_cnt & (P == N-1);

assign Z_to_plus1 = Z | Z_from_minus1;

always@(*) begin
	case({Z_to_plus1, T_from_minus1, T})
		3'b000: 		{T_to_plus1,s1,s2} = 3'b000;
		3'b001: 		{T_to_plus1,s1,s2} = 3'b101;
		3'b010,3'b011:  	{T_to_plus1,s1,s2} = 3'b110;
		3'b100:			{T_to_plus1,s1,s2} = 3'b011;
		3'b101,3'b110,3'b111:	{T_to_plus1,s1,s2} = 3'b111;
	endcase
end

// R_next generation
always@(*) begin
	case({s1,s2})
		2'b00: R_next = R;		// R remains unchanged
		2'b01: R_next = X;		// Loads X to R
		2'b10: R_next = R_from_minus1;	// Shifts Right
		2'b11: R_next = R_from_plus1;	// Shifts Left
	endcase
end

// P_next generation
always@(*) begin
	case({s1,s2})
		2'b00: P_next = P;		// P remains unchanged
		2'b01: P_next = {P_WIDTH{1'b0}};// Clears counter
		2'b10: P_next = P_from_minus1;	// Shifts Right
		2'b11: P_next = P_from_plus1;	// Shifts Left
	endcase
end

assign R_to_plus1minus1 = R;
assign P_to_plus1minus1 = P;

endmodule
