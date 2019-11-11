`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2019 02:20:50 PM
// Design Name: 
// Module Name: imMem
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
module imMem #(parameter inWidth=5, dataWidth=100) (
    input           clk,
    input   [inWidth-1:0]   x,
    output  [dataWidth-1:0]  out
    );
    
    reg [dataWidth-1:0] mem [inWidth-1:0];
    reg [inWidth-1:0] y;
	
	initial
	begin
		$readmemb("image.mif",mem);
	end
    

   assign out = mem[2];
    
endmodule


