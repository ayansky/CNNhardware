module Conv(
input wire clk,
input wire rst,
input wire [799:0] ram1,
input wire [799:0] ram2,
input wire [799:0] ram3,
input wire [71:0] FL,
input wire [2:0] wr_en,
output wire [1:0] k,
output wire [1567:0] regOut,
output wire output_valid
);

wire data_valid1;
wire data_valid2;
wire data_valid3;
wire data_valid;
wire rd_en;
wire [9:0] rd_addr;
wire [23:0] rd_data1;
wire [23:0] rd_data2;
wire [23:0] rd_data3;


assign data_valid = data_valid1 & data_valid2 & data_valid3;

LB LB1(
.clk(clk),
.rst(rst),
.wr_en(wr_en[0]),
.wr_data(ram1),
.rd_addr(rd_addr),
.rd_en(rd_en),
.rd_data(rd_data1),
.data_valid(data_valid1)
);

LB LB2(
.clk(clk),
.rst(rst),
.wr_en(wr_en[1]),
.wr_data(ram2),
.rd_addr(rd_addr),
.rd_en(rd_en),
.rd_data(rd_data2),
.data_valid(data_valid2)
);

LB LB3(
.clk(clk),
.rst(rst),
.wr_en(wr_en[2]),
.wr_data(ram3),
.rd_addr(rd_addr),
.rd_en(rd_en),
.rd_data(rd_data3),
.data_valid(data_valid3)
);


LB_cl LB_control(
.clk(clk),
.rst(rst),
.data_valid(data_valid),
.LB1(rd_data1),
.LB2(rd_data2),
.LB3(rd_data3),
.FL(FL),
.rd_en(rd_en),
.rd_addr(rd_addr),
.k(k),
.regOut(regOut),
.output_valid(output_valid)
);



endmodule