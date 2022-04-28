`timescale 1ns / 1ps


module wallace_tree_tb;
    reg [7:0] x;
    reg [7:0] y;
    reg clk;
    wire [15:0] product;
    
    wallace_Tree uut(
     .x(x),
     .y(y),
     .clock(clk),
     .product(product)
     );
    
    initial begin
        clk = 0;
        x = 'b10101010;
        y = 'b01010101;
        #1;
        clk = 1;
        #1;
        clk = 0;
        x = 'b10101111;
        y = 'b01011101;
        #1;
        clk = 1;
        #1;
        clk = 0;
        x = 'b11101010;
        y = 'b01010000;
        #1;
        clk = 1;
        #1;
        clk = 0;
        
        $finish;
        
    end
endmodule
