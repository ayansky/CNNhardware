`timescale 1ns / 1ps
`include "include.v"
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
input wire [15:0] data,
input wire [`filterSize*`filterSize*8-1:0] Fl,
input wire valid,
output reg [15:0] out_data,
output reg out_valid,
output reg data_in_en
);

reg all_data_valid;
reg [3:0] k;
wire rd_en;
wire [6:0] rd_addr;
wire output_valid;
wire [15:0] regOut;

reg [`filterSize-1:0] wr_en=`filterSize'b0; 
wire [`filterSize*`filterSize*8-1:0] rd_data;
wire [`filterSize-1:0] data_valid;
wire [`filterSize-1:0] full_LB;
wire [`filterSize*7-1:0] wr_addr;

integer iter,wr;
reg [2:0] state;
wire ready;



localparam IDLE = 3'b000,
		   WRITE_ALL = 3'b010,
		   WAIT =3'b001,
		   REPLACE = 3'b011,
		   READY =3'b100,
		   Wait1 =3'b111;
initial begin
    iter = 0;
    state <= IDLE;
end

always @(posedge clk) begin
    case(state)
    IDLE:begin
        data_in_en <= 0;
        all_data_valid <= 0;
        wr =0;
        state <= WRITE_ALL;
    end
    WRITE_ALL: begin
          // for(wr=0; wr<`filterSize*7-1;wr =wr+7) begin
              if(wr_addr[wr+:7]==`sizeLB-2 ) begin
              $display("ENTERED IF IN FOR LOOP CONV");
              if(wr<`filterSize*7-7)
              wr_en[wr/7+1] <=1;
               data_in_en <= 0;
               wr <=wr+7;
              state <=WRITE_ALL;
              end
              else if(!full_LB[wr/7]) begin
                          wr_en <=2**(wr/7);
                          data_in_en <= 1;
                          state <=WRITE_ALL;
                      end
                    
          //state <= WRITE_OK;
                else begin
                   $display("All buffers full go to WAIT");
                  data_in_en <= 0;
                  wr_en[wr/7-1] <= 0;
                  all_data_valid <=1;
                  state <= WAIT; end 
            
    end

    WAIT:begin
        out_valid <=0; 
        k <= iter%`filterSize;
        data_in_en <=0;
        wr_en <= 0; 
         //if (data_valid[0] & data_valid[1] & data_valid[2]) begin
         all_data_valid <=&data_valid;
         //end
         //else
         //all_data_valid <=0;
         if (output_valid) begin
         $display("Conv performed for iteration ", iter);
             all_data_valid <=0;
             out_valid <=1;
             out_data <= regOut; end
         //else
            //all_data_valid <=1;
         if (ready) begin
             //out_valid <=0;
              $display("Ready to replace");
             if(iter<`sizeLB)
             begin
             state <= REPLACE;
             iter <= iter +1;
             end
             end
    end
    REPLACE: begin 
    out_valid <=0;
        if(iter%`filterSize!=0 & wr_addr[(iter%`filterSize-1)*7+:7]==`sizeLB-2)
        begin 
          $display("Goes to wait after replacing, iter", iter);
           $display("wr_addr0",wr_addr[6:0]);
           $display("wr_addr1",wr_addr[13:7]);
           $display("wr_addr2",wr_addr[20:14]);
           $display("wr_addr3",wr_addr[27:21]);
           $display("wr_addr4", wr_addr[34:28]);
            state<= WAIT;
            data_in_en <=0;
            all_data_valid <=1;
        end
        else if(iter%`filterSize==0) begin
        if(wr_addr[(`filterSize-1)*7+:7]==`sizeLB-2)begin
            $display("Goes to wait after replacing, iter", iter);
            state<= WAIT;
            data_in_en <=0;
            all_data_valid <=1;
        end
           else if(!full_LB[`filterSize-1]) begin
                      if(wr_addr[(`filterSize-1)*7+:7] ==0)
                        state<= READY;
                        else 
                        state<= REPLACE;
                    wr_en <= 2**(`filterSize-1) ;
                    end
            else 
            begin
            state<= WAIT;
            data_in_en <=0;
            all_data_valid <=1;
            end
        end
        else  begin
                    if(!full_LB[`filterSize-1-iter%`filterSize]) begin
                    if(wr_addr[(iter%`filterSize-1)*7+:7] ==0)
                     state<= READY;
                     else 
                     state<= REPLACE;
                            wr_en<=2**(iter%`filterSize-1);
                    end
                    else 
                    begin
                    state<= WAIT;
                    data_in_en <=0;
                    all_data_valid <=1;
                    end
                end             
    
    end
    READY:begin
     data_in_en <=1;
     state<= REPLACE;
    end
    endcase
end


 

 
 genvar i;
 generate 
 for(i =0; i<`filterSize; i =i+1)
 begin: lineBuffer
LB LB1(
 .clk(clk),
 .rst(rst),
 .wr_en(wr_en[i]),
 .wr_data(data),
 .rd_en(rd_en),
 .rd_addr(rd_addr),
 .rd_data(rd_data[i*`filterSize*8+:8*`filterSize]),
 .data_valid(data_valid[i]),
 .full(full_LB[i]),
 .wr_addr(wr_addr[i*7+:7])
 );
  end
 endgenerate
 

LB_cl LBCL(
.clk(clk),
.rst(rst),
.data_valid(all_data_valid),   //LB
.LB1(rd_data),
.FL(Fl),
.k(k),   //Conv
.rd_en(rd_en),       //LB
.rd_addr(rd_addr), // LB
.regOut(regOut),// Conv
.output_valid(output_valid), //Conv
.ready(ready)         //Conv
);


endmodule
