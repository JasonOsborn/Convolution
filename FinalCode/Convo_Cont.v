`timescale 1ns / 1ps

module convo_cont #(parameter MaxImageSize = 1280)(
                    input clk,
                    input Start,
                    input [7:0] ImageAddress,
                    input [2:0] KernelSelect,
                    input [7:0] KernelA_In,
                    input [7:0] KernelS_In,
                    
                    input [7:0] dataIn,
                    
                    output [15:0] dataAddress,
                    output [15:0] writeAddress,
                    
                    output AccumReset,
                    output reg DoneFlag = 0,
                    output [31:0] OutputTrue
                    );
    
    reg [31:0] StartOverride = 0;
    reg [31:0] OutputLatch = 0;
    assign OutputTrue = Start ? StartOverride : OutputLatch;
    
    reg [7:0] Kernels [35:0]; // Lookup Table
    
    // Counters
    integer i = 0;
    integer j = 0;
    
    // Working Signals
    reg StartingFlag = 1;
    wire [31:0] AccumOut;
    
    // Loop Counters
    reg [11:0] iCountRow    = 0; // Position along X-axis
    reg [11:0] iCountColumn = 0; // Position along Y-axis
    reg [11:0] kCountRow    = 0; // Position along kX-axis
    reg [11:0] kCountColumn = 0; // Position along kY-axis
    
    // Image Info
    wire [12:0] distXCenter; 
    wire [12:0] distYCenter;
    
    reg [7:0] imageIn    = 0;
    reg [7:0] imageTemp  = 0; // Z-less imageIn
    reg [7:0] dataActual = 0; // Padded imageIn
    
    // Padding
        // Calculated Padding
    wire BoundaryXUp, BoundaryYUp;
    wire PadX, PadY;
    wire PadFlag;
        // Pulled Padding - # of cells
    reg [15:0] padNum = 0;
    
    // Addresses
        // Addresses to Choose From
    reg  [15:0] StartAddress = 0;
    wire [15:0] PixelAddress;
    wire [15:0] KernelAddress;
    
    // Image
    reg [15:0] OffsetAddress = 0; // File offset information to data
    reg [15:0] imageRow = 0;      // Width of the image in pixels
    reg [15:0] imageColumn = 0;   // Height of the image in pixels
    reg [15:0] pixBit  = 0;       // contains pixel size Bits
    reg [15:0] pixByte = 0;       // contains pixel size Bytes
    
    // Kernel
    reg DataKernelFlag = 0;  // Grabbing Kernel?
    reg [7:0] kDataMem = 0;  // in from data mem
    wire [7:0] kData;        // in from data mem OR lookup table, depending on kernel select
    
    wire [4:0] kCenter;
    wire [11:0] kernelSize;
    wire [11:0] kernelOffset;
    
    // System State Machine Controller
    reg [2:0] RGB = 0;
    wire RGBControl;
    wire iColControl;
    wire iRowControl;
    wire kColControl;
    wire kRowControl;
    
    wire [7:0] Controller;
    
// Module Declaration
    SignedMultAccum Container_MulAccum( 
                        .clk(clk),
                        .AccumReset(AccumReset | WriteFlag),
                        .x(dataActual),
                        .y(kData),
                        .LocalReg(AccumOut)
                        ); // LocalReg is negedge clocked, holds output of multiply & accumulate.
    
// Input/Output Addresses
    // Output Addresses
    assign dataAddress = StartingFlag ? StartAddress : (DataKernelFlag ? PixelAddress : KernelAddress);
    assign writeAddress = StartingFlag ? StartAddress : PixelAddress;
    
    // Working Addresses
    assign PixelAddress = OffsetAddress + (distYCenter*(imageRow + padNum) + distXCenter)*pixByte*3;
    assign KernelAddress = KernelA_In + kernelOffset;
    
// Image
    // Initial - Extracted from tricolor BMP file, assuming standard header - BITMAPINFOHEADER - May '22
    always@(*) begin
            // byte the bit
        pixByte = pixBit >> 3;
            // Pre-existing Padding controls
        padNum = ((imageRow + 7) & ((~8)+1)) - imageRow;
            // kill Zs
        for(i = 0; i < 23; i = i + 1)
            imageTemp[i] = (imageIn[i] == 1'bz)? imageIn[i-1] : imageIn[i];
            // Output Latch
        OutputLatch = (AccumReset | DoneFlag) ? ((~(|OutputLatch)) ? AccumOut : OutputLatch) : 0;
    end
    
// Kernel
    // Source of Kernel Data
    assign kData = (KernelSelect > 3) ? kDataMem : Kernels[(3*KernelSelect) + kernelOffset];
    
    // Initial Definitions
    assign kernelSize =  (KernelSelect > 3) ? KernelS_In : 3; // Default of 3
    assign kCenter = ((kernelSize + 1) >> 1);
    
    // Location in Kernel
    assign kernelOffset = kCountRow + (kernelSize*kCountColumn);
    
    // Where are we overlayed?
    assign distXCenter = iCountRow + (kCountRow - kCenter);
    assign distYCenter = iCountColumn + (kCountColumn - kCenter);
    assign BoundaryXUp = (distXCenter > imageRow)    & (distXCenter[12] == 0) ? 1 : 0;
    assign BoundaryYUp = (distYCenter > imageColumn) & (distYCenter[12] == 0) ? 1 : 0;
    
    // Our Padding
    assign PadX = (BoundaryXUp | (distXCenter[12] == 1)) ? 1 : 0;
    assign PadY = (BoundaryYUp | (distYCenter[12] == 1)) ? 1 : 0;
    assign PadFlag = PadX | PadY;
    
// Loop Controls
    // If Conditionals
    assign RGBControl  = (RGB < 3)                    ? 1 : 0; // Top Level
    assign iColControl = (iCountColumn < imageColumn) ? 1 : 0; // 2nd Level
    assign iRowControl = (iCountRow    < imageRow)    ? 1 : 0; // 3rd Level
    assign kColControl = (kCountColumn < kernelSize)  ? 1 : 0; // 4th Level
    assign kRowControl = (kCountRow    < kernelSize)  ? 1 : 0; // Lowest Level
    
    // Controller
    assign Controller = {Start,StartingFlag,DoneFlag,RGBControl,iColControl,iRowControl,kColControl,kRowControl};
    
    reg [11:0] headerCount = 0;
    
// The Loop - Where the magic happens
    always@(posedge clk) begin
        casex(Controller[7:5])
            3'b11x: begin
                // Read from Header
                StartOverride = 0;
                StartAddress = ImageAddress + 'hA;
                OffsetAddress = dataIn; // Offset to data
                headerCount = 0;
                if(headerCount < OffsetAddress) begin
                    StartAddress = ImageAddress + headerCount;
                    case(headerCount)
                        'h16: begin // ImageRow
                            imageRow = dataIn;
                        end
                        'h12: begin // ImageColumn
                            imageColumn = dataIn;
                        end
                        'h1C: begin // Bits per Pixel
                            pixBit = dataIn;
                            end
                    endcase
                    StartOverride = dataIn;
                    headerCount = headerCount + 1;
                end
                else
                    StartingFlag = 0;
            end
            3'b100: begin
                DataKernelFlag = 1;
                imageIn = dataIn;
                
                if(KernelSelect > 3) begin
                    DataKernelFlag = 0;
                    kDataMem = dataIn;
                end
            end
            3'bx01:
                StartingFlag = 1;
        endcase
        
        casex(Controller)
            8'b100_0xxxx: begin
                RGB <= 0;
                DoneFlag = 1; // RGB reaches 3, we're done.
            end
            8'b100_10xxx: begin
                RGB <= RGB + 1;
                iCountColumn <= 0;
            end
            8'b100_110xx: begin
                iCountColumn <= iCountColumn + 1;
                iCountRow <= 0;
            end
            8'b100_1110x: begin
                iCountRow <= iCountRow + 1;
                kCountColumn <= 0;
            end
            8'b100_11110: begin
                kCountColumn <= kCountColumn + 1;
                kCountRow <= 0;
            end
            8'b100_11111: begin
                kCountRow <= kCountRow + 1;
            end
            // Default behavior is just to hold all current values
        endcase
        
        // Data Input
        case({kRowControl,PadFlag})
            2'b10:   dataActual <= imageTemp;
            default: dataActual <= 0;
        endcase
    end
    
    assign AccumReset = Start | (~(&Controller[4:1]));
    
// Lookup table that sits on the chip at the beginning of time
    integer z = 0;
    initial begin
        for(z = 0; z < 35; z = z + 1) begin
            case(z)
                // Sharpen
                0: Kernels[z] = 7'd0;
                1: Kernels[z] = -7'd1;
                2: Kernels[z] = 7'd0;
                
                3: Kernels[z] = -7'd1;
                4: Kernels[z] = 7'd5;
                5: Kernels[z] = -7'd1;
                
                6: Kernels[z] = 7'd0;
                7: Kernels[z] = -7'd1;
                8: Kernels[z] = 7'd0;
                
                // Blur
                9: Kernels[z] = 7'd1;
                10: Kernels[z] = 7'd2;
                11: Kernels[z] = 7'd1;
                
                12: Kernels[z] = 7'd2;
                13: Kernels[z] = 7'd4;
                14: Kernels[z] = 7'd2;
                
                15: Kernels[z] = 7'd1;
                16: Kernels[z] = 7'd2;
                17: Kernels[z] = 7'd1;
                
                // Outline
                18: Kernels[z] = -7'd1;
                19: Kernels[z] = -7'd1;
                20: Kernels[z] = -7'd1;
                
                21: Kernels[z] = -7'd1;
                22: Kernels[z] = 7'd8;
                23: Kernels[z] = -7'd1;
                
                24: Kernels[z] = -7'd1;
                25: Kernels[z] = -7'd1;
                26: Kernels[z] = -7'd1;
                
                // Emboss
                27: Kernels[z] = -7'd2;
                28: Kernels[z] = -7'd1;
                29: Kernels[z] = 7'd0;
                
                30: Kernels[z] = -7'd1;
                31: Kernels[z] = 7'd1;
                32: Kernels[z] = 7'd1;
                
                33: Kernels[z] = 7'd0;
                34: Kernels[z] = 7'd1;
                35: Kernels[z] = 7'd2;
            endcase
        end
    end
endmodule