`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2025 01:35:34 AM
// Design Name: 
// Module Name: tb
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


module tb;

    reg clk100mhz = 0;
    wire cs;
    wire mosi;
    wire sclk;
    reg st_wrt = 0;
    reg [11:0] data_in = 0;
    wire done;
    
    
    master_DA dut (data_in, clk100mhz, st_wrt, done, mosi, sclk, cs);
    
    always#5 clk100mhz = ~clk100mhz;
    
    initial begin
    st_wrt = 1;
    data_in = 12'b101010101010;
    end



endmodule
