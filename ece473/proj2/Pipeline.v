//file Pipeline.v

module Pipeline(
input wire CLOCK,
input wire RESET,
input wire IFID_CLR,	//In case of branch or jump, clear instructions AFTER branch inst

//STAGE 1 INPUTS (IF/ID stage)___________________________________
input wire [9:0] PC,
input wire [31:0] Instruction,
//OUTPUTS
//output reg [4:0] RS,	//Instruction [25-11]	//Individual registers not necessary
//output reg [4:0] RD,	//Instruction [20-16]	//With this implementation
//output reg [4:0] RT,	//Instruction [15-11]	//Passing instruction is fine
output reg [31:0] Inst_IF_ID, //Basically the whole instruction, delayed 1CLK


//STAGE 2 INPUTS (ID/EX stage)___________________________________
//INTERNAL PASS PC+4 [9:0]
//INTERNAL PASS SIGN_EXTENDED IMMEDIATE [15:0]
//INTERNAL PASS RD [4:0]
//INTERNAL PASS RT [4:0]
input wire [31:0] RD1in,		//Input direct from register (output to execution stage)
input wire [31:0] RD2in,
input wire 		 RegDST,		//Execution stage RGDST from controller
input wire		 ALUSrc,		//ALU Immediate or Register data
input wire [3:0] ALUOp,			//Execution stage control signal (ALUOp)
input wire 		 MemRead,		//Memory read/write control signals
input wire		 MemWrite,
input wire 		 MemToReg,		//Self-explanatory
input wire		 RegWEnable,	//Register WEN control signal flag
input wire		 Branch,		//Control input branch flag
//input wire		 Jump,			//Control input jump flag
//OUTPUTS
output reg [31:0] Inst_ID_EX,	//Instruction delayed 2 clocks
output reg [31:0] RD1,
output reg [31:0] RD2,
output reg [31:0] SignXtend,	//This will be handled in the pipeline block
output reg [3:0]  ALUOpOut,		//Execution stage control signals
output reg		  ALUSrcOut,		//Execution stage ALU Input mux
output reg [9:0]  PCP4,

//STAGE 3 INPUTS (EX/Mem stage)___________________________________
input wire [31:0] ALU_Result,
//INTERNAL PASS RegDst selected register [4:0]
//INTERNAL PASS PC to next stage
//INTERNAL PASS MEMORY signals
//INTERNAL PASS WRITEBACK signals
//INTERNAL PASS RD2 [31:0]
//OUTPUTS
output reg [31:0] Inst_EX_MEM,	//Instruction delayed 2 clocks
output reg MemRENABLE,
output reg MemWENABLE,
output reg BranchOut,
output reg [31:0] ALU_ResultOut,	//Address
output reg [31:0] WDOut,			//Data OUTPUT TO MEMORY


//STAGE 4 INPUTS (MEM/WB stage)___________________________________
input wire [31:0] Read_Data,
//INTERNAL PASS MemToReg
//INTERNAL PASS RegWrite
//INTERNAL PASS ALU_ResultOut [31:0]
//INTERNAL PASS RegDst [4:0]
//OUTPUTS
output reg [31:0] Inst_MEM_WB,		//Instruction delayed 3 clocks
output reg MemToRegOut,				//UNUSED (Passover handled internally)
output reg [4:0] RegDSTaddrOut,
output reg [31:0] DataOut,
output reg RegWEnableOut);
//END DECLARE MODULE - START INTERNAL DECLARATIONS____________________

//Internally passed variable from stage 1 to 2
reg [9:0] PC_Stage_2;
		
//Internally passed variables from Stage 2 to 3
reg [4:0] RegDSTaddr_Stage_3;
reg [1:0] _Stage_3;
reg 	  MemToReg_Stage_3;
reg		  RegWEnable_Stage_3;
reg		  MemRead_Stage_3;
reg		  MemWrite_Stage_3;

//Internally passed variables from Stage 3 to 4
reg [4:0] RegDSTaddr_Stage_4;
reg 	  MemToReg_Stage_4;
reg		  RegWEnable_Stage_4;	
	
	always @(posedge CLOCK) begin
	//*Note - The order of these operations are reversed from what is normally expected,
	//If the stages were performed in-order, the same information would propagate to every
	//stage, instead of pipelining through like it should. All stages have to be performed
	//from right to left.
	if(RESET == 0) begin

		//STAGE 4______________________________________________________________
		//OUTPUT is DATA and TARGET WRITE REGISTER & WRITE FLAG ONLY!
		if(MemToReg_Stage_4 == 0) begin
			DataOut = ALU_Result;		//Integrates MemToReg Mux into pipeline block
		end else begin					//Take ALU data if 0, Memory read data if 1
			DataOut = Read_Data;
		end
		Inst_MEM_WB = Inst_EX_MEM;
		MemToRegOut = MemToReg_Stage_4;		//DEBUG output
		RegDSTaddrOut = RegDSTaddr_Stage_4;
		RegWEnableOut = RegWEnable_Stage_4;
	
		//STAGE 3______________________________________________________________________
		//Set OUTPUTS to CPU Hardware (Memory access stage)
		MemRENABLE = MemRead_Stage_3;
		MemWENABLE = MemWrite_Stage_3;
		ALU_ResultOut = ALU_Result;
		WDOut = RD2;
		
		//"Internal" outputs to next pipe stage
		Inst_EX_MEM = Inst_ID_EX;
		RegDSTaddr_Stage_4= RegDSTaddr_Stage_3;
		MemToReg_Stage_4 = MemToReg_Stage_3;
		RegWEnable_Stage_4 = RegWEnable_Stage_3;
		
		
		//STAGE 2_________________________________________________________________
		
		RD1 = RD1in;	//This first bit handles all INPUT/OUTPUT items
		RD2 = RD2in;	//To CPU Hardware
		ALUOpOut = ALUOp;
		ALUSrcOut = ALUSrc;
	
		//This next part handles INTERNAL passes directly to the next pipeline stage
	
		SignXtend[15:0] = Inst_IF_ID[15:0];
		if(SignXtend[15] == 0) begin
			SignXtend[31:16] = 32'h0000;	//Set 0 if non-negative
		end else begin
			SignXtend[31:16] = 32'hFFFF;	//Set all 1's if negative
		end	
		PCP4 = PC_Stage_2;				//PC+4 Delayed 2 cycles
		BranchOut = Branch;					//Branch delayed 1 cycle
		
		if(RegDST == 0) begin
			RegDSTaddr_Stage_3 = Inst_IF_ID[20:16];
		end else begin
			RegDSTaddr_Stage_3 = Inst_IF_ID[15:11];
		end
			//Simple values, stored and passed out
			Inst_ID_EX = Inst_IF_ID;
			MemRead_Stage_3 = MemRead;
			MemWrite_Stage_3 = MemWrite;
			MemToReg_Stage_3 = MemToReg;
			RegWEnable_Stage_3 = RegWEnable;
		//STAGE 2 COMPLETE
			
	
		//STAGE 1 
		PC_Stage_2 = PC+1;
		Inst_IF_ID = Instruction;
		//STAGE 1 COMPLETE
		
	end else if (RESET != 0) begin		//Clear the ENTIRE pipe on Reset
		Inst_IF_ID = 0;
		Inst_ID_EX = 0;
		Inst_EX_MEM = 0;
		Inst_MEM_WB = 0;
		RD1 = 0;
		RD2 = 0;
		SignXtend = 0;
		ALUOpOut = 0;
		ALUSrcOut = 0;
		PCP4 = 0;
		MemRENABLE = 0;
		MemWENABLE = 0;
		BranchOut = 0;
		ALU_ResultOut = 0;
		WDOut = 0;
		MemToRegOut = 0;
		RegDSTaddrOut = 0;
		DataOut = 0;
		RegWEnableOut = 0;
	end else if (IFID_CLR != 0) begin
		Inst_IF_ID = 0;
		Inst_ID_EX = 0;
		RD1 = 0;
		RD2 = 0;
		SignXtend = 0;
		ALUOpOut = 0;
		ALUSrcOut = 0;
		PCP4 = 0;
		MemRENABLE = 0;
		MemWENABLE = 0;
		BranchOut = 0;
		ALU_ResultOut = 0;
		WDOut = 0;
		MemToRegOut = 0;
		RegDSTaddrOut = 0;
		DataOut = 0;
		RegWEnableOut = 0;
	end
end
endmodule
