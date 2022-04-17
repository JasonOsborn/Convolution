`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 07:06:47 PM
// Design Name: 
// Module Name: Select_4Bit
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


module Select_8Bit(
    input  [N:0]        A,
    input  [N:0]        B,
    input               Cin,
    output [N:0]        S,
    output              Cout,
    output [10*(N+1)-1:0] Gates // (3 + 3 + 4) * (N + 1)
    );
    
    parameter N = 7;
    
    wire [N:0]S0;     //(N+1)
    wire [N:0]Carry0; //(N+1)
    
    wire [N:0]S1;     //(N+1)
    wire [N:0]Carry1; //(N+1)
    
    assign Gates[10*(N+1)-1:6*(N+1)] = {S0, S1, Carry0, Carry1}; // 4*(N+1)
    
    assign #3 {Cout,S} = Cin ? {Carry1[N],S1} : {Carry0[N],S0};
    
    Full_Adder  FA0[N:0](.A(A), .B(B), .Cin({Carry0[N-1:0],1'b0}), .S(S0), .Cout(Carry0), .Gate(Gates[3*(N+1)-1:0])); // 3*(N+1)
    Full_Adder  FA1[N:0](.A(A), .B(B), .Cin({Carry1[N-1:0],1'b1}), .S(S1), .Cout(Carry1), .Gate(Gates[6*(N+1)-1:3*(N+1)])); // 3*(N+1)
        
endmodule
