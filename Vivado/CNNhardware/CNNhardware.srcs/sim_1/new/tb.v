`timescale 1ns / 1ps
`define Period 5

module tb();

reg clk;
reg rst;
reg [799:0] ram1;
reg [799:0] ram2;
reg [799:0] ram3;
reg [71:0] FL;
reg [2:0] wr_en;

wire [1:0] k;
wire [1567:0] regOut;
wire output_valid;

initial
begin 
    clk = 0;
    forever
    begin
        clk = ~clk;
        #(`Period/2);
      end
end
        
initial 
begin 
ram1 = {{50{8'h1}},{50{8'h0}}};
ram2 = {{50{8'h1}},{50{8'h0}}};
ram3 = {{50{8'h1}},{50{8'h0}}};
FL = {{3{8'h1}},{3{8'h0}},{3{8'h1}}};
end


initial 
begin 
@(posedge clk);
wr_en = 3'b111;
@(posedge clk);
wr_en = 0;
@(posedge clk);


end

Conv conv1(
.clk(clk),
.rst(rst),
.ram1(ram1),
.ram2(ram2),
.ram3(ram3),
.FL(FL),
.wr_en(wr_en),
.k(k),
.regOut(regOut),
.output_valid(output_valid)
);


endmodule
