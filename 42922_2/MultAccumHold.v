`timescale 1ns / 1ps

module MultAccumHold(   input clk,
                        input AccumReset,
                        input [7:0] x,
                        input [7:0] y,
                        //output [31:0] Holder,
                        //output HoldMatch,
                        output [31:0] LocalReg
                        //output [31:0] AddIn
                        //output RegMatch
                        );
    
//    assign HoldMatch = (Holder1 == Holder2) ? 1 : 0;
//    assign RegMatch = (LocalReg1 == LocalReg2) ? 1 : 0;
    wire [31:0] AddIn;
    //wire [31:0] LocalReg;
    //MultAccum MulUnsign(.Clk(Clk),.AccumReset(AccumReset),.x(x),.y(y),.Holder(Holder2),.LocalReg(LocalReg2));
    
    SignedMultAccum MulSign(.clk(clk),.AccumReset(AccumReset),.x(x),.y(y),.LocalReg(LocalReg));
    
endmodule