//file Register.v

module Register(
input wire CLOCK,
input wire [31:0] INST,
input wire RGDST,		//Reg dest mux - 0 for RT, 1 for RD
input wire RegWrite,	//Write enable
input wire [31:0] WD,	//Write data
output reg [31:0] RD1,	//Output reg 1
output reg [31:0] RD2);	//Output reg 2

reg [4:0] RS;		//First input
reg [4:0] RT;		//Second input
reg [4:0] RD;		//Write reg select
reg [4:0] WN;		//WN input to register block
reg [31:0] mem [0:31];	//32x32bit memory "register"
reg [4:0] i;		//Loop variable


initial begin
	for(i=0; i<31; i=i+1) begin	//Clear "registers"
		mem[i] = 0;
	end
end
	
always @(INST) begin

	RS = INST[25:21];		//First input
	RT = INST[20:16];		//Second input
	RD = INST[15:11];		//Write reg select

	if(RGDST == 0) begin		//Basic mux to WN
		WN = INST[20:16];
	end else begin
		WN = INST[15:11];
	end
end
	
	always @* begin
		RD1 = mem[RS];		//Verilog array elements are
		RD2 = mem[RT];		//accessed "all bits" at a time, these
							//will be 32 bit numbers
		if(RegWrite == 1) begin
			mem[WN] = WD;	//Write data to register
		end
	end		//Close @* begin
endmodule
