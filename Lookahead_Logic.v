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

module Lookahead_Logic_8Bit #(parameter N = 7)(
    input  [N:0] A,
    input  [N:0] B,
    input        Cin,
    output [N:0] Cout,
    
    output [3*(N+1)-1:0] Gate
    );
    
    // Where
    // A ^ B = P
    // A & B = G
    // Cout[0] = ((Cin & P0) | G0)
    // Cout[1] = ((((Cin & P0) | G0) & P1) | G1)
    // Cout[2] = ((((((Cin & P0) | G0) & P1) | G1) & P2) | G2)
    // Cout[3] = (((((((Cin & P0) | G0) & P1) | G1) & P2) | G2) & P3) | G3
    // and so on
    
    // Cout0 = G0 + P0*Cin
    // Cout1 = G1 + P1*Cout0
        // Cout1 = G1 + P1*G0 + P1*P0*Cin
    // Cout2 = G2 + P2*Cout1
        // Cout2 = G2 + P2*G1 + P2*P1*G0 + P2*P1*P0*Cin
    // Cout3 = G3 + P3*Cout2
        // Cout3 = G3 + P3*G2 + P3*P2*G1 + P3*P2*P1*G0 + P3*P2*P1*P0*Cin
    
    
    // Power Consumption signals
    reg [N:0] InWorkMem = 0;
    assign Gate = {P,G,InWorkMem}; // N+1, N+1, N+1 = 3N+3
    
    // Signals
    wire [N:0] P, G;
    wire [N+1:0] G_Work;
    reg [N:0] C = 0, InnerWorks = 0, InnerWorks2 = 0;
    
    assign #1 P = A ^ B; // 1 sim gate delay
    assign #1 G = A & B; // 1 sim gate delay
    assign G_Work = {G,Cin};
    
    integer i = 0,j = 0, k = 0;
    
    assign #2 Cout = C; // 2 layer * 2 sim gate delay
    
    always @(*) begin
        {i,j,k} = 0;
        for(i = 0; i < N+1; i = i + 1) begin // if i = 2
            C[i] = G_Work[i+1];
            for(j = 0; j < i + 1; j = j + 1) begin // 0,1,2
                InnerWorks2 = {N+1{1'b1}};
                for(k = j; k < i + 1; k = k + 1) begin //(0,1,2),(1,2),(2)
                    InnerWorks2[j] = InnerWorks2[j] & P[k];
                    // P0&P1&P2
                    // P1&P2
                    // P2
                end
                // Power check
                InWorkMem = InnerWorks2;
                
                // Operation
                InnerWorks[j] = InnerWorks2[j]&G_Work[j];
                C[i] = (C[i] | InnerWorks[j]);
                // P0&P1&P2&G0
                // P0&P1&P2&G0 + P1&P2&G1
                // P0&P1&P2&G0 + P1&P2&G1 + P2&G2
                // G_Work[0] is Cin- this just makes generalization easier.
            end
        end
    end
    
endmodule
