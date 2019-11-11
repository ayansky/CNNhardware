`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2019 12:28:26 AM
// Design Name: 
// Module Name: Conv2D
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Conv2D(
input wire clk,
input wire rst,
input wire [31:0] data,
input wire [71:0] Fl,
input wire valid,
output reg [15:0] out_data,
output reg out_valid,
output reg data_in_en
);

reg all_data_valid;
wire data_valid_1;
wire data_valid_2;
wire data_valid_3;
wire [23:0] rd_data_1;
wire [23:0] rd_data_2;
wire [23:0] rd_data_3;
reg [1:0] k;
wire rd_en;
wire rd_addr;
wire output_valid;
wire [15:0] regOut;
wire full_LB_1;
wire full_LB_2;
wire full_LB_3;
reg wr_en_1;
reg wr_en_2;
reg wr_en_3;
integer iter;
reg [2:0] state;
wire ready;

localparam IDLE = 2'b00,
		   WRITE_ALL = 2'b10,
		   WAIT =2'b01,
		   REPLACE = 2'b11;

initial begin
    iter = 0;
end

always @(posedge clk) begin
    case(state)
    IDLE:begin
        data_in_en <= 1;
    end
    WRITE_ALL: begin
        if(!full_LB_1) begin
            wr_en_1 <= 1;
            wr_en_2 <= 0;
            wr_en_3 <= 0;
        end else if(!full_LB_2) begin
            wr_en_1 <= 0;
            wr_en_2 <= 1;
            wr_en_3 <= 0;
        end else if(!full_LB_3) begin
            wr_en_1 <= 0;
            wr_en_2 <= 0;
            wr_en_3 <= 1;
        end else
            state <= WAIT;
    end
    WAIT:begin
        out_valid <=0; 
        k <= iter%3;
        data_in_en <=0;
        if (data_valid_1 & data_valid_2 & data_valid_3) begin
            all_data_valid <=1;
            if (output_valid) begin
                out_valid <=1;
                out_data <= regOut; end
            if (ready) begin
                data_in_en <=1;
                state <= REPLACE;
                iter <= iter +1;
                end
        end else begin
            all_data_valid <=0; end
    end
    REPLACE: begin 
        if(iter%3==0) begin
            if(!full_LB_3) begin
                    wr_en_1 <= 0;
                    wr_en_2 <= 0;
                    wr_en_3 <= 1;
            end
            else
             state<= WAIT;
        end
        else if(iter%3==1) begin
            if(!full_LB_1) begin
                    wr_en_1 <= 1;
                    wr_en_2 <= 0;
                    wr_en_3 <= 0;
            end
            else
              state<= WAIT;
        end
        else if(iter%3==2) begin
            if(!full_LB_1) begin
                    wr_en_1 <= 0;
                    wr_en_2 <= 1;
                    wr_en_3 <= 0;
            end
            else 
                state<= WAIT;
        end       
    
    end
    endcase
end

		   




LB LB1(
.clk(clk),
.rst(rst),
.wr_en(wr_en_1),
.wr_data(data),
.rd_en(rd_en),
.rd_addr(rd_addr),
.rd_data(rd_data_1),
.data_valid(data_valid_1),
.full(full_LB_1)
);

LB LB2(
.clk(clk),
.rst(rst),
.wr_en(wr_en_2),
.wr_data(data),
.rd_en(rd_en),
.rd_addr(rd_addr),
.rd_data(rd_data_2),
.data_valid(data_valid_2),
.full(full_LB_2)
);

LB LB3(
.clk(clk),
.rst(rst),
.wr_en(wr_en_2),
.wr_data(data),
.rd_en(rd_en),
.rd_addr(rd_addr),
.rd_data(rd_data_3),
.data_valid(data_valid_3),
.full(full_LB_3)
);


LB_cl LBCL(
.clk(clk),
.rst(rst),
.data_valid(all_data_valid),   //LB
.LB1(rd_data_1),
.LB2(rd_data_2),
.LB3(rd_data_3),
.FL(Fl),
.k(k),   //Conv
.rd_en(rd_en),       //LB
.rd_addr(rd_addr), // LB
.regOut(regOut),// Conv
.output_valid(output_valid), //Conv
.ready(ready)         //Conv
);


endmodule
