`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 07:29:25 PM
// Design Name: 
// Module Name: Select_8Bit_Alt
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


module Select_8Bit_Alt(
    input  [N:0]         A,
    input  [N:0]         B,
    input                Cin,
    output [N:0]         S,
    output               Cout,
    output [7*(N+1)-1:0] Gates // 4*(N+1) + 3*(N+1)
    );
    
    parameter N = 7;
    
    wire [N+2:0]S0, S1, Carry0; // 3*(N+1), 2 leading 0s for safety)
    
    assign S0 [N+2:N+1] = 0;
    assign Carry0 [N+2:N+1] = 0;
    
    wire Carry1; // 1
    
    wire [N+2:0]AndCarry; // N, 2 leading 0s
    assign AndCarry [N+2:N+1] = 0;
    
    assign Gates[7*(N+1)-1:3*(N+1)] = {AndCarry,Carry0,Carry1,S0,S1};
    
    Full_Adder FA0[N:0](.A(A), .B(B), .Cin({Carry0[N-1:0],1'b0}), .S(S0[N:0]), .Cout(Carry0[N:0]), .Gate(Gates[3*(N+1)-1:0])); // 3*(N+1)
    
    assign #3 {Cout,S} = Cin ? {Carry1,S1[N:0]} : {Carry0[N],S0[N:0]};
    assign #1 AndCarry = {AndCarry[N:0],S0[0]} & S0[N+2:1]; // N
    
    assign #1 S1[0]  = ~S0[0]; // 1
    assign #1 S1[N+2:1] = {AndCarry[N:0],S0[0]} ^ S0[N+2:1]; // N
    assign #1 Carry1 = AndCarry[N-1] ^ Carry0[N]; // 1
endmodule
