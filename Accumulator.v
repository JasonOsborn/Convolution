`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2022 01:54:40 PM
// Design Name: 
// Module Name: Accumulator
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


module Accumulator(
    input Clk,
    input [31:0] AddIn,
    
    input AccumReset,
    output Holder,
    output reg AccumDone = 0
    );
    
    reg [31:0] LocalReg = 0;
//    wire [31:0] Holder;
    
    dum_add Adder(.A(AddIn),.B(LocalReg),.S(Holder));
    
    // A + B = S, always
        // We only care when clock & when we're supposed to be adding
    
    always@(posedge Clk)
        if(!(AccumDone | AccumReset))
            {LocalReg,AccumDone} <= {Holder,1'b1};
        else
            {LocalReg,AccumDone} <= 0;
endmodule
