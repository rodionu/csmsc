//Clock Counter

module counter (
input wire clock ,
input wire reset ,
output reg [15:0] counter_out 
); 
initial begin
	counter_out=1;
end
always @(posedge clock) begin
   if (reset) begin
     counter_out = 0;
   end else begin
     counter_out =  counter_out + 1;
   end
 end

endmodule
