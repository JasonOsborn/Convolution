`timescale 1ns / 1ps

module MultAccum_Sim_tb;
    
    reg clk = 0;
    always #10 clk = ~clk;
    
    reg [7:0] x = 0;
    reg [7:0] y = 0;
    
    wire [31:0] LocalReg;
    wire AccumReset;
    wire RegMatch;
    wire HoldMatch;
    
    MultAccumHold MultAccumFull(.clk(clk), .LocalReg(LocalReg), .AccumReset(AccumReset), .x(x), .y(y));
    
//    wire [31:0] LocalReg1;
//    assign LocalReg1 = MultAccumHold.LocalReg1;
//    wire [31:0] Holder1;
//    assign Holder1 = MultAccumHold.Holder1;
    
//    Wallace_Tree_tb WallaceTB();
    
    parameter Test = 7;
    
    reg [(Test*8)-1:0] nextX;
    reg [(Test*8)-1:0] nextY;
    
    integer i = 0;
    reg [31:0] j = 0;
    wire [31:0] k;
    assign k = j + j^3;
    
    assign AccumReset = (i == 0) ? 1 : 0;
    
    reg start = 0;
    
    initial begin
        {x,y,start} = 0;
        nextX = {8'h7F,8'hAA,8'hAF,8'hEA,8'h7F,8'd0,8'hFF};
        nextY = {8'h7F,8'h55,8'h5D,8'h50,8'h0,8'h7F,8'hFF};
        #100;
        start = 1;
    end
    
    always@(posedge clk) begin
        if(start) begin
            {nextX,nextY} = AccumReset ? {nextX,nextY} : (
                (j > Test) ? {j[7:0],k[7:0]} : {nextX >> 8,nextY >> 8});
            {x,y} = {nextX[7:0],nextY[7:0]};
            i = (i > 9)? 0 : i + 1;
            j = j + 1;
        end
    end
    
endmodule
