//file reginterface.v

module registermem(
input wire [4:0] RN1,	//rs
input wire [4:0] RN2,	//rt
input wire [4:0] WN,	//rd (mux with RegDst)
input wire [31:0] WD,	//Write Data
input wire regwrite,	//Register write enable
output reg [31:0] RD1,	//Output 1 to ALU
output reg [31:0] RD2);	//Output 2 to ALU

integer r[0:31]; // All registers

always @* begin

RD1 = r[RN1];
RD2 = r[RN2];
WN = r[WN];