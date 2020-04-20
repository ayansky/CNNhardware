`include "include.v"
module LB_cl(
input wire clk,
input wire rst,
input wire data_valid,   //LB
input wire [`filterSize*`filterSize*8-1:0] LB1,
input wire [`filterSize*`filterSize*8-1:0] FL,
input wire [3:0] k,   //Conv
output reg rd_en,       //LB
output reg [6:0] rd_addr, // LB
output reg [15:0] regOut,// Conv
output reg output_valid, //Conv
output reg ready         //Conv
);

reg [2:0] state;

reg [`filterSize*`filterSize*8-1:0] newLB1;
integer i,u;
//assign iter = k%3;
localparam IDLE = 3'b000,
		   READ = 3'b001,
		   WAIT =3'b010,
		   UPDATE = 3'b100,
		   MAC = 3'b011;
		   
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
             u=1;
	         rd_en<=1;
			state<=WAIT;
		end
	WAIT:begin
	       rd_en<=0;
		if(data_valid) begin
		newLB1 <=LB1;
		if(k==0) begin
		   regOut <=0;
           state<=MAC;
		   end
          else begin 
          state <= UPDATE;
		 end
		end
		end
    UPDATE:begin
    newLB1 <= {newLB1[`filterSize*8-1:0],newLB1[`filterSize*`filterSize*8-1:`filterSize*8]};
    u <=u+1;
    if(u<k)
      state <= UPDATE;
    else begin
    regOut <=0;
      state <= MAC;
      end
    end
	MAC:begin
	rd_addr<=rd_addr+1;
       for (i=0;i<`filterSize*`filterSize*8-8;i=i+8)
          regOut = regOut+ FL[i+:8]*newLB1[i+:8];
          //regOut[15:0]<= FL[7:0]*newLB1[7:0]+FL[15:8]*newLB1[15:8]+FL[23:16]*newLB1[23:16]+FL[31:24]*newLB1[31:24]+FL[39:32]*newLB1[39:32]+FL[47:40]*newLB1[47:40]+FL[55:48]*newLB1[55:48]+FL[63:56]*newLB1[63:56]+FL[71:64]*newLB1[71:64];
      output_valid<=1;
      if(rd_addr==`sizeLB-`filterSize) begin
        ready <= 1;
        rd_addr<=0;
		state<=IDLE; end
	  else
		state<=READ;
	 end
	endcase
end
 

endmodule