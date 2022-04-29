module SignedMultAccum( input Clk,
                        input AccumReset,
                        input [7:0] x,
                        input [7:0] y,
                        output [31:0] Holder,
                        output [31:0] LocalReg // Doesn't usually exist; for sim
                        );
    
    wire [7:0] x_in;
    wire [7:0] NotX;
    wire x_sign;
    assign x_sign = x[7];
    assign NotX = ~x;
    wire [7:0] y_in;
    wire [7:0] NotY;
    wire y_sign;
    assign y_sign = y[7];
    assign NotY = ~y;
    
    wire SignBit;
    assign SignBit = x_sign ^ y_sign;
    
    assign x_in = x_sign ? NotX + 1 : x;
    assign y_in = y_sign ? NotY + 1 : y;
    
    wire [15:0] MultOut;
    wire [15:0] NegMultOut;
    wire [31:0] AddIn;
    assign NegMultOut = (~MultOut) + 1;
    assign AddIn = SignBit ? ((|NegMultOut) ? {{16'hFFFF},NegMultOut} : 32'd0) : {16'd0,MultOut};
    
    wallace_Tree Mult(.x(x_in),.y(y_in),.product(MultOut));
    Accumulator Accum(.Clk(Clk), .AddIn(AddIn), .LocalReg(LocalReg), .AccumReset(AccumReset), .Holder(Holder));
    
endmodule
