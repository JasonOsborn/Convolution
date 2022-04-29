`timescale 1ns / 1ps


module Wallace_Tree_tb;
    reg [7:0] x = 0;
    reg [7:0] y = 0;
    wire [15:0] product;
    
    wallace_Tree uut(
     .x(x),
     .y(y),
     .product(product)
     );
    
    initial begin
        
        x = 'd0;
        y = 'd0;
        
        #100;
        
        x = 8'h7F;
        y = 8'h7F;
        
        #100;
        
        x = 'b1010_1010;
        y = 'b0101_0101;
        
        #100;
        
        x = 'b1010_1111;
        y = 'b0101_1101;
        
        #100;
        
        x = 'b1110_1010;
        y = 'b0101_0000;
    end
endmodule