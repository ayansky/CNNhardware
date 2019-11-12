`timescale 1ns / 1ps
`define Period 5

module tb();

reg clk;
reg rst;
reg [71:0] FL;
reg [31:0] data_in;
reg valid;
wire [15:0] regOut;
wire ready;
wire out_valid;

Conv2D Conv(
.clk(clk),
.rst(rst),
.data(data_in),
.Fl(FL),
.valid(valid),
.out_data(regOut),
.out_valid(out_valid),
.data_in_en(ready)
);





`define read_fileName "C:\\Users\\marzh\\Desktop\\CNNhardware\\Vivado\\cnnCopy\\lena512.bmp"
 localparam ARRAY_LEN =11078; //500*1024;
 
 reg[7:0] data[0: ARRAY_LEN];
 integer size, start_pos, width, height, bitcount;

task readBMP;
     integer fileID;
 //    integer i;
     begin
         fileID = $fopen(`read_fileName, "rb");
         $display("%d", fileID);
         if(fileID == 0) begin
             $display("Error: Please check file path");
             $finish;
         end else begin
             $fread(data, fileID);
             $fclose(fileID);
         
             size = {data[5],data[4],data[3],data[2]};
             $display("size - %d", size);
             start_pos = {data[13],data[12],data[11],data[10]};
             $display("startpos : %d", start_pos);
             width = {data[21],data[20],data[19],data[18]};
             height = {data[25],data[24],data[23],data[22]};
             $display("width - %d; height - %d",width, height );
         
             bitcount = {data[29],data[28]};
         
             if(bitcount != 8) begin
                 $display("Error: Please check the image file. It may be corrupted");
             end
         
             if(width%4)begin
                 $display("width is not suitable");
                 $finish;
             end
           //for(i = start_pos; i<size;i = i+1)begin
                 //$display("%h", data[i]);
            //end
        end
     end
 endtask
 // Image read complete


integer i, j;
 localparam RESULT_ARRAY_LEN = 98*98*2+1078;//5000*1024;
 
 reg[7:0] result[0:RESULT_ARRAY_LEN - 1];
//Image Write Start
 
 `define write_filename "C:\\Users\\marzh\\Desktop\\CNNhardware\\Vivado\\cnnCopy\\Result.bmp"
 
task writeBMP;
integer fileID, k;
 begin
     fileID = $fopen(`write_filename, "wb");
     
     for(k = 0; k < start_pos; k = k+1)begin
         $fwrite(fileID, "%c", data[k]);
     end
    
     
     for(k = start_pos; k<20286; k = k+1)begin
         $fwrite(fileID, "%c", result[k-start_pos]);
     end
     
     $fclose(fileID);
     $display("Result.bmp is generated \n");
 end
endtask
 
 //Image Write ends

/*
event ready_data_in;
event ready_out;

always @(posedge clk) begin
    if(rst) begin
        j<=8'b0;
    end else if(out_valid) begin
        ->ready_out;
    end
end

always @(ready_out) begin
        result[j] <= regOut[15:8];
        result[j+1] <= regOut[7:0];
        j<=j+2; 
end

always @(posedge clk) begin
    if(rst) begin
        i<=start_pos;end
    else if(ready)
        ->ready_data_in;
end

always @(ready_data_in) begin
    data_in <= {data[i+3],data[i+2],data[i+1],data[i]};
    i<=i+4; 
end
*/
initial
begin
       j<=8'b0;
       end

always @(posedge clk) begin
    //if(rst) begin
        //j<=8'b0;
    //end else begin
        if(out_valid) begin
        result[j] <= regOut[15:8];
        result[j+1] <= regOut[7:0];
        j<=j+2; end
end

       
always begin
     #5 clk = ~clk;
end



initial begin
    clk = 1;
    rst=1;
    valid = 1;
    FL = {8'h1,8'h0,8'h1,
          8'h1,8'h0,8'h1,
          8'h1,8'h0,8'h1};
    
    
    readBMP;
    
    rst = 0;
    
    for(i = start_pos; i < size; i = i+4)begin
        wait(ready);             
        data_in <= {data[i+3],data[i+2],data[i+1],data[i]};
    end
    
    
    #1000000;
    #10;
    writeBMP;  
    #10;
    $stop;
    
end
endmodule
