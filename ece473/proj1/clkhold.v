// By John Murray
//A reset hold. This block will hold a value until the next clock cycle. 

module clkhold(
			input wire val,
			input wire CLOCK,
			output reg out			
		);
		
		
		always @(posedge CLOCK) begin
			if(val) begin
				out=val;
			end else begin
				out=0;
			end
		end
	endmodule