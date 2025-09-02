`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2025 06:24:34 PM
// Design Name: 
// Module Name: fsm_spi
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


module fsm_spi(
    input wire clk, rst, tx_enable,
    output reg mosi, cs,
    output wire sclk
    );
    typedef enum logic {idle = 0, tx_data = 1} state_type;
    state_type state;
    reg [2:0] ccount=0;
    reg [2:0] count=0;
    reg spi_clk = 0;
    reg [7:0] din = 8'hff;
    // generating sclk from clk
    always@ (posedge clk) begin
    if(!rst && tx_enable) begin
    if(ccount<3) ccount <= ccount+1;
    else begin
    ccount<=0;
    spi_clk<=~spi_clk;
    end
    end 
    end
    
    // master
    always@ (posedge sclk) begin
    case(state)
    idle: begin
    mosi<=1'b0;
    cs<=1'b1;
    if(tx_enable && !rst) begin
    state<=tx_data;
    cs<=1'b0;
    end
    end
    tx_data: begin
    if(count<8)begin
    mosi<=din[7-count];
    count<=count+1;
    end
    else begin
    mosi<=0;
    cs<=1'b1;
    state<=idle;
    end
    end
    default: state<=idle;
    endcase
    end
    assign sclk = spi_clk;
endmodule

//slave
module spi_slave (
input sclk, mosi,cs,
output [7:0] dout,
output reg done 
);

integer count = 0;
typedef enum logic  {idle = 0, sample = 1 } state_type;
state_type state;

reg [7:0] data = 0;

  
always@(negedge sclk)
begin
case (state)

idle: begin
done <= 1'b0;

if(cs == 1'b0)
state <= sample;
else
state <= idle;
end

sample: 
begin
        if(count < 8)
        begin
        count <= count + 1;
        data <= {data[6:0],mosi};
        state <= sample;
        end
        else
        begin
        count <= 0;
        state <= idle;
        done  <= 1'b1;
        end
end

default : state <= idle;
endcase

end

assign dout = data;

endmodule

//integrating both of them
module top
(
input clk, rst, tx_enable,
output [7:0] dout,
output done
);

wire mosi, ss, sclk;

fsm_spi    spi_m (clk, rst, tx_enable, mosi, ss, sclk);
spi_slave  spi_s (sclk, mosi,ss, dout, done);

endmodule