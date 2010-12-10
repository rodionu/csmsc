//John Murray & Yusef Nouri
//Tuesday, December 7th, 2010
//ECE 473 - Computer Architecture and Organization
//Project 2 - Design of a Five Stage Pipelined MIPS-like Processor
//Instructor: Yifeng Zhu
//File: FU.v

module FU_Y(
	input wire [31:0] ReadData1,		//Attaches after ReadData1 register output line, before ID/EX Pipeline
	input wire [31:0] ReadData2,		//Attaches after ReadData2 register output line, before ID/EX Pipeline
	input wire [31:0] result_mem,	//Attaches 2 output of MemtoReg be4 MEM/WB (Mux must b moved in front of this pipe, output should also go through pipe)
	input wire [31:0] result_alu,		//Attaches right after ALUresult, before EX/MEM Pipeline
	input wire [31:0] inst_IFID,		//Attaches to PC line right after IF/ID Pipeline
	input wire [31:0] inst_IDEX,		//Attaches to PC line right after ID/EX Pipeline
	input wire [31:0] inst_EXMEM,		//Attaches to PC line right after EX/MEM Pipeline
//	input wire RegDst_alu,			//Attaches to controller output
//	input wire RegDst_mem,			//Attaches to controller output
	input wire [4:0] w_addr_alu,			//After RegDst mux, right before EX/MEM pipeline
	input wire [4:0] w_addr_mem,			//After RegDst mux, right after EX/MEM pipeline, before MEM/WB
	output reg [31:0] forward_rd1,		//Attaches before ID/EX pipeline, from the ReadData1 register output line
	output reg [31:0] forward_rd2		//Attaches before ID/EX pipeline, from the ReadData1 register output line
//	output reg [3:0] forward_status		//only used for testing and bug hunting, not needed
	);

	reg [31:0] temp_rd1;
	reg [31:0] temp_rd2;

	always @* begin
		if((inst_IFID[20:16]==w_addr_mem) && (inst_EXMEM[20:16] != 5'b0))
			temp_rd2 <= result_mem;
		else
			temp_rd2 <= ReadData2;

		if((inst_IFID[20:16]==w_addr_alu) && (inst_IDEX[20:16] != 5'b0))
			forward_rd2 <= result_alu;
		else
			forward_rd2 <= temp_rd2;

		if((inst_IFID[25:21]==w_addr_mem) && (inst_EXMEM[25:21] != 5'b0))
			temp_rd1 <= result_mem;
		else
			temp_rd1 <= ReadData1;

		if((inst_IFID[25:21]==w_addr_alu) && (inst_IDEX[25:21] != 5'b0))
			forward_rd1 <= result_alu;
		else
			forward_rd1 <= temp_rd1;
	end
endmodule 
