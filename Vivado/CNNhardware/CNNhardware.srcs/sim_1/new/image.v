`timescale 1ns / 1ps
`define Period 5

module image(

    );

wire [99:0] memOut;
reg clk;
    initial
    begin 
        clk = 0;
        
        forever
        begin
            clk = ~clk;
            #(`Period/2);
          end
    end 
  
imMem im  (
.clk(clk),
.x(0),
.out(memOut)
 );  
    
endmodule
