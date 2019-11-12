// Line buffer, 28 in width each entity represented by 4 bits

module LB(
input wire clk,
input wire rst,
input wire wr_en,
input wire [31:0] wr_data,
input wire rd_en,
input wire [6:0] rd_addr,
output reg [23:0] rd_data,
output reg data_valid,
output reg full
);

reg [7:0] mem [99:0];
reg [1:0] state;
reg [6:0] wr_addr;

localparam IDLE = 2'b00,
		   READ = 2'b10,
		   WRITE =2'b01;
		   
initial begin
    state<=IDLE;   
    wr_addr <= 0;
    full <= 0;
    data_valid <=0;
end

always @(posedge clk)
begin
	case (state)
	IDLE:begin
		
		if(wr_en)
			state <= WRITE;
		else if(rd_en)
			state <= READ;
		end
	WRITE:begin
	    mem[wr_addr] <= wr_data[7:0];
	    mem[wr_addr+1] <= wr_data[15:8];
	    mem[wr_addr+2] <= wr_data[23:16];
	    mem[wr_addr+3] <= wr_data[31:24];
	    if (wr_addr==96) begin
	       full <= 1;
	       wr_addr <=0;
	       data_valid <=1;
	    end else begin
	       wr_addr<=wr_addr+4;
		end
		state<=IDLE;
		end
	READ:begin
		rd_data[7:0] <= mem[rd_addr];
		rd_data[15:8] <= mem[rd_addr+1];
		rd_data[23:16] <= mem[rd_addr+2];
		
		full <= 0;
		state<=IDLE;
		end
	endcase
end
endmodule