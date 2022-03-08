`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 06:50:22 PM
// Design Name: 
// Module Name: Lookahead_4Bit
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


module Lookahead_8Bit(
        input  [N:0] A,B,
        input  Cin,
        output Cout,
        output [N:0] S,
        output [(7*(N+1))-1:0] Gate
        // 3*(N+1) + 3*(N+1) + N+1 = 7*(N+1)
    );
    parameter N = 7;
    
    wire [N:0] Carry;
    assign Cout = Carry[N];
    
    assign Gate[7*(N+1)-1:6*(N+1)] = Carry; // N+1 gates

    Full_Adder           AdderTest[N:0]  (  .A   (A     [N:0]),
                                            .B   (B     [N:0]),
                                            .Cin ({Carry[N-1:0],Cin}),
                                            .S   (S     [N:0]),
                                            .Gate(Gate  [(3*(N+1))-1:0])
                                          ); // 3 gates per Adder, 3*(N+1) Adders
    
    Lookahead_Logic_8Bit #(N) Logic( .A(A), .B(B), .Cin(Cin), .Cout(Carry), .Gate(Gate[(6*(N+1))-1:3*(N+1)])); // 3*(N+1) Gates
    
endmodule
