`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2022 04:50:21 PM
// Design Name: 
// Module Name: Padding_Mockup
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


module Padding_Mockup(
        input Clk,
        input [31:0] ImageAddress,
        input [31:0] kernelAddress,
        input [31:0] kernelSize,
        
        input [23:0] imageIn
    );
    
    // Extract data from BMP file, assuming standard header
    wire OffsetAddress;
    assign OffsetAddress = data[ImageAddress + 'hA];
    
    wire imageRow; // rows (bottom to top)
    wire imageColumn; // columns (left to right)
    assign imageRow = data[ImageAddresss + 'h16];
    assign imageColumn = data[ImageAddresss + 'h12];
    
    wire pixBit; // contains pixel size Bits
    reg pixByte; // contains pixel size Bytes
    assign pixBit = data[imageAddress + 'h1C];
    always@(*) // byte the bit
        for (pixByte = 0; j != 0; pixByte = pixByte + 1)
            j = pixByte*8 - pixBit;
    
    // 3 is because RGB
    wire imageData;
    assign imageData = data[OffsetAddress + (distXCenter*(w + padNum) + distYCenter)*pixByte*3];
    
    // kill Zs
    wire [23:0] imageIn;
    assign imageIn = imageData;
    always@(*)
        for(i = 0; i < 23; i = i + 1)
            imageIn[i] = (imageIn[i] = 1'bz)? imageIn[i-1] : imageIn[i];
    
    reg [31:0] iCountRow; // Position along X-axis
    reg [31:0] iCountColumn; // Position along Y-axis
    reg [31:0] kCountRow; // Position along X-axis
    reg [31:0] kCountColumn; // Position along Y-axis
    
    reg [31:0] dataActual = 0; // Padded imageIn
    wire DoneMultAccum;
    Multiplier dumMult(.Clk(Clk), .ImageData(dataActual),  .kData(kData), .MultOut(MultOut), .MultDone(MultDone));
    Accumulator dumAdd(.Clk(Clk), .AddIn(MultOut), .reset(reset), .AccumOut(AccumOut), .AccumDone(AccumDone));
    assign DoneMultAccum = MultDone & AccumDone;
    
    
    // Overlay controls
    wire kcenter;
    assign kCenter = (kernelSize - 1) >> 1;
    
    wire distXCenter,distYCenter;
    assign distXCenter = iCountRow + (kCountRow - kCenter);
    assign distYCenter = iCountColumn + (kCountColumn - kCenter);
    
    // Padding controls
    reg padNum; // contains # of pad cells
    always@(*)
        for(i = 0; padNum[31] == 0; i = i + 1)
            padNum = 4*i - imageColumn;
    
    wire BoundaryXUp, BoundaryYUp;
    assign BoundaryXUp = (distXCenter > sizeX) & (distXCenter[31] == 0) ? 1 : 0;
    assign BoundaryYUp = (distYCenter > sizeY) & (distYCenter[31] == 0) ? 1 : 0;
    
    wire PadX, PadY;
    assign PadX = (BoundaryXUp | (distXCenter[31] == 1)) ? 1 : 0;
    assign PadY = (BoundaryYUp | (distYCenter[31] == 1)) ? 1 : 0;
    
    wire PadFlag;
    assign PadFlag = PadX | PadY;
    
    // For loop controls
    wire RGBControl;
    wire iColControl;
    wire iRowControl;
    wire kColControl;
    wire kRowControl;
    assign RGBControl  = (RGB < 3) ? 1 : 0;
    assign iColControl = (iCountColumn < imageColumn)? 1 : 0;
    assign iRowControl = (iCountRow < imageRow)? 1 : 0;
    assign kColControl = (kCountColumn < kernelSize)? 1 : 0;
    assign kRowControl = DoneMultAccum & ((kCountRow < kernelSize)? 1 : 0);
    
    wire [4:0] Controller;
    assign Controller = {RGBControl,iColControl,iRowControl,kColControl,kRowControl};
    
    always@(posedge Clk) begin // Behold: A For Loop.
            // If anything below in nested logic is high, we hold.
            // If *everything* above in nested logic, and itself, is high, we increment
            // Else, reset to 0- either we're 0 and need to reset, or something above us is happening and we don't matter.
        RGB <=           (Controller[0] | Controller[1] | Controller[2] | Controller[3]) ? RGB : (Controller[4] ? RGB + 1 : 0);
        iCountColumn <=  (Controller[0] | Controller[1] | Controller[2])? iCountColumn : ((Controller[3] & Controller[4]) ? iCountColumn + 1 : 0);
        iCountRow <=     (Controller[0] | Controller[1])? iCountRow : ((Controller[2] & Controller[3] & Controller[4]) ? iCountRow + 1 : 0);
        kCountColumn <=  (Controller[0])? kCountColumn : ((Controller[1] & Controller[2] & Controller[3] & Controller[4]) ? kCountColumn + 1 : 0);
        kCountRow <=     ((Controller[0] & Controller[1] & Controller[2] & Controller[3] & Controller[4]) ? kCountColumn + 1 : 0);
        
        case({kRowControl,PadFlag})
            2'b10: {reset,dataActual} <= {1'b0,imageIn};
            2'b11: {reset,dataActual} <= 0;
            default: {reset,dataActual} <= {1'b1,dataActual};
        endcase
    end
    
endmodule
