`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2025 04:13:15 PM
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


//module tb;
//    reg clk = 0;
//    reg rst = 0;
//    reg tx_enable = 0;
//    wire mosi;
//    wire ss;
//    wire sclk;
//    always #5 clk = ~clk;
//    initial begin
//    rst = 1;
//    repeat(5) @(posedge clk);
//    rst = 0;
//    end
//    initial begin 
//    tx_enable = 0;
//    repeat(5) @(posedge clk);
//    tx_enable = 1;
//    end 
//    spi_without_modes dut (clk, rst, tx_enable, mosi, ss, sclk);
//endmodule

module tb;

    reg clk = 0;
    reg rst = 0;
    reg tx_enable = 0;
    wire [7:0] dout;
    
    
    always #5 clk = ~clk;
    
    initial begin
    rst = 1;
    repeat(5) @(posedge clk);
    rst = 0;
    end

    initial begin
    tx_enable = 0;
    repeat(5) @(posedge clk);
    tx_enable = 1;
    end

top dut (clk, rst, tx_enable, dout);

endmodule
