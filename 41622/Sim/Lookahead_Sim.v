`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 09:06:19 PM
// Design Name: 
// Module Name: Lookahead_Sim
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

module Lookahead_Sim;
    
    reg [31:0] A, B;
    wire [31:0] S, S_Alt, S_4B, S_A4B; // Should be equal
    wire Cout, Cout_Alt, Cout_4B, Cout_A4B; // Should be equal
    
    wire [223:0] GatesExtern; // 4*7*8 Gates = 224
    wire [215:0] GatesExternAlt; // 2*3 + 7*2 + 3*7*8 + 7*4 = 216
    wire [223:0] GatesExtern_4B; //8*7*4 = 224
    wire [215:0] GatesExternAlt_4B; // 2*3 + 7*2 + 7*7*4 = 216
    
    Lookahead_32Bit uut(A, B, S, S_Alt, S_4B, S_A4B, Cout, Cout_Alt, Cout_4B, Cout_A4B,
                        GatesExtern, GatesExternAlt, GatesExtern_4B, GatesExternAlt_4B); // Instantiate Lookahead
    
    Select_Sim Start_Select(); // Start another sim.
    
    
    wire S_Compare, S_Compare_4B, S_Comp_Fin;
    wire Cout_Compare, Cout_Compare_4B, Cout_Comp_Fin;
    
    wire S_Compare_True, Cout_Compare_True;
    assign S_Compare_True = S_Comp_Fin & Start_Select.S_Compare;
    assign Cout_Compare_True = Cout_Comp_Fin & Start_Select.Cout_Compare;
    
    assign S_Compare    = (S == S_Alt) ? 1 : 0;
    assign Cout_Compare = (Cout == Cout_Alt) ? 1 : 0; // 8 Bit comparison
    
    assign S_Compare_4B    = (S_4B == S_A4B) ? 1 : 0;
    assign Cout_Compare_4B = (Cout_4B == Cout_A4B) ? 1 : 0; // 4 Bit comparison
    
    assign S_Comp_Fin = (S_Compare & S_Compare_4B);
    assign Cout_Comp_Fin = (Cout_Compare & Cout_Compare_4B); // 8/4 Bit comparison
    
    wire [2:0] CarryOut;
    wire [5:0] CarryOutAlt;
    wire [6:0] CarryOut4B;
    wire [8:0] CarryOutA4B;
    assign CarryOut    = uut.Carry;
    assign CarryOut4B  = uut.Carry_4B;
    assign CarryOutAlt = uut.Carry_Alt;
    assign CarryOutA4B = uut.Carry_A4B;
    
//    wire [223:0] GatesExtern;
//    wire [285:0] GatesExternAlt;
//    wire [447:0] GatesExtern_4B;
//    wire [453:0] GatesExternAlt_4B;
    
    wire [259:0] CounterSensitivity;
    wire [259:0] CountCompare;
    reg  [259:0] OldState = 260'b0;
    
    wire [323:0] CounterSensitivityAlt;
    wire [323:0] CountCompareAlt;
    reg  [323:0] OldStateAlt = 325'b0;
    
    wire [487:0] CounterSensitivity4B;
    wire [487:0] CountCompare4B;
    reg  [487:0] OldState4B = 488'b0;
    
    wire [495:0] CounterSensitivityA4B;
    wire [495:0] CountCompareA4B;
    reg  [495:0] OldStateA4B = 496'b0;
    
    assign CounterSensitivity    = {GatesExtern,       S,     Cout,     CarryOut   };
    assign CounterSensitivity4B  = {GatesExtern_4B,    S_4B,  Cout_4B,  CarryOut4B };
    assign CounterSensitivityAlt = {GatesExternAlt,    S_Alt, Cout_Alt, CarryOutAlt};
    assign CounterSensitivityA4B = {GatesExternAlt_4B, S_A4B, Cout_A4B, CarryOutA4B};
    
    assign CountCompare    = CounterSensitivity    ^ OldState;
    assign CountCompare4B  = CounterSensitivity4B  ^ OldState4B;
    assign CountCompareAlt = CounterSensitivityAlt ^ OldStateAlt;
    assign CountCompareA4B = CounterSensitivityA4B ^ OldStateA4B;
    
    integer counter = 0;
    integer counter4B = 0;
    integer counterAlt = 0;
    integer counterA4B = 0;
    
    integer i = 0, j = 0, k = 0, m = 0;
    reg start = 0;
    
    always@(CounterSensitivity) begin // Counter Functions. Count all gate flips.
        OldState <= CounterSensitivity;
        if(start) begin
            for (i = 0; i < 260; i = i + 1) counter = CountCompare[i] ? counter + 1: counter;
        end
    end
    always@(CounterSensitivity4B) begin
        OldState4B <= CounterSensitivity4B;
        if(start) begin 
            j = 0;
            for (j = 0; j < 488; j = j + 1) counter4B = CountCompare4B[j] ? counter4B + 1: counter4B;
        end
    end
    always@(CounterSensitivityAlt) begin
        OldStateAlt <= CounterSensitivityAlt;
        if(start) begin
            k = 0;
            for (k = 0; k < 324; k = k + 1) counterAlt = CountCompareAlt[k] ? counterAlt + 1: counterAlt;
        end
    end
    always@(CounterSensitivityA4B) begin
        OldStateA4B <= CounterSensitivityA4B;
        if(start) begin
            m = 0;
            for (m = 0; m < 496; m = m + 1) counterA4B = CountCompareA4B[m] ? counterA4B + 1: counterA4B;
        end
    end
    
    initial begin
    {A,B,start} = 0;
    
    #99;
    
    start = 1;
    
    #1;
    
    A = 32'h1; // = 0 0000 0002
    B = 32'h1;
    
    #100;
    
    A = 32'hFFFFFFFF; // = 0 FFFF FFFF
    B = 32'h0;
    
    #100;
    
    A = 32'hFFFFFFFF; // = 1 0000 0000
    B = 32'h1;
    
    #100;
    
    A = 32'h0; // = 0 FFFF FFFF
    B = 32'hFFFFFFFF;
    
    #100;
    
    A = 32'h1; // = 1 0000 0000
    B = 32'hFFFFFFFF;
    
    #100;
    
    A = 32'hFFFFFFFF; // = 1 FFFF FFFE
    B = 32'hFFFFFFFF;
    
    #100;
    
    A = 32'h12345678; // = 0 AAAA AAAA
    B = 32'h98765432;
    
    #100;
    
    A = 32'h98765432; // = 0 AAAA AAAA
    B = 32'h12345678;
    
    #100;
    
    A = 32'h12378945; // = 0 AAAB EE57
    B = 32'h98746512;
    
    #100;
    
    A = 32'h12378945; // = 1 1237 8944
    B = 32'hFFFFFFFF;
    
    end
    
endmodule
