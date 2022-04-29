`timescale 1ns / 1ps


module Accumulator(
                    input Clk,
                    input [31:0] AddIn,
                    
                    input AccumReset,
                    
                    output [31:0] Holder,
                    output reg [31:0] LocalReg = 0// Not normally output; for sim
                    );
    
    Lookahead_32Bit_A Adder(.A(AddIn),.B(LocalReg),.S(Holder));
    
//    always@(posedge Clk) LocalReg <= AccumReset ? 0 : Holder;
    always@(negedge Clk) LocalReg = {32{~AccumReset}} & (Holder);
    
endmodule
