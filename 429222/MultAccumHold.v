`timescale 1ns / 1ps

module MultAccumHold(   input Clk,
                        input AccumReset,
                        input [7:0] x,
                        input [7:0] y,
                        output [31:0] Holder1,
                        output HoldMatch,
                        output [31:0] LocalReg1,
                        output RegMatch
                        );
    
    assign HoldMatch = (Holder1 == Holder2) ? 1 : 0;
    assign RegMatch = (LocalReg1 == LocalReg2) ? 1 : 0;
    
    MultAccum MulUnsign(.Clk(Clk),.AccumReset(AccumReset),.x(x),.y(y),.Holder(Holder2),.LocalReg(LocalReg2));
    
    SignedMultAccum MulSign(.Clk(Clk),.AccumReset(AccumReset),.x(x),.y(y),.Holder(Holder1),.LocalReg(LocalReg1));
    
endmodule