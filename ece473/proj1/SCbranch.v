// file: SCbranch.v
// Branch Offset for Project 1 - Version: 0.1

module SCbranch(
	PCplus4,
	offset,
	newPC);
	
	input PCplus4, offset;
	output newPC;
	
	wire [7:0] PCplus4;
	wire [7:0] offset;
	reg [7:0] newPC;
	
	always @* begin
		newPC=PCplus4+offset;
	end
endmodule 