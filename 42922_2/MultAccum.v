`timescale 1ns / 1ps

module MultAccum(   input Clk,
                    input AccumReset,
                    input [7:0] x,
                    input [7:0] y,
                    output [31:0] Holder, // Doesn't usually exist; for sim
                    output [31:0] LocalReg
                    );
    
    wire [15:0] MultOut;
    wire [31:0] AddIn;
    assign AddIn = {{16{1'b0}},MultOut};
    
    
    wallace_Tree Mult(.x(x),.y(y),.product(MultOut));
    Accumulator Accum(.Clk(Clk), .SignBit(1'b0), .AddIn(AddIn), .LocalReg(LocalReg), .AccumReset(AccumReset), .Holder(Holder));
    
endmodule
