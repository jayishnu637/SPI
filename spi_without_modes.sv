`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2025 03:30:49 PM
// Design Name: 
// Module Name: spi_without_modes
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


module spi_without_modes(
    input wire clk,
    input wire rst,
    input wire tx_enable,
    output reg mosi,
    output reg cs,
    output wire sclk
    );
typedef enum logic [1:0]{idle = 0, start_tx = 1, data_tx = 2, end_tx = 3} state_type;
state_type state, next_state;
reg [7:0] din = 8'hff;
reg spi_clk = 0;
reg [2:0] count = 0;
integer bit_count = 0;

// generating sclk
always@(posedge clk) begin
case(state)
idle: begin
spi_clk <= 0;
end
start_tx, data_tx, end_tx: begin
if(count<3'b011 || count == 3'b111) spi_clk<=1'b1;
else spi_clk<=1'b0;
end
endcase
end

//sense reset
always@(posedge clk) begin
if(rst) begin
state <= idle;
end
else state<=next_state;
end

//next_state decoder
always@(*)begin
case(state)
idle: begin
mosi = 1'b0;
cs = 1'b1;
if(tx_enable) next_state = start_tx;
else next_state = idle;
end
start_tx: begin
cs = 1'b0;
if(count == 3'b111) next_state = data_tx;
else next_state = start_tx;
end
data_tx: begin
mosi = din[7-bit_count];
if(bit_count != 8)begin
next_state = data_tx;
end
else begin
next_state = end_tx;
mosi = 1'b0;
end
end
end_tx: begin
mosi = 1'b0;
if(count == 3'b111) next_state = idle;
else next_state = end_tx;
end
endcase
end

//counter
always@(posedge clk) begin
case(state)
idle: begin
count<=0;
bit_count<=0;
end
start_tx: begin
count<=count+1;
end
data_tx: begin
if(bit_count != 8) begin
if(count<3'b111) begin
count<=count+1;
end
else begin
count<=0;
bit_count<=bit_count+1;
end
end
end
end_tx: begin
count<=count+1;
bit_count<=0;
end
default: begin
count<=0;
bit_count<=0;
end
endcase
end
assign sclk = spi_clk;
endmodule

module spi_slave(
    input sclk, mosi, cs,
    output [7:0] dout,
    output reg done);
    integer count = 0;
    typedef enum logic {idle= 0, sample= 1} state_type;
    state_type state;
    reg [7:0] data = 0;
    always@(negedge sclk) begin
    case (state)
    idle : begin
    done<=1'b0;
    if(cs) state <= idle;
    else state <= sample;
    end
    sample : begin
    if(count<8) begin
    count <= count+1;
    data <= {data[6:0], mosi};
    state <= sample;
    end
    else begin
    count<=0;
    state<=idle;
    done<=1'b1;
    end
    end
    default: state<=idle;
    endcase
    end
    assign dout = data;
endmodule

module top
(
input clk, rst, tx_enable,
output [7:0] dout,
output done
);

wire mosi, ss, sclk;

spi_without_modes    spi_m (clk, rst, tx_enable, mosi, ss, sclk);
spi_slave  spi_s (sclk, mosi,ss, dout, done);

endmodule