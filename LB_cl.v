module LB_cl(
input wire clk,
input wire rst,
input wire data_valid,
input wire [23:0] LB1,
input wire [23:0] LB2,
input wire [23:0] LB3,
input wire [71:0] FL,
output reg rd_en,
output reg [9:0] rd_addr,
output reg [1:0] k,
output reg [1567:0] regOut,
output reg output_valid
);

reg [1:0] state;
reg [23:0] regA;
reg [23:0] regB;
reg [23:0] regC;


initial begin
	k<=0;
	rd_en<=0;

end

localparam IDLE = 2'b00,
		   READ = 2'b01,
		   WAIT =2'b10;
		   MAC = 2'b11;

always @(posedge clk)
begin
	case (state)
	IDLE:begin
		if(data_valid)
			begin
				rd_addr<=0;
				state<=READ;
				output_valid<=0;
			end
		end
	READ:begin
			rd_en<=1;
			state<=WAIT;
		end
	WAIT:begin
		if(data_valid)
			begin
				rd_addr<=rd_addr+8;
				rd_en<=0;
					if(k==0)
					begin 
						regA <= LB1;
						regB <= LB2;
						regC <= LB3;
					end
					else if(k==1)
					begin 
						regA <= LB3;
						regB <= LB1;
						regC <= LB2;
					end
					else if(k==2)
					begin 
						k <=0;
						regA <= LB2;
						regB <= LB3;
						regC <= LB1;
					end
					state<=MAC;
			end
		end
		MAC:begin
			regOut[2*rd_addr+15:2*rd_addr]<=regA*FL[23:0] + regB*FL[47:24]+regC*FL[71:48];
			if(rd_addr==799)
			begin
				k<=k+1;
				output_valid<=1;
				state<=IDLE;
			end
			else
				state<=READ;
		end
end
endmodule