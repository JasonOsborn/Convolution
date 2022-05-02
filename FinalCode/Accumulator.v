`timescale 1ns / 1ps

module Accumulator(
                    input clk,
                    input [31:0] AddIn,
                    input SignBit,
                    
                    input AccumReset,
                    
                    output reg [31:0] LocalReg = 0
                    );
    
    wire [31:0] Holder;
    wire [31:0] AddInTrue;
    assign AddInTrue = SignBit ? ((~AddIn) + 1) : AddIn;
    
    Lookahead_32Bit_A Adder(.A(AddInTrue),.B(LocalReg),.S(Holder));
    
    always@(negedge clk) begin
        LocalReg <= ({32{~AccumReset}} & (Holder));
    end
    
endmodule
