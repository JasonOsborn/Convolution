`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2022 09:06:19 PM
// Design Name: 
// Module Name: Select_Sim
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


module Select_Sim;
    
    reg  [31:0] A, B;
    wire [31:0] S, S_Alt; // Should be equal
    wire Cout, Cout_Alt; // Should be equal
    
    wire S_Compare;
    wire Cout_Compare;
    
    assign S_Compare = (S == S_Alt) ? 1 : 0;
    assign Cout_Compare = (Cout == Cout_Alt) ? 1 : 0;
    
    Select_32Bit uut(A, B, S, S_Alt, Cout, Cout_Alt);
    
    wire [325:0] CounterSensitivity;
    reg  [325:0] OldState;
    wire [325:0] CountCompare;
    assign CounterSensitivity = {uut.GatesExtern, uut.Carry}; // 320 + 6
    assign CountCompare = OldState ^ CounterSensitivity;
    
    wire [229:0] CounterSensitivityAlt;
    reg  [229:0] OldStateAlt;
    wire [229:0] CountCompareAlt;
    assign CounterSensitivityAlt = {uut.GatesExternAlt, uut.Carry_Alt}; // 224 + 6
    assign CountCompareAlt = OldStateAlt ^ CounterSensitivityAlt;
    
    reg start = 0;
    
    integer i = 0;
    integer j = 0;
    integer counter = 0;
    integer counterAlt = 0;
    
    always@(CounterSensitivity) begin // Counter Functions. Count all gate flips.
        OldState <= CounterSensitivity;
        if(start) begin
            for (i = 0; i < 326; i = i + 1) counter = CountCompare[i] ? counter + 1: counter;
        end
    end
    always@(CounterSensitivityAlt) begin
        OldStateAlt <= CounterSensitivityAlt;
        if(start) begin 
            j = 0;
            for (j = 0; j < 230; j = j + 1) counterAlt = CountCompareAlt[j] ? counterAlt + 1: counterAlt;
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
