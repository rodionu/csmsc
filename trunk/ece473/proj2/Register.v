//file Register.v

module Register(
input wire CLOCK,
input wire [31:0] Instruction,
input wire RegWrite,	//Write enable		//From Pipe STAGE 4
input wire [4:0] WN,		//Write Register #	//From Pipe STAGE 4
input wire [31:0] WD,	//Write data		//From Pipe STAGE 4
output reg [31:0] RD1,	//Output reg 1
output reg [31:0] RD2);	//Output reg 2

//Below are variables NOT input/output ports
reg [4:0] RS;		//First input
reg [4:0] RT;		//Second input
reg [31:0] mem [0:31];	//32x32bit memory "register"
reg [4:0] i;		//Loop variable


initial begin
	for(i=0; i<31; i=i+1) begin	//Clear "registers"
		mem[i] = 0;
	end
end
	
always @(posedge CLOCK) begin			//Trigger on the clock

	if(RegWrite == 1) begin		//Writebacks can be read in same cycle
		mem[WN] = WD;			//Write data to register
	end

	RS = Instruction[25:21];		//First input
	RT = Instruction[20:16];		//Second input
	
	RD1 = mem[RS];		//Verilog array elements are
	RD2 = mem[RT];		//accessed "all bits" at a time, these
						//will be 32 bit numbers
	
	end
endmodule
