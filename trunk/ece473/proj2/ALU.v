// file: SCALUJ.v
// ALU for Project 1 - Version: 0.1

module ALU(
	ALUSrc,
	ALUOp,
	shamt,
	DataIn1,
	regData2,
	immData2,
	PC,
	jump,
	DataOut,
	Zero);
	
	input ALUSrc, ALUOp, shamt, DataIn1, regData2, immData2,PC,jump;
	output DataOut, Zero;
	
	wire [3:0] ALUOp;
	wire [4:0] shamt;
	wire [31:0] DataIn1;
	wire [31:0] regData2;
	wire [31:0] immData2;
	wire [9:0] PC;
	reg [31:0] DataIn2;
	reg [31:0] Data;
	reg [31:0] DataOut;
	reg Zero;
	
	always @* begin
		if (jump!=0) begin
			DataIn2=PC;
		end else begin
			if (ALUSrc==0) begin
				DataIn2=regData2;
			end else begin
				DataIn2=immData2;
			end
		end
		if(ALUOp==4'h1) begin				//0001 --> add	needs more
			DataOut = DataIn1 + DataIn2;
		end else if(ALUOp==4'h2) begin		//0010 --> addu needs more
			DataOut = DataIn1 + DataIn2;
		end else if(ALUOp==4'h3) begin		//0011 --> sub	needs more
			DataOut = DataIn1 - DataIn2;
		end else if(ALUOp==4'h4) begin		//0100 --> subu needs more
			DataOut = DataIn1 - DataIn2;
		end else if(ALUOp==4'h5) begin		//0101 --> and
			DataOut = DataIn1 & DataIn2;
		end else if(ALUOp==4'h6) begin		//0110 --> or
			DataOut = DataIn1 | DataIn2;
		end else if(ALUOp==4'h7) begin		//0111 --> nor
			DataOut = ~(DataIn1 | DataIn2);
		end else if(ALUOp==4'h8) begin		//1000 --> slt
			if((DataIn2 - DataIn1) > 0) begin
				DataOut = 32'b1;
			end else begin
				DataOut = 32'b0;
			end
		end else if(ALUOp==4'h9) begin		//1001 --> sll
			DataOut = DataIn2 << shamt;
		end else if(ALUOp==4'hA) begin		//1010 --> srl
			DataOut = DataIn2 >> shamt;
		end else if(ALUOp==4'hB) begin		//1011 --> sra	needs more
			DataOut = DataIn2 >>> shamt;
		end else if(ALUOp==4'hC) begin		//1100 --> jr
			DataOut = DataIn1;
		end else if(ALUOp==4'hD) begin		//1101 --> bne inverse zero
			if((DataIn1-DataIn2)==0) begin
				DataOut=32'b1;
			end else begin
				DataOut = 32'b0;
			end
		end else if(ALUOp==4'hE) begin		//1110 --> Does Nothing
			DataOut = 32'b0;
		end else if(ALUOp==4'hF) begin		//1111 --> Does Nothing
			DataOut = 32'b0;
		end else  begin						//0000 --> Does Nothing
			DataOut = 32'b0;
		end
	end
	
	always @* begin
		if(DataOut==32'b0) begin
			Zero=1;
		end else begin
			Zero=0;
		end
	end
endmodule 