`timescale 1ns / 1ps


module Lookahead_32Bit_A(
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    
    // Carry-Out
    output Cout
    );
    
    //Propogation
    wire [2:0] Carry;
    
    //8-Bit
    Lookahead_8Bit  LA[3:0] (.A(A), .B(B), .Cin({Carry[2:0],1'b0}), .Cout({Cout,Carry[2:0]}), .S(S));
endmodule


module Lookahead_8Bit #(parameter N = 7)(
        input  [N:0] A,B,
        input  Cin,
        output Cout,
        output [N:0] S
    );
    
    wire [N+1:0] Carry;
    assign Cout = Carry[N+1];
    assign Carry[0] = Cin;
    
    Full_Adder           AdderTest[N:0]  (  .A   (A     [N:0]),
                                            .B   (B     [N:0]),
                                            .Cin ({Carry[N:0]}),
                                            .S   (S     [N:0])
                                          );
    
    Lookahead_Logic_8Bit #(N) Logic( .A(A), .B(B), .Cin(Cin), .Cout(Carry[N+1:1]));
    
endmodule



module Lookahead_Logic_8Bit #(parameter N = 7)(
    input  [N:0] A,
    input  [N:0] B,
    input        Cin,
    output [N:0] Cout
    );
    
    
    wire [N:0] P, G;
    wire [N+1:0] G_Work;
    reg [N:0] C = 0, InnerWorks = 0, InnerWorks2 = 0;
    
    assign P = A ^ B;
    assign G = A & B;
    assign G_Work = {G,Cin};
    
    integer i = 0,j = 0, k = 0;
    
    assign Cout = C;
    
    always @(*) begin
        {i,j,k} = 0;
        for(i = 0; i < N+1; i = i + 1) begin // if i = 2
            C[i] = G_Work[i+1];
            for(j = 0; j < i + 1; j = j + 1) begin // 0,1,2
                InnerWorks2 = {N+1{1'b1}};
                for(k = j; k < i + 1; k = k + 1) begin //(0,1,2),(1,2),(2)
                    InnerWorks2[j] = InnerWorks2[j] & P[k];
                end
                
                InnerWorks[j] = InnerWorks2[j]&G_Work[j];
                C[i] = (C[i] | InnerWorks[j]);
            end
        end
    end
endmodule

module Full_Adder(
    input  A,
    input  B,
    input  Cin,
    output S,
    output Cout
    );
    
    wire [2:0] Gate;
    
    assign Gate[0] = A ^ B;
    assign Gate[1] = A & B;
    assign Gate[2] = Gate[0] & Cin;
    
    assign S = Gate[0] ^ Cin;
    assign Cout = Gate[1] | Gate[2];
    
endmodule
