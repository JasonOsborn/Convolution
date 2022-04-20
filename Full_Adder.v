`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2022 03:06:18 PM
// Design Name: 
// Module Name: Full_Adder
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


module Full_Adder(
    input  A,
    input  B,
    input  Cin,
    output S,
    output Cout,
    
    output [2:0]Gate
    );
    
    assign #1 Gate[0] = A ^ B;
    assign #1 Gate[1] = A & B;
    assign #1 Gate[2] = Gate[0] & Cin;
    
    assign #1 S = Gate[0] ^ Cin;
    assign #1 Cout = Gate[1] | Gate[2];
endmodule
