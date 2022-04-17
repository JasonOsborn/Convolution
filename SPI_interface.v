`timescale 1ns / 1ps

module SPI_interface(
    input clk,
    input MISO,
    output reg sclk,
    output reg MOSI,
    output reg cs
    );

//Op codes used 
parameter idle              = 6'd0;
parameter set_length        = 6'd16;
parameter read_block_single = 6'd17;
parameter read_block_multi  = 6'd18;
parameter stop_trans        = 6'd12;
parameter write_block       = 6'd24;

parameter crc_toggle        = 6'd59;

parameter start_address     = 32'd0;
    
parameter generic_crc       = 7'd0;
    
    //reg [7:0] clk_div; //Have to divide basys3 clock
    reg [5:0] counter;
    
    //full command is 48 bits long
    reg [47:0] data_to_send;
    
    //data_in should be 24 bit
    reg [23:0] data_in_hold;
    reg [23:0] data_in_fin;
    
    reg setup = 1'b1; 
    
    reg clk_div = 8'd0;
    
    //lower clk to 25 MHz
    always @(posedge clk)
    begin
        if(clk_div == 8'd4)
        begin
            clk_div <= 8'd0;
            sclk = !sclk;
        end
        else
        begin
            clk_div <= clk_div + 8'd1;
        end
        if(setup == 1)
        begin
            //send idle command
            data_to_send <= {0,1,idle,000000000000000000000000000000,generic_crc,1};
            setup <= 0;
        end
    end
///////////////////////
//Sending commands 
///////////////////////
always @(posedge sclk)
begin
    if(data_to_send != 0)
    begin
        MOSI <= data_to_send[0];
        data_to_send = data_to_send << 1;
    end
end

    
///////////////////
//read in data 
///////////////////
always @(negedge sclk)
    begin
        if(counter <= 5'd24) 
        begin
            //read in and shift
            data_in_hold <= data_in_hold << 1;
            data_in_hold[24] <= MISO;
        end
        else
        begin
            //finished 24 bit data block for pixel
            data_in_fin <= data_in_hold;
        end
    end    
    
endmodule
