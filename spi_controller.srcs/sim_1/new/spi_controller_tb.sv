`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 10:19:08 PM
// Design Name: 
// Module Name: spi_controller_tb
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


module spi_controller_tb(
    );

    logic clk, reset_n;
    logic i_miso, i_cpol, i_request, i_cpha, sclk, o_mosi, o_cs0, o_cs1, o_cs2, o_cs3;
    logic [31:0] i_data;
    logic [1:0] i_cs_selector;

    spi_controller #(
        .DATA_WIDTH(32)
    ) spi_controller_instance (
        .clk(clk),
        .reset_n(reset_n),
        .i_miso(i_miso),
        .i_request(i_request),
        .i_data(i_data),
        .i_cpol(i_cpol),
        .i_cpha(i_cpha),
        .i_cs_selector(i_cs_selector),
        .sclk(sclk),
        .o_mosi(o_mosi),
        .o_cs0(o_cs0),
        .o_cs1(o_cs1),
        .o_cs2(o_cs2),
        .o_cs3(o_cs3)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_n = 0;
        i_miso = 0;
        i_data = 0;
        i_request = 0;
        i_cpol = 1;
        i_cpha = 0;
        i_cs_selector = 2'd2;
        
        #15;
        reset_n = 1;

        #10;
        i_data = 32'd427;
        i_request = 1;
        #10;
        i_request = 0;


        #400;
        $finish;
    end
    
    
endmodule
