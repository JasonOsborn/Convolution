`timescale 1ns / 1ps

module HA(a,b,sum,carry);
    input a,b;
    output sum, carry;
    
    assign sum = a^b;
    assign carry = a&b;
    
endmodule

module FA(a,b,cin,sum,carry);
    input a,b,cin;
    output sum, carry;
    
    assign sum = a^b^cin;
    assign carry = a&b | (a^b) & cin;

endmodule

module wallace_Tree(input [7:0] x,y, output [15:0] product);
    reg p [7:0][7:0]; //stores partial product 
    wire [55:0] s,c; //sum and carry 
    
    integer i,j;
    
    //Generate partial products
    always @(y,x)
    begin
        for(i =0; i <= 7; i = i +1)
            for(j = 0; j <= 7; j = j + 1)
                p[j][i] <= x[j] & y[i];
    end      
    
    //P1
    HA ha_11(.sum(s[0]),.carry(c[0]), .a(p[1][0]), .b( p[0][1])); 
    //P2
    FA fa_21( .sum(s[1]), .carry(c[1]), .a(p[2][0]), .b( p[1][1]), .cin( (c[0]) ) );
    HA ha_21( .sum(s[2]), .carry(c[2]), .a(p[0][2]), .b( s[1]));                                              
    //P3
    FA fa_31( .sum(s[3]), .carry(c[3]), .a(p[2][1]), .b( p[3][0]), .cin( c[1]) );
    FA fa_32( .sum(s[4]), .carry(c[4]), .a(p[1][2]), .b( s[3]), .cin( c[2]) );
    HA ha_31( .sum(s[5]), .carry(c[5]), .a(p[0][3]), .b( s[4]));                                               
    //P4
    FA fa_41( .sum(s[6]), .carry(c[6]), .a(p[4][0]), .b( p[3][1]), .cin( c[3]) );
    FA fa_42( .sum(s[7]), .carry(c[7]), .a(p[2][2]), .b(s[6]), .cin( c[4]) );
    FA fa_43( .sum(s[8]), .carry(c[8]), .a(p[1][3]), .b(s[7]), .cin( c[5]) );
    HA ha_41( .sum(s[9]), .carry(c[9]), .a(p[0][4]), .b( s[8]));                                             
    //P5
    FA fa_51( .sum(s[10]), .carry(c[10]), .a(p[5][0]), .b( p[4][1]), .cin( c[6]) );
    FA fa_52( .sum(s[11]), .carry(c[11]), .a(p[3][2]), .b( s[10]), .cin( c[7]) );
    FA fa_53( .sum(s[12]), .carry(c[12]), .a(p[2][3]), .b( s[11]), .cin( c[8]) );
    FA fa_54( .sum(s[13]), .carry(c[13]), .a(p[1][4]), .b( s[12]), .cin( c[9]) );
    HA ha_55( .sum(s[14]), .carry(c[14]), .a(p[0][5]), .b( s[13]));                                     
    //P6
    FA fa_61( .sum(s[15]), .carry(c[15]), .a(p[6][0]), .b( p[5][1]), .cin( c[10]) );
    FA fa_62( .sum(s[16]), .carry(c[16]), .a(p[4][2]), .b( s[15]), .cin( c[11]) );
    FA fa_63( .sum(s[17]), .carry(c[17]), .a(p[3][3]), .b( s[16]), .cin( c[12]) );
    FA fa_64( .sum(s[18]), .carry(c[18]), .a(p[2][4]), .b( s[17]), .cin( c[13]) );
    FA fa_65( .sum(s[19]), .carry(c[19]), .a(p[1][5]), .b( s[18]), .cin( c[14]) );
    HA ha_42( .sum(s[20]), .carry(c[20]), .a(p[0][6]), .b( s[19]));                                      
    //P7
    FA fa_71( .sum(s[21]), .carry(c[21]), .a(p[7][0]), .b( p[6][1]), .cin( c[15]) );
    FA fa_72( .sum(s[22]), .carry(c[22]), .a(p[5][2]), .b( s[21]), .cin( c[16]) );
    FA fa_73( .sum(s[23]), .carry(c[23]), .a(p[4][3]), .b( s[22]), .cin( c[17]) );
    FA fa_74( .sum(s[24]), .carry(c[24]), .a(p[3][4]), .b( s[23]), .cin( c[18]) );
    FA fa_75( .sum(s[25]), .carry(c[25]), .a(p[2][5]), .b( s[24]), .cin( c[19]) );
    FA fa_76( .sum(s[26]), .carry(c[26]), .a(p[1][6]), .b( s[25]), .cin( c[20]) );
    HA ha_71( .sum(s[27]), .carry(c[27]), .a(p[0][7]), .b( s[26]));                                      
    //P8
    FA fa_81( .sum(s[28]), .carry(c[28]), .a(p[7][1]), .b( p[6][2]), .cin( c[21]) );
    FA fa_82( .sum(s[29]), .carry(c[29]), .a(p[5][3]), .b( s[28]), .cin( c[22]) );
    FA fa_83( .sum(s[30]), .carry(c[30]), .a(p[4][4]), .b( s[29]), .cin( c[23]) );
    FA fa_84( .sum(s[31]), .carry(c[31]), .a(p[3][5]), .b( s[30]), .cin( c[24]) );
    FA fa_85( .sum(s[32]), .carry(c[32]), .a(p[2][6]), .b( s[31]), .cin( c[25]) );
    FA fa_86( .sum(s[33]), .carry(c[33]), .a(p[1][7]), .b( s[32]), .cin( c[26]) );
    HA ha_81( .sum(s[34]), .carry(c[34]), .a(s[33]), .b( c[27]));                                          
    //P9
    FA fa_91( .sum(s[35]), .carry(c[35]), .a(p[7][2]), .b( p[6][3]), .cin( c[28]) );
    FA fa_92( .sum(s[36]), .carry(c[36]), .a(p[5][4]), .b( s[35]), .cin( c[29]) );
    FA fa_93( .sum(s[37]), .carry(c[37]), .a(p[4][5]), .b( s[36]), .cin( c[30]) );
    FA fa_94( .sum(s[38]), .carry(c[38]), .a(p[3][6]), .b( s[37]), .cin( c[31]) );
    FA fa_95( .sum(s[39]), .carry(c[39]), .a(p[2][7]), .b( s[38]), .cin( c[32]) );
    FA fa_96( .sum(s[40]), .carry(c[40]), .a(s[39]), .b( c[33]), .cin( c[34]) );                         
    //P10
    FA fa_101( .sum(s[41]), .carry(c[41]), .a(p[7][3]), .b( p[6][4]), .cin( c[35]) );
    FA fa_102( .sum(s[42]), .carry(c[42]), .a(p[5][5]), .b( s[41]), .cin( c[36]) );
    FA fa_103( .sum(s[43]), .carry(c[43]), .a(p[4][6]), .b( s[42]), .cin( c[37]) );
    FA fa_104( .sum(s[44]), .carry(c[44]), .a(p[3][7]), .b( s[43]), .cin( c[38]) );
    FA fa_105( .sum(s[45]), .carry(c[45]), .a(s[44]), .b( c[39]), .cin( c[40]) );                   
    //P11
    FA fa_111( .sum(s[46]), .carry(c[46]), .a(p[7][4]), .b( p[6][5]), .cin( c[41]) );
    FA fa_112( .sum(s[47]), .carry(c[47]), .a(p[5][6]), .b( s[46]), .cin( c[42]) );
    FA fa_113( .sum(s[48]), .carry(c[48]), .a(p[4][7]), .b( s[47]), .cin( c[43]) );
    FA fa_114( .sum(s[49]), .carry(c[49]), .a(s[48]), .b( c[44]), .cin( c[45]) );                     
    //P12
    FA fa_121( .sum(s[50]), .carry(c[50]), .a(p[7][5]), .b( p[6][6]), .cin( c[46]) );
    FA fa_122( .sum(s[51]), .carry(c[51]), .a(p[5][7]), .b(s[50]), .cin( c[47]) );
    FA fa_123( .sum(s[52]), .carry(c[52]), .a(s[51]), .b(c[48]), .cin( c[49]) );                    
    //P13
    FA fa_131( .sum(s[53]), .carry(c[53]), .a(p[7][6]), .b( p[6][7]), .cin( c[50]) );
    FA fa_132( .sum(s[54]), .carry(c[54]), .a(s[53]), .b(c[51]), .cin( c[52]) );                 
    //P14
    FA fa_141( .sum(s[55]), .carry(c[55]), .a(p[7][7]), .b(c[53]), .cin( c[54]) );             

    assign product = {c[55],s[55],s[54],s[52],s[49],s[45],s[40],s[34],s[27],s[20],s[14],s[9],s[5],s[2],s[0],p[0][0]}; //p[0][0]=P0
endmodule