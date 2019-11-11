module Conv(
input wire clk,
input wire rst,
input wire [31:0] data,
input wire [71:0] Fl,
input wire wr_en,
output ready
//output wire [31:0] regOut,
//output reg output_valid
);

wire data_valid1;
wire data_valid2;
wire data_valid3;
reg data_valid;
wire out_valid;
wire [15:0] out_data;
wire rd_en;
wire [9:0] rd_addr;
wire [23:0] rd_data1;
wire [23:0] rd_data2;
wire [23:0] rd_data3;
reg counter;
wire [1:0] k;
reg wr_en1;
reg wr_en2;
reg wr_en3;

initial begin
    counter<=0;     
end

always @(posedge clk)
begin
    data_valid = data_valid1 & data_valid2 & data_valid3;
    if(wr_en)
    begin
		if(k==0)
		begin
			if(counter<25)
			begin
				wr_en1 <= 1;
				wr_en2 <= 0;
				wr_en3 <= 0;
			end
			else if(counter<50)
			begin
				wr_en1 <= 0;
				wr_en2 <= 1;
				wr_en3 <= 0;
			end
			else if(counter<75)
			begin
				wr_en1 <= 0;
				wr_en2 <= 0;
				wr_en3 <= 1;
			end
			else if(counter==75)
			begin
				counter <= 0;
				data_valid <=1;
			end
			counter <= counter+1;
		end
		else if(k==1)
		begin
			wr_en1 <= 1;
			wr_en2 <= 0;
			wr_en3 <= 0;
      if(counter == 25)
        begin
          counter <= 0;
          data_valid <= 1;
        end
      counter <= counter+1;
		end
		
		else if(k==2)
		begin
			wr_en1 <= 0;
			wr_en2 <= 1;
			wr_en3 <= 0;
      if(counter == 25)
        begin
          counter <= 0;
          data_valid <= 1;
        end
      counter <= counter+1;
		end
		
		else if(k==3)
		begin
      if(counter == 25)
        begin
          counter <= 0;
          data_valid <= 1;
        end
      counter <= counter+1;
			wr_en1 <= 0;
			wr_en2 <= 0;
			wr_en3 <= 1;
		end
        
    end
end




LB LB1(
.clk(clk),
.rst(rst),
.wr_en(wr_en1),
.wr_data(data),
.rd_en(rd_en),
.rd_addr(rd_addr),
.rd_data(rd_data1),
.data_valid(data_valid1)
);

LB LB2(
.clk(clk),
.rst(rst),
.wr_en(wr_en2),
.wr_data(data),
.rd_en(rd_en),
.rd_addr(rd_addr),
.rd_data(rd_data2),
.data_valid(data_valid1)
);

LB LB3(
.clk(clk),
.rst(rst),
.wr_en(wr_en3),
.wr_data(data),
.rd_en(rd_en),
.rd_addr(rd_addr),
.rd_data(rd_data3),
.data_valid(data_valid1)
);



LB_cl LBCL(
.clk(clk),
.rst(rst),
.data_valid(data_valid),
.LB1(rd_data1),
.LB2(rd_data2),
.LB3(rd_data3),
.FL(Fl),
.rd_en(rd_en),
.rd_addr(rd_addr),
.k(),
.regOut(out_data),
.output_valid(out_valid),
.ready(ready)
);


endmodule