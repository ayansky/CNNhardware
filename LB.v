// Line buffer, 28 in width each entity represented by 4 bits

module LB(
input wire clk,
input wire rst,
input wire wr_en,
input wire [799:0] wr_data,
input wire [9:0] rd_addr,
input wire rd_en,
output reg [23:0] rd_data,
output reg data_valid
);

reg [799:0] data;
reg [1:0] state;

localparam IDLE = 2'b00,
		   READ = 2'b01,
		   WRITE =2'b10;

always @(posedge clk)
begin
	case (state)
	IDLE:begin
		data_valid <=0;
		if(wr_en)
			state <= WRITE;
		else if(rd_en)
			state <= READ;
		end
	WRITE:begin
		data <=wr_data;
		data_valid <=1;
		state<=IDLE;
		end
	READ:begin
		rd_data <=data[rd_addr+23:rd_addr];
		data_valid <=1;
		state<=IDLE;
		end
end
endmodule