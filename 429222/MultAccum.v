module MultAccum(   input Clk,
                    input AccumReset,
                    input [7:0] x,
                    input [7:0] y,
                    output [31:0] Holder, // Doesn't usually exist; for sim
                    output [31:0] LocalReg
                    );
    
    wire [15:0] MultOut;
    wire [31:0] AddIn;
    assign AddIn = {{16{MultOut[15]}},MultOut};
    
    wallace_Tree Mult(.x(x),.y(y),.product(MultOut));
    Accumulator Accum(.Clk(Clk), .AddIn(AddIn), .LocalReg(LocalReg), .AccumReset(AccumReset), .Holder(Holder));
    
endmodule
