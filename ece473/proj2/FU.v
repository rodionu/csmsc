// file: FU.v
// ALU for Project 2 - Version: 0.2
// Joel Castro

module FU(
	ID_EX,		// Inst. stored in ID/EX register
	EX_MEM,		// Inst. stored in EX/MEM register
	MEM_WB,		// Inst. stored in MEM/WB register
//	ID_EX_OP,	// Temp. for ID/EX Opcode
//	ID_EX_RS,	// Temp. for ID/EX RS
//	ID_EX_RT,	// Temp. for ID/EX RT
//	ID_EX_RD,	// Temp. for ID/EX RD
//	EX_MEM_OP,	// Temp. for EX/MEM Opcode
//	EX_MEM_RS,	// Temp. for EX/MEM RS
//	EX_MEM_RT,	// Temp. for EX/MEM RT
//	EX_MEM_RD,	// Temp. for EX/MEM RD
//	MEM_WB_OP,	// Temp. for MEM/WB Opcode
//	MEM_WB_RS,	// Temp. for MEM/WB RS
//	MEM_WB_RT,	// Temp. for MEM/WB RT
//	MEM_WB_RD,	// Temp. for MEM/WB RD
//	CHK_W,		// Temp. for Write Add. being compared
	ALU2ALU_RS,	// Mux control for ALU input RS(RAW 1 Stage off)
	ALU2ALU_RT,	// Mux control for ALU input RT(RAW 1 Stage off)
	MEM2ALU_RS,	// Mux control for ALU input RS(RAW 2 Stages off)
	MEM2ALU_RT,	// Mux control for ALU input RT(RAW 2 Stages off)
	CLOCK		// Arbritary Clock Signal
	);
	
	input ID_EX,EX_MEM,MEM_WB,CLOCK;
	output ALU2ALU_RS,ALU2ALU_RT,MEM2ALU_RS,MEM2ALU_RT;
	
	wire CLOCK;
	wire [31:0] ID_EX;
	wire [31:0] EX_MEM;
	wire [31:0] MEM_WB;
	reg [5:0] ID_EX_OP;
	reg [4:0] ID_EX_RS;
	reg [4:0] ID_EX_RT;
	reg [4:0] ID_EX_RD;
	reg [5:0] EX_MEM_OP;
	reg [4:0] EX_MEM_RS;
	reg [4:0] EX_MEM_RT;
	reg [4:0] EX_MEM_RD;
	reg [5:0] MEM_WB_OP;
	reg [4:0] MEM_WB_RS;
	reg [4:0] MEM_WB_RT;
	reg [4:0] MEM_WB_RD;
//	reg [4:0] CHK_W;
	reg ALU2ALU_RS;
	reg ALU2ALU_RT;
	reg MEM2ALU_RS;
	reg MEM2ALU_RT;
	
//	[31:26][25:21][20:16][15:11][10:6][5:0]
	
	always @* begin
		ID_EX_OP  =  ID_EX[31:26];
		ID_EX_RS  =  ID_EX[25:21];
		ID_EX_RT  =  ID_EX[20:16];
		ID_EX_RD   =  ID_EX[15:11];
		EX_MEM_OP =  EX_MEM[31:26];
		EX_MEM_RS =  EX_MEM[25:21];
		EX_MEM_RT =  EX_MEM[20:16];
		EX_MEM_RD  =  EX_MEM[15:11];
		MEM_WB_OP =  MEM_WB[31:26];
		MEM_WB_RS =  MEM_WB[25:21];
		MEM_WB_RT =  MEM_WB[20:16];
		MEM_WB_RD  =  MEM_WB[15:11];
		if((EX_MEM_OP != 6'h02 && EX_MEM_OP != 6'h03)||(MEM_WB_OP != 6'h02 && MEM_WB_OP != 6'h03)) begin	// Forwards not from jump inst.
			if(ID_EX_OP == 6'b0) begin											// if curerent inst. is a R-type
				if(EX_MEM_OP == 6'h00) begin									// and prev. inst. was an R-Type
					if(ID_EX_RS == EX_MEM_RD || ID_EX_RT == EX_MEM_RD) begin	// Check if forward neccesary
						if(ID_EX_RS == EX_MEM_RD) begin			// ALU to ALU Forward for current RS?
							ALU2ALU_RS = 1'b1;
							MEM2ALU_RS = 1'b0;	// if ALU to ALU forward then no MEM to ALU Forward
						end 
						if(ID_EX_RT == EX_MEM_RD) begin			// ALU to ALU Forward for current RT?
							ALU2ALU_RT = 1'b1;
							MEM2ALU_RT = 1'b0;
						end
					end
				end else if(EX_MEM_OP != 6'h02 && EX_MEM_OP != 6'h03) begin		// or if prev. inst. was an I-Type
					if(ID_EX_RS == EX_MEM_RT || ID_EX_RT == EX_MEM_RT) begin	// Check if forward neccesary
						if(ID_EX_RS == EX_MEM_RT) begin			
							ALU2ALU_RS = 1'b1;
							MEM2ALU_RS = 1'b0;
						end 
						if(ID_EX_RT == EX_MEM_RT) begin
							ALU2ALU_RT = 1'b1;
							MEM2ALU_RT = 1'b0;
						end
					end
				end
				if(MEM_WB_OP == 6'b0) begin										// or if 2 stages ago was an R-Type
					if(ID_EX_RS == MEM_WB_RD || ID_EX_RT == MEM_WB_RD) begin	
						if(ID_EX_RS == MEM_WB_RD) begin
							MEM2ALU_RS = 1'b1;
							ALU2ALU_RS = 1'b0;
						end
						if(ID_EX_RT == MEM_WB_RD) begin
							MEM2ALU_RT = 1'b1;
							ALU2ALU_RT = 1'b0;
						end
					end
				end else if(MEM_WB_OP != 6'h02 && MEM_WB_OP != 6'h03) begin		// or if 2 stages ago was an I-Type
					if(ID_EX_RS == MEM_WB_RT || ID_EX_RT == MEM_WB_RT) begin
						if(ID_EX_RS == MEM_WB_RT) begin
							MEM2ALU_RS = 1'b1;
							ALU2ALU_RS = 1'b0;
						end
						if(ID_EX_RT == MEM_WB_RT) begin
							MEM2ALU_RT = 1'b1;
							ALU2ALU_RT = 1'b0;
						end
					end
				end
			end else if(ID_EX_OP != 6'h02 && ID_EX_OP != 6'h03) begin			// If current inst. is an I-Type
				if(EX_MEM_OP == 6'h00) begin									// and prev. inst. was an R-Type
					if(ID_EX_RS == EX_MEM_RD) begin
						ALU2ALU_RS = 1'b1;
						MEM2ALU_RS = 1'b0;
					end 
				end else if(EX_MEM_OP != 6'h02 && EX_MEM_OP != 6'h03) begin		// or prev. inst. was an I-Type as well
					if(ID_EX_RS == EX_MEM_RT) begin
						ALU2ALU_RS = 1'b1;
						MEM2ALU_RS = 1'b0;
					end 
				end
				if(MEM_WB_OP == 6'b0) begin										// or if 2 stages ago was an R-Type
					if(ID_EX_RS == MEM_WB_RD) begin
						MEM2ALU_RS = 1'b1;
						ALU2ALU_RS = 1'b0;
					end
				end else if(MEM_WB_OP != 6'h02 && MEM_WB_OP != 6'h03) begin		// or if 2 stages ago was an I-Type
					if(ID_EX_RS == MEM_WB_RT) begin
						MEM2ALU_RS = 1'b1;
						ALU2ALU_RS = 1'b0;
					end
				end
			end
		end	
	end
endmodule