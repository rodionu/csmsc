// file: SCbranch.v
// Branch Offset for Project 1 - Version: 0.1

module SCbranch(
	PCplus4,
	offset,
	newPC);
	
	input PCplus4, offset;
	output newPC;
	
	wire [9:0] PCplus4;
	wire [9:0] offset;
	reg [7:0] newPC;
	reg [9:0] tempPC;
	always @* begin
		tempPC=PCplus4+(offset<<2);
		newPC=tempPC[9:2];
	end
endmodule 