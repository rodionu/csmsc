//file 32bitadder.v

module miniadd(
input wire [31:0] A,		//First input
input wire [31:0] B,		//Second input
output reg [31:0] OUT);		//Result


always @* begin
	OUT = A+B;
end
endmodule