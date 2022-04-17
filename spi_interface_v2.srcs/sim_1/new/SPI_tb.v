`timescale 1ns / 1ps

module SPI_tb;
    reg clk;
    reg MISO;
   // reg setup;
    wire sclk;
    wire MOSI;
    wire cs;
    wire clk_div;
    
    SPI_interface uut(
    .clk(clk),
    .MISO(MISO),
  //  .setup(setup),
    .sclk(sclk),
//    .clk_div(clk_div),
    .MOSI(MOSI),
    .cs(cs)
    );
    
    initial begin
        clk = 0;
        MISO = 0;
       // setup = 1;
    end
    
    always #10 clk = ~clk;
    

endmodule
