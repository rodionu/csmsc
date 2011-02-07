//file Register.v

module Register(
//input wire CLOCK,
input wire RESET,
input wire [31:0] Instruction,
input wire RegWrite,	//Write enable		//From Pipe STAGE 4
input wire [4:0] WN,		//Write Register #	//From Pipe STAGE 4
input wire [31:0] WD,	//Write data		//From Pipe STAGE 4
output reg [4:0] RS,
output reg [4:0] RT,
output reg [31:0] RD1,	//Output reg 1
output reg [31:0] RD2);	//Output reg 2

//Below are variables NOT input/output ports
//reg [4:0] RS;		//First input
//reg [4:0] RT;		//Second input
reg [31:0] mem [0:31];	//32x32bit memory "register"
reg [4:0] i;		//Loop variable


	
always @* begin			//Trigger on the clock

	if(RESET !=0) begin
		for(i=0; i<31; i=i+1) begin	//Clear "registers"
			mem[i] = i;
		end
		
	end else if(RESET == 0) begin
<<<<<<< .mine
		if(RegWrite == 1) begin		//Writebacks can be read in same cycle
			mem[WN] = WD;			//Write data to register
		end
		RS = Instruction[25:21];		//First input
		RT = Instruction[20:16];		//Second input
		RD1 = mem[RS];		//Verilog array elements are
		RD2 = mem[RT];		//accessed "all bits" at a time, these
	end
						//will be 32 bit numbers
=======
		if(RegWrite!=0) begin		//Writebacks can be read in same cycle
			mem[WN] = WD;			//Write data to register
			RS = Instruction[25:21];		//First input
			RT = Instruction[20:16];		//Second input
			RD1 = mem[RS];		//Verilog array elements are
			RD2 = mem[RT];		//accessed "all bits" at a time, these
		end else if (RegWrite==0) begin
			RS = Instruction[25:21];		//First input
			RT = Instruction[20:16];		//Second input
			RD1 = mem[RS];		//Verilog array elements are
			RD2 = mem[RT];		//accessed "all bits" at a time, these
								//will be 32 bit numbers
>>>>>>> .r131
end
end
endmodule
