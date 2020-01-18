module LB_cl(
input wire clk,
input wire rst,
input wire data_valid,   //LB
input wire [23:0] LB1,
input wire [23:0] LB2,
input wire [23:0] LB3,
input wire [71:0] FL,
input wire [1:0] k,   //Conv
output reg rd_en,       //LB
output reg [6:0] rd_addr, // LB
output reg [15:0] regOut,// Conv
output reg output_valid, //Conv
output reg ready         //Conv
);

reg [1:0] state;
reg [23:0] regA;
reg [23:0] regB;
reg [23:0] regC;

//assign iter = k%3;
localparam IDLE = 2'b00,
		   READ = 2'b01,
		   WAIT =2'b10,
		   MAC = 2'b11;
		   
initial begin
	rd_en<=0;
    state<=IDLE;
    regOut<=0;
      rd_addr<=0;
end

always @(posedge clk)
begin
	case (state)
	IDLE:begin
        ready <= 0;
        output_valid<=0;
		if(data_valid) begin
         ready <= 0;
		 state<=READ;
		 output_valid<=0; end
	   end
	READ:begin
	         output_valid<=0;
	         rd_en<=1;
			state<=WAIT;
		end
	WAIT:begin
	       rd_en<=0;
		if(data_valid) begin
		   if(k==0) begin
		    regA <= LB1;
			regB <= LB2;
			regC <= LB3; end
		   else if(k==1) begin
			regA <= LB2;
			regB <= LB3;
			regC <= LB1; end
		   else if(k==2) begin
			regA <= LB3;
            regB <= LB1;
			regC <= LB2; end			
		   state<=MAC;
		 end
		end
	MAC:begin
	rd_addr<=rd_addr+1;
      regOut[15:0]<=(regA[23:16]*FL[23:16] + regA[15:8]*FL[15:8] + regA[7:0]*FL[7:0]+regB[23:16]*FL[47:40]+  regB[15:8]*FL[39:32] + regB[7:0]*FL[31:24]+ regC[23:16]*FL[71:64] +regC[15:8]*FL[63:56] + regC[7:0]*FL[55:48]) ;
      output_valid<=1;
      if(rd_addr==97) begin
        ready <= 1;
        rd_addr<=0;
		state<=IDLE; end
	  else
		state<=READ;
	 end
	endcase
end
endmodule