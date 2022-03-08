`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 05:23:04 PM
// Design Name: 
// Module Name: Lookahead_Logic
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


module Lookahead_Logic_8Bit(
    input  [N:0] A,
    input  [N:0] B,
    input        Cin,
    output [N:0] Cout,
    
    output [3*(N+1)-1:0] Gate
    );
    
    parameter N = 7;
    // Where A ^ B = P, A & B = G
    // Cout[0] = (Cin     & P0) | G0 (3 gates)
    // Cout[1] = (Cout[0] & P1) | G1 (5)
    // Cout[2] = (Cout[1] & P2) | G2 (7)
    // Cout[3] = (Cout[2] & P3) | G3 (9)
    // and so on
    
    wire [N+1:0] Out_FakeWire, P, G, Ands; // N+1, leading 0
    assign P[N+1] = 0;
    assign G[N+1] = 0;
    
    assign Gate = {P[N:0],G[N:0],Ands[N:0]}; // Power Test use
    
    assign #1 P[N:0] = A ^ B;
    assign #1 G[N:0] = A & B;
    
    assign #1 Ands[0] = Cin & P[0];
    assign #1 Ands[N+1:1] = Out_FakeWire[N:0] & P[N+1:1];
    assign #1 Out_FakeWire = Ands | G;
    
    assign Cout = Out_FakeWire[N:0];
    
endmodule
