//file PC.v

module PC(
input wire		 CLOCK,
input wire		 RESET,
input wire [31:0] SE,		//Sign extended 32
input wire [9:0] PCP4,		//Stored PC+4 from pipeline
input wire		 Branch, //Branch flag from controller (pipe delayed)
input wire		 Zero,	//ALU Zero
input wire		 Jump,	//Jump flag from controller (delayed by pipe)
input wire [9:0] JTGT,	//Jump target
output reg [7:0] PC);	//PC Output to instruction memory

reg [9:0] target;
reg [7:0] NewPC;
reg		  PCSrc;	//PC Source

always @* begin
	if((Branch == 0)||(Zero == 0)) begin
		PCSrc = 0;
	end else begin
		PCSrc = 1;
	end
end
always @(posedge CLOCK) begin
	if(RESET !=0) begin
		PC = 0;
	
	end else if(PCSrc == 0) begin
		PC = PC + 4;
	
	end else if (Jump != 0)	
	
	end else begin
		target = SE [9:0];
		target = (target << 2)+PCP4;
		PC = target[9:2];
	end
end
endmodule
