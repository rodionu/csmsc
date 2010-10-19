//file Register.v

module Register(
input wire [5:0] A,		//First input
input wire [5:0] B,		//Second input
input wire [5:0] WN,	//Write reg select
input wire [31:0] WD,	//Write data
input wire RegWrite,	//Write enable
output reg [31:0] OR1,	//Output reg 1
output reg [31:0] OR2);	//Output reg 2

reg [31:0] mem[0:31];	//32x32bit memory "register"
int i;

for(i=0; i<31, i++) begin	//Clear "registers"
	mem[i] = 0;
end

always @* begin
	OR1 = mem[A];		//Verilog array elements are
	OR2 = mem[B];		//accessed "all bits" at a time, these
							//will be 32 bit numbers
	if(RegWrite == 1) begin
		mem[WN] = WD;	//Write data to register
	end
end					
endmodule