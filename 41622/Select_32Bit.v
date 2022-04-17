`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 07:04:15 PM
// Design Name: 
// Module Name: Select_32Bit
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

// "optimum" 8-7-6-4-3-2-2 for 32 Select_32Bit
// meaning we don't care about much of the output of C/S from the 8 bit FA modules used below

// 2 different Carry-Select Adders are displayed- Typical and an alternate, much lighter operation

module Select_32Bit(
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    output [31:0] S_Alt,
    output        Cout,
    output        Cout_Alt
    );
    
    wire [5:0] Carry;
    wire [5:0] Carry_Alt;
    
    wire [319:0] GatesExtern; // 70 : 79 z, 110 : 119; 170 : 179; 240 : 249
    wire [223:0] GatesExternAlt;
    
    // 40 + 30 + 40 + 60 + 70 + 80 = 320
    Select_8Bit #(1) S01[1:0](.A(A[3:0  ]), .B(B[3:0  ]), .Cin({Carry[0],1'b0}), .S(S[3:0  ]), .Cout({Carry[1],Carry[0]}),.Gates(GatesExtern[39:0   ])); // 2*(2*10) = 40
    Select_8Bit #(2) S02     (.A(A[6:4  ]), .B(B[6:4  ]), .Cin(Carry[1]),        .S(S[6:4  ]), .Cout(Carry[2]           ),.Gates(GatesExtern[69:40  ])); // 3*10 = 30
    Select_8Bit #(3) S03     (.A(A[10:7 ]), .B(B[10:7 ]), .Cin(Carry[2]),        .S(S[10:7 ]), .Cout(Carry[3]           ),.Gates(GatesExtern[109:70 ])); // 4*10 = 40
    Select_8Bit #(5) S04     (.A(A[16:11]), .B(B[16:11]), .Cin(Carry[3]),        .S(S[16:11]), .Cout(Carry[4]           ),.Gates(GatesExtern[169:110])); // 6*10 = 60
    Select_8Bit #(6) S05     (.A(A[23:17]), .B(B[23:17]), .Cin(Carry[4]),        .S(S[23:17]), .Cout(Carry[5]           ),.Gates(GatesExtern[239:170])); // 7*10 = 70
    Select_8Bit      S06     (.A(A[31:24]), .B(B[31:24]), .Cin(Carry[5]),        .S(S[31:24]), .Cout(Cout               ),.Gates(GatesExtern[319:240])); // 8*10 = 80
    
    // 28 + 21 + 28 + 42 + 49 + 56 = 224
    Select_8Bit_Alt #(1) SA1[1:0](.A(A[3:0  ]), .B(B[3:0  ]), .Cin({Carry_Alt[0],1'b0}), .S(S_Alt[3:0  ]), .Cout({Carry_Alt[1],Carry_Alt[0]}),.Gates(GatesExternAlt[27:0]  )); // 2*(2*7) = 28
    Select_8Bit_Alt #(2) SA2     (.A(A[6:4  ]), .B(B[6:4  ]), .Cin(Carry_Alt[1]),        .S(S_Alt[6:4  ]), .Cout(Carry_Alt[2]               ),.Gates(GatesExternAlt[48:28  ])); // 3*7 = 21
    Select_8Bit_Alt #(3) SA3     (.A(A[10:7 ]), .B(B[10:7 ]), .Cin(Carry_Alt[2]),        .S(S_Alt[10:7 ]), .Cout(Carry_Alt[3]               ),.Gates(GatesExternAlt[76:49  ])); // 4*7 = 28
    Select_8Bit_Alt #(5) SA4     (.A(A[16:11]), .B(B[16:11]), .Cin(Carry_Alt[3]),        .S(S_Alt[16:11]), .Cout(Carry_Alt[4]               ),.Gates(GatesExternAlt[118:77 ])); // 6*7 = 42
    Select_8Bit_Alt #(6) SA5     (.A(A[23:17]), .B(B[23:17]), .Cin(Carry_Alt[4]),        .S(S_Alt[23:17]), .Cout(Carry_Alt[5]               ),.Gates(GatesExternAlt[167:119])); // 7*7 = 49
    Select_8Bit_Alt      SA6     (.A(A[31:24]), .B(B[31:24]), .Cin(Carry_Alt[5]),        .S(S_Alt[31:24]), .Cout(Cout_Alt                   ),.Gates(GatesExternAlt[223:168])); // 8*7 = 56
    
endmodule
