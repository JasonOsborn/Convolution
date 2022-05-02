`timescale 1ns / 1ps

module UnoInputAndMemory #(parameter MaxImageSize = 1280)(   input clk,
                            output reg unoClk = 0,
                            input SerialComms,
                            output reg SerialOut = 0,
                            
                            input [15:0] MemAddress,
                            input [31:0] InternalMemIn,
                            output [7:0] InternalMemOut,
                            input WriteFlag,
                            input DoneFlag,
                            input StartFlag,
                            input Reset
                            );
    
    reg [4:0] counter = 0;
    reg prevUnoClk = 0;
    
    reg [(2*MaxImageSize)-1:0] Memory = 0;
        // Reserved; [MaxImageSize-1:0] for image in
        // Reserved; [2*MaxImageSize-1:MaxImageSize] for image out
    
    wire [3:0] FlagsController;
    assign FlagsController = {WriteFlag,DoneFlag,StartFlag,Reset};
    
    assign InternalMemOut = Memory [MemAddress*8+:7];
    
    always@(posedge clk) begin
        casex(FlagsController)
            4'bxxx1: Memory = 0; // Reset
            4'b0100: begin       // DoneFlag
                SerialOut = Memory[MaxImageSize];
                Memory[2*MaxImageSize-1:MaxImageSize] = Memory[2*MaxImageSize-1:MaxImageSize] >> 1;
            end
            4'b0010: begin       // StartFlag
                if((~prevUnoClk)&unoClk) begin
                    Memory[MaxImageSize-1:0] = Memory[MaxImageSize-1:0] + SerialComms;
                    Memory[MaxImageSize-1:0] = Memory[MaxImageSize-1:0] << 1;
                end
            end
            4'b1000: begin      // Write flag
                Memory[MemAddress*8+:31] = InternalMemIn;
            end
        endcase
    end
    
    always @(posedge clk) begin
        if(counter < 24)
            counter = counter + 1;
        else begin
            prevUnoClk = unoClk;
            unoClk = ~unoClk;
            counter = 0;
        end
    end
endmodule
