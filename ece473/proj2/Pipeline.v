//file Pipeline.v

module Pipeline(
input wire CLOCK,

//STAGE 1 INPUTS (IF/ID stage)___________________________________
input wire [9:0] PCplusfour,
input wire [31:0] Instruction,
//OUTPUTS
output reg [4:0] RS,	//Instruction [25-11]
output reg [4:0] RD,	//Instruction [20-16]
output reg [4:0] RT,	//Instruction [15-11]
output reg [31:0] Control_IN, //Basically the whole instruction, delayed 1CLK


//STAGE 2 INPUTS (ID/EX stage)___________________________________
//INTERNAL PASS PC+4 [9:0]
//INTERNAL PASS SIGN_EXTENDED IMMEDIATE [15:0]
//INTERNAL PASS RD [4:0]
//INTERNAL PASS RT [4:0]
input wire [31:0] RD1in,
input wire [31:0] RD2in,
input wire 		 RegDST,		//Execution stage RGDST from controller
input wire		 ALUSrc,		//ALU Immediate or Register data
input wire [3:0] ALUOp,			//Execution stage control signal (ALUOp)
input wire [1:0] MemoryRWflags,	//Memory read/write enable control signals
input wire 		 MemToReg,		//Self-explanatory
input wire		 RegWEnable,	//Register WEN control signal flag
input wire		 Branch,			//Control input branch flag
//OUTPUTS
output reg [31:0] RD1,
output reg [31:0] RD2,
output reg [31:0] SignXtend,	//This will be handled in the pipeline block
output reg [3:0] ALUOpOut,		//Execution stage control signals
output reg		 ALUSrcOut,		//Execution stage ALU Input mux


//STAGE 3 INPUTS (EX/Mem stage)___________________________________
input wire [31:0] ALU_Result,
//INTERNAL PASS RegDst selected register [4:0]
//INTERNAL PASS PC to next stage
//INTERNAL PASS MEMORY signals
//INTERNAL PASS WRITEBACK signals
//INTERNAL PASS RD2 [31:0]
//INTERNAL PASS 
//OUTPUTS
output reg MemRENABLE,
output reg MemWENABLE,
output reg BranchOut,
output reg [9:0] PC_BranchOut,	//PC output to PC block, will not handle logic in here
output reg [31:0] ALU_ResultOut,	//Address
output reg [31:0] WDOut,			//Data


//STAGE 4 INPUTS (MEM/WB stage)___________________________________
input wire [31:0] Read_Data,
//INTERNAL PASS MemToReg
//INTERNAL PASS RegWrite
//INTERNAL PASS ALU_ResultOut [31:0]
//INTERNAL PASS RegDst [4:0]
//OUTPUTS
output reg MemToRegOut,
output reg [4:0] RegDSTaddrOut,
output reg [31:0] DataOut,
output reg RegWEnableOut);	

	initial begin	//Internal variables used to save on output wires, etc
		//Internally passed variables from Stage 1 to 2
		reg [9:0] PC_Stage_2;
		
		//Internally passed variables from Stage 2 to 3
		reg [9:0] PC_Stage_3;
		reg [4:0] RegDSTaddr_Stage_3;
		reg [1:0] MemoryRWflags_Stage_3;
		reg 	  MemToReg_Stage_3;
		reg		  Branch_Stage_3;
		reg		  RegWEnable_Stage_3;
		
		//Internally passed variables from Stage 3 to 4
		reg [4:0] RegDSTaddr_Stage_4;
		reg 	  MemToReg_Stage_4;
		reg		  RegWEnable_Stage_4;
		
	end
	
	
	always @(posedge CLOCK) begin
		//STAGE 1 INPUTS
		PC_Stage_2 = PcPlusFour;
		RS = Instruction[25:21];
		RD = Instruction[20:16];
		RT = Instruction[15:11];
		Control_IN = Instruction;
		//STAGE 1 COMPLETE
	end
	
	always @(posedge CLOCK) begin
	
		//STAGE 2_________________________________________________________________
		
		RD1 = RD1in;	//This first bit handles all INPUT/OUTPUT items
		RD2 = RD2in;	//To CPU Hardware
		ALUOpOut = ALUOp;
		ALUSrcOut = ALUSrc;
	
		//This next part handles INTERNAL passes directly to the next pipeline stage
	
		SignXtend[15:0] = Control_IN[15:0];
		if(SignXtend[15] == 0) begin
			SignXtend[31:16] = 4'h0000;	//Set 0 if non-negative
		end else begin
			SignXtend[31:16] = 4'hFFFF;	//Set all 1's if negative
		end	
		PC_Stage_3 = PC_Stage_2 +(SignXtend[11:2]);	//Left shift SignXtended and add
		if(RegDST == 0) begin
			RegDSTaddr_Stage_3 = Control_IN[20:16];
		end else begin
			RegDSTaddr_Stage_3 = Control_IN[15:11];
		end
			//Simple values, stored and passed out
			MemoryRWflags_Stage_3 = MemoryRWflags;
			MemToReg_Stage_3 = MemToReg;
			Branch_Stage_3 = Branch;
			RegWEnable_Stage_3 = RegWEnable;
	end
	
	always @(posedge CLOCK) begin
		//STAGE 3______________________________________________________________________
		//Set OUTPUTS to CPU Hardware (Memory access stage)
		PCBranchOut = PC_Stage_3;		//Address to branch to
		BranchOut = Branch_Stage_3;		//Branch bit set/not set
		MemRENABLE = MemoryRWflags_Stage_3[0];
		MemWENABLE = MemoryRWflags_Stage_3[1];
		ALU_ResultOut = ALU_Result;
		WDOut = RD2;
		
		//"Internal" outputs to next pipe stage
		RegDSTaddr_Stage_4= RegDSTaddr_Stage_3;
		MemToReg_Stage_4 = MemToReg_Stage_3;
		RegWEnable_Stage_4 = RegWEnable_Stage_3;
	end
	
	
	always @(posedge CLOCK) begin
		//STAGE 4_________________________________________________________________________
		//OUTPUT is DATA and TARGET WRITE REGISTER & WRITE FLAG ONLY!
		if(MemToReg_Stage_4 == 0) begin
			Data_Out = ALU_Result;		//Integrates MemToReg Mux into pipeline block
		end else begin					//Take ALU data if 0, Memory read data if 1
			Data_Out = Read_Data;
		end
		
		RegDSTaddrOut = RegDSTaddr_Stage_4;
		RegWEnableOut = RegWEnable_Stage_4;
		end
endmodule
