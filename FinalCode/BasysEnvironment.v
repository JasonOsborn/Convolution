`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2022 12:54:35 AM
// Design Name: 
// Module Name: BasysEnvironment
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


module BasysEnvironment(
                        input clk,
                        output unoClk,
                        
                        input SerialComms,
                        output SerialOut,
                        
                        input StartFlag,
                        output DoneFlag
                        );
    
    parameter MaxImageSize = 1280;
    
    wire [15:0] MemAddress;     // wire 15 - dataAddress
    wire [31:0] InternalMemIn;  // wire 32 - OutputLatch
    wire [7:0] InternalMemOut;  // wire 8 - dataIn
    wire WriteFlag;             // wire 1
    
    wire [7:0] ImageAddress;    // user input x
    wire [2:0] KernelSelect;    // user input 4b
    wire [7:0] KernelA_In;      // user input 
    wire [7:0] KernelS_In;      // user input
    assign ImageAddress = 0;
    assign KernelA_In = 0;
    assign KernelS_In = 0;
    
    // Kernel Select
    assign KernelSelect = 0;
    
    UnoInputAndMemory Mem(
                        .clk(clk),                       // in 1
                        .unoClk(unoClk),                 // out 1
                        .StartFlag(StartFlag),           // in 1
                        .SerialComms(SerialComms),       // in 1
                        .SerialOut(SerialOut),           // out 1
                        .MemAddress(MemAddress),         // in 16
                        .InternalMemIn(InternalMemIn),   // in 32
                        .InternalMemOut(InternalMemOut), // out 8
                        .WriteFlag(WriteFlag),           // in 1
                        .DoneFlag(DoneFlag)              // in 1
                        );
    
    convo_cont  Container(
                        .clk(clk),                      // in 1
                        .Start(StartFlag),              // in 1
                        .ImageAddress(ImageAddress),    // in 8
                        .KernelSelect(KernelSelect),    // in 3
                        .KernelA_In(KernelA_In),        // in 8
                        .KernelS_In(KernelS_In),        // in 8
                        .dataIn(InternalMemOut),        // in 8
                        .dataAddress(MemAddress),       // out 16
                        .AccumReset(WriteFlag),         // out 1
                        .DoneFlag(DoneFlag),            // out 1
                        .OutputTrue(InternalMemIn)     // out 32
                        );
    
    
endmodule
