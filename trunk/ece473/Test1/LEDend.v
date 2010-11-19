	module LEDend(
			Val,
			done	
		);
		input Val;
		output done;
		
		reg [17:0] done;
		
		
		always @* begin
			if(Val) begin
				done=18'b111111111111111111;
			end else begin
				done=18'b000000000000000000;
			end
		end
	endmodule
