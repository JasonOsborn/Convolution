module SignedMultAccum( input clk,
                        input AccumReset,
                        input [7:0] x,
                        input [7:0] y,
                        output [31:0] Holder,
                        //output [31:0] AddIn,
                        output [31:0] LocalReg // Doesn't usually exist; for sim
                        );
    
    wire [7:0] AbsX;
    assign AbsX = x[7] ? (~x)+1'b1 : x;
    wire [7:0] AbsY;
    assign AbsY = y[7] ? (~y)+1'b1 : y;
    
    wire SignBit;
    assign SignBit = x[7] ^ y[7];
    
    wire [15:0] MultOut;
    
    wallace_Tree Mult(.x(AbsX),.y(AbsY),.product(MultOut));
    
    wire [31:0] AddIn;
    assign AddIn = {{16{1'b0}},MultOut};
    
    Accumulator Accum(.clk(clk), .SignBit(SignBit), .AddIn(AddIn), .LocalReg(LocalReg), .AccumReset(AccumReset));
    
endmodule
