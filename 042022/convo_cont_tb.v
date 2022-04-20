`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2022 03:34:08 PM
// Design Name: 
// Module Name: convo_cont_tb
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


module convo_cont_tb;
    //inputs
    reg Clk;
    reg [31:0] ImageAddress;
    reg [31:0] kernelAddress;
    reg [31:0] kernelSize;
    reg [500:0] data;
    
    //Instantiate Unit Under Test
    convo_cont uut(
        .Clk(Clk),
        .ImageAddress(ImageAddress),
        .kernelAddress(kernelAddress),
        .kernelSize(kernelSize),
        .data(data)
    );
    
    initial begin
        Clk = 0;
        ImageAddress = 0;
        kernelAddress = 0;
        kernelSize = 0;
        data = 0;
        
        #50;
        
    end
    
    always #5 Clk = ~Clk;
endmodule
