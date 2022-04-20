`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2022 06:47:42 PM
// Design Name: 
// Module Name: convo_cont
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module convo_cont(
    input Clk,
    input [31:0] ImageAddress,
    input [31:0] kernelAddress,
    input [31:0] kernelSize,
    input [500:0] data // don't know how to access physical memory, need Tucker's help
    );
    
    wire OffsetAddress;
    
    reg [31:0] iCountRow; // Position along X-axis
    reg [31:0] iCountColumn; // Position along Y-axis
    reg [31:0] kCountRow; // Position along X-axis
    reg [31:0] kCountColumn; // Position along Y-axis
    
    wire imageRow; // rows (bottom to top)
    wire imageColumn; // columns (left to right)
    
    wire pixBit; // contains pixel size Bits
    reg pixByte; // contains pixel size Bytes
    integer j;
    
    reg [31:0] padNum; // contains # of pad cells
    integer i;
    
    wire [31:0] distXCenter; 
    wire [31:0] distYCenter;
    
    wire [31:0] imageIn;
    reg [31:0] imageTemp = 0; // Padded imageIn
    reg [31:0] dataActual = 0; // Padded imageIn
    
    reg w;
    
    wire DoneMultAccum;
    
    wire kcenter;
    
    wire BoundaryXUp, BoundaryYUp;
    reg sizeX;
    reg sizeY;
    
    wire PadX, PadY;
    
    wire PadFlag;
    
    reg [2:0] RGB;
    wire RGBControl;
    wire iColControl;
    wire iRowControl;
    wire kColControl;
    wire kRowControl;
    
    wire [4:0] Controller;
    reg AccumReset = 0;
    reg Done = 0;
    
    wire [31:0] kData; // in from data mem
    wire [31:0] MultOut;
    wire MultDone;
    reg reset;
    wire [31:0] AccumOut;
    wire AccumDone;
    wire kCenter;
    
    // Extract data from BMP file, assuming standard header
    assign OffsetAddress = data[ImageAddress + 'hA];
    
    assign imageRow = data[ImageAddress + 'h16];
    assign imageColumn = data[ImageAddress + 'h12];
    
    assign pixBit = data[ImageAddress + 'h1C];
    always@(*) // byte the bit
        for (pixByte = 0; j != 0; pixByte = pixByte + 1)
            j = pixByte*8 - pixBit;
    
    // Padding controls
    always@(*)
        for(i = 0; padNum[31] == 0; i = i + 1)
            padNum = (4*i) - imageColumn;
    
    // 3 is because RGB
    assign imageIn = data[OffsetAddress + (distYCenter*(w + padNum) + distXCenter)*pixByte*3];
    
    // kill Zs
    always@(*)
        for(i = 0; i < 23; i = i + 1)
            imageTemp[i] = (imageIn[i] == 1'bz)? imageIn[i-1] : imageIn[i];
    
    wallace_Tree dumMult(.Clk(Clk), .x(dataActual),  .y(kData), .MultReset(MultReset), .product(MultOut), .MultDone(MultDone));
    Accumulator dumAdd(.Clk(Clk), .AddIn(MultOut), .AccumReset(AccumReset), .Holder(AccumOut), .AccumDone(AccumDone));
    assign DoneMultAccum = MultDone & AccumDone;
    
    // Overlay controls
    assign kCenter = ((kernelSize + 1) >> 1);
    
    assign distXCenter = iCountRow + (kCountRow - kCenter);
    assign distYCenter = iCountColumn + (kCountColumn - kCenter);
    
    assign BoundaryXUp = (distXCenter > sizeX) & (distXCenter[31] == 0) ? 1 : 0;
    assign BoundaryYUp = (distYCenter > sizeY) & (distYCenter[31] == 0) ? 1 : 0;
    
    assign PadX = (BoundaryXUp | (distXCenter[31] == 1)) ? 1 : 0;
    assign PadY = (BoundaryYUp | (distYCenter[31] == 1)) ? 1 : 0;
    
    assign PadFlag = PadX | PadY;
    
    // For loop controls
    assign RGBControl  = (RGB < 3) ? 1 : 0;
    assign iColControl = (iCountColumn < imageColumn)? 1 : 0;
    assign iRowControl = (iCountRow < imageRow)? 1 : 0;
    assign kColControl = (kCountColumn < kernelSize)? 1 : 0;
    assign kRowControl = DoneMultAccum & ((kCountRow < kernelSize)? 1 : 0);
    
    assign Controller = {RGBControl,iColControl,iRowControl,kColControl,kRowControl};
    
    always@(posedge Clk) begin
        // A much more sensible for loop, given i *already had* a controller, haha
        Done = 0;
        casex(Controller)
            5'b0xxxx: begin
                RGB <= 0;
                Done = 1; // RGB reaches 3, we're done.
            end
            5'b10xxx: begin
                RGB <= RGB + 1;
                iCountColumn <= 0;
            end
            5'b110xx: begin
                iCountColumn <= iCountColumn + 1;
                iCountRow <= 0;
            end
            5'b1110x: begin
                iCountRow <= iCountRow + 1;
                kCountColumn <= 0;
                AccumReset = 1; // Kernel is done, empty the accumulator.
            end
            5'b11110: begin
                kCountColumn <= kCountColumn + 1;
                kCountRow <= 0;
            end
            5'b11111: begin // this also checks for the done flag from the accum & multiplier
                kCountRow <= kCountRow + 1;
            end
            // Default behavior is just to hold all current values
        endcase
        // Data Input
        case({kRowControl,PadFlag})
            2'b10: {reset,dataActual} <= {1'b0,imageTemp};
            2'b11: {reset,dataActual} <= 0;
            default: {reset,dataActual} <= {1'b1,dataActual};
        endcase
    end
endmodule