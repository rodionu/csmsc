// file: SCControlJ2.v
// Controller for Project 1 - Version: 0.2

module SCControlJ2(
    opcode,
    shamt,
    func,
    zero,
    RESET,
    CLOCK,
    RegDst,
    ALUSrc,
    MemtoReg,
    RegWrite,
    MemRead,
    MemWrite,
    PCSrc,
    ALUOp);

    input opcode, shamt, func, zero, RESET, CLOCK;
    output RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, PCSrc, ALUOp;

    wire [5:0] opcode;
    wire [4:0] shamt;
    wire [5:0] func;
    reg RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, PCSrc;
    reg [3:0] ALUOp;

    always @(posedge CLOCK) begin
        if(opcode == 6'b0) begin
			if(shamt==5'b0 && func==6'h00) begin	//nop
				RegWrite=1'b0;
				ALUOp=4'h9;
			end else begin
				RegWrite=1'b1;
			end
            RegDst=1'b1;
            ALUSrc=1'b0;
            MemtoReg=1'b0;
//          RegWrite=1'b1;
            MemRead=1'b0;
            MemWrite=1'b0;
            PCSrc=1'b0;
			if(func==6'h20) begin			//add
				ALUOp=4'h1;
			end else if(func==6'h21) begin	//addu
				ALUOp=4'h2;
			end else if(func==6'h22) begin	//sub
				ALUOp=4'h3;
			end else if(func==6'h23) begin	//subu
				ALUOp=4'h4;
			end else if(func==6'h24) begin	//and
				ALUOp=4'h5;
			end else if(func==6'h25) begin	//or
				ALUOp=4'h6;
			end else if(func==6'h27) begin	//nor
				ALUOp=4'h7;
			end else if(func==6'h2A) begin	//slt
				ALUOp=4'h8;
			end else if(shamt>5'b0 && func==6'h00) begin	//sll
				ALUOp=4'h9;
			end else if(shamt>5'b0 && func==6'h02) begin	//srl
				ALUOp=4'hA;
			end else if(shamt>5'b0 && func==6'h03) begin	//sra
				ALUOp=4'hB;
			end else if(func==6'h08) begin	//jr
				ALUOp=4'hC;
			end
        end else if(opcode==6'b10 || opcode==6'b11) begin
            //Jump instructions here
        end else begin
			RegDst=1'b0;
			ALUSrc=1'b1;
			MemtoReg=1'b0;
			RegWrite=1'b1;
			MemRead=1'b0;
			MemWrite=1'b0;
			PCSrc=1'b0;
			if(opcode==6'h0C) begin			//andi
				ALUOp=4'h5;
			end else if(opcode==6'h0D) begin	//ori
				ALUOp=4'h6;
			end else if(opcode==6'h0A) begin	//slti
				ALUOp=4'h8;
			end else if(opcode==6'h08) begin	//addi
				ALUOp=4'h1;
			end else if(opcode==6'h09) begin	//subi
				ALUOp=4'h3;
			end else if(opcode==6'h04) begin	//beq
				ALUSrc=1'b0;
				RegWrite=1'b0;
				ALUOp=4'h3;
				if(zero==1) begin
					PCSrc=1'b1;
				end
			end else if(opcode==6'h05) begin	//bne
				ALUSrc=1'b0;
				RegWrite=1'b0;
				ALUOp=4'h3;
				if(zero==0) begin
					PCSrc=1'b1;
				end 
			end else if(opcode==6'h22) begin	//lw
				MemtoReg=1'b1;
				MemRead=1'b1;
				ALUOp=4'h1;
			end else if(opcode==6'h2B) begin	//sw
				RegWrite=1'b0;
				MemWrite=1'b1;
				ALUOp=4'h1;
			end else if(opcode==6'h0F) begin	//lui
				MemRead=1'b1;
				ALUOp=4'h6;
			end
        end
    end
endmodule
