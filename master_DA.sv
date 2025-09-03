`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2025 12:35:35 AM
// Design Name: 
// Module Name: master_DA
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


module master_DA(
    input [11:0] data_in,
    input clk_100mhz,
    input st_wrt,
    output reg done,
    output reg mosi,
    output reg sclk,
    output reg cs
    );
    typedef enum logic [1:0] {idle_dac = 0, init_dac = 1, dac_data = 2, send_data = 3} state_type;
    state_type state;
    integer count = 0;
    reg [31:0] data = 32'h0;
    reg [31:0] setup_dac = 32'h08000001;
    reg dac_init = 1'b0;
    reg clk_1mhz = 1'b0;
    integer clk_div = 0;
    
    //sclk generation
    always@ (posedge clk_100mhz) begin
    if(clk_div==49) begin
    clk_div <= 0;
    clk_1mhz <= ~clk_1mhz;
    end
    else begin
    clk_div <= clk_div+1;
    end
    end
    
    //DAC main process
    always@ (posedge clk_1mhz or negedge st_wrt) begin
    if(!st_wrt) begin
    state <= idle_dac;
    cs <= 1'b1;
    mosi <= 1'b0;
    done <= 1'b0;
    count <= 0;
    end else begin
    case (state)
    idle_dac : begin
    cs <= 1'b1;
    mosi <= 1'b0;
    count <= 0;
    done  <= 1'b0; 
    if(!dac_init) begin
    state <= init_dac;
    end
    else begin
    state <= dac_data;
    end
    end
    init_dac : begin
    if(count<32) begin
    cs<=1'b0;
    mosi<=setup_dac[31-count];
    count<=count+1;
    state<=init_dac;
    end
    else begin
    count<=0;
    dac_init<=1'b1;
    cs<=1'b1;
    state<=dac_data;
    end
    end
    dac_data: begin
    cs <= 1'b1;
    mosi <= 1'b0;
    data <= {12'h030, data_in, 8'h00};
    state <= send_data;
    end
    send_data: begin
    if(count<32) begin
    cs <= 1'b0;
    mosi <= data[31-count];
    count <= count + 1;
    state<=send_data;
    end else begin
    count <= 0;
    cs <= 1'b1;
    done <= 1'b1;
    state <= idle_dac;
    end
    end
    default: state <= idle_dac;
    endcase
    end
    end
    assign sclk = clk_1mhz;
endmodule
