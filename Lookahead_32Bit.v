`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 05:59:38 PM
// Design Name: 
// Module Name: Lookahead_32Bit
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


module Lookahead_32Bit(
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    output [31:0] S_Alt,
    output [31:0] S_4B,
    output [31:0] S_A4B,
    
    // Carry-Out
    output Cout,
    output Cout_4B,
    output Cout_Alt,
    output Cout_A4B,
    
    //Gate Consideration
    output [223:0] GatesExtern, // 4*7*8 Gates = 224
    output [215:0] GatesExternAlt, // 2*3 + 7*2 + 3*7*8 + 7*4 = 216
    output [223:0] GatesExtern_4B, //8*7*4 = 224
    output [215:0] GatesExternAlt_4B // 2*3 + 7*2 + 7*7*4 = 216
    );
    
    //Propogation
    wire [2:0] Carry;
    wire [6:0] Carry_4B;
    wire [5:0] Carry_Alt;
    wire [8:0] Carry_A4B;
    
    //8-Bit
    Lookahead_8Bit  LA[3:0] (.A(A), .B(B), .Cin({Carry[2:0],1'b0}), .Cout({Cout,Carry[2:0]}), .S(S), .Gate(GatesExtern)); // 4*(7*8)
                    
    //8-Bit Alt
    Full_Adder          Fa[1:0] (.A(A[1:0]),    .B(B[1:0]),  .Cin({Carry_Alt[0],1'b0}), .Cout(Carry_Alt[1:0]),.S(S_Alt[1:0]),   .Gate(GatesExternAlt[5:0])); // 2*(3) = 6
    Lookahead_8Bit #(1) LA0A    (.A(A[3:2]),    .B(B[3:2]),  .Cin(Carry_Alt[1]),        .Cout(Carry_Alt[2]),  .S(S_Alt[3:2]),   .Gate(GatesExternAlt[19:6])); // 1*(7*2) = 14
    Lookahead_8Bit      LAA[2:0](.A(A[27:4]),   .B(B[27:4]), .Cin(Carry_Alt[4:2]),      .Cout(Carry_Alt[5:3]),.S(S_Alt[27:4]),  .Gate(GatesExternAlt[187:20])); // 3*(7*8) = 168
    Lookahead_8Bit #(3) LA1A    (.A(A[31:28]),  .B(B[31:28]),.Cin(Carry_Alt[5]),        .Cout(Cout_Alt),      .S(S_Alt[31:28]), .Gate(GatesExternAlt[215:188])); // 1*(7*4) = 28
    
    //4-Bit
    Lookahead_8Bit #(3) LA4B[7:0](.A(A),        .B(B),       .Cin({Carry_4B,1'b0}),     .Cout({Cout_4B,Carry_4B[6:0]}), .S(S_4B), .Gate(GatesExtern_4B)); // 8*(7*4) = 224
    
    //4-Bit Alt
    Full_Adder          FA4[1:0] (.A(A[1:0]),   .B(B[1:0]),  .Cin({Carry_A4B[0],1'b0}), .Cout(Carry_A4B[1:0]),     .S(S_A4B[1:0]),        .Gate(GatesExternAlt_4B[5:0])); // 2*(3) = 6
    Lookahead_8Bit #(1) LA4BA1   (.A(A[3:2]),   .B(B[3:2]),  .Cin(Carry_A4B[1]),        .Cout(Carry_A4B[2]),       .S(S_A4B[3:2]),        .Gate(GatesExternAlt_4B[19:6])); // 1*(7*2) = 14
    Lookahead_8Bit #(3) LA4BA[6:0](.A(A[31:4]), .B(B[31:4]), .Cin(Carry_A4B[8:2]),      .Cout({Cout_A4B,Carry_A4B[8:3]}),.S(S_A4B[31:4]), .Gate(GatesExternAlt_4B[215:20])); // 7*(7*4)= 196

endmodule
