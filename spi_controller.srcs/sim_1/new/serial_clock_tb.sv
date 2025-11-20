`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 03:37:02 PM
// Design Name: 
// Module Name: serial_clock_tb
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


module serial_clock_tb();

    logic clk, reset_n, i_start, i_cpol, sclk;
    logic [3:0] i_divider;

    serial_clock #(
        .DATA_WIDTH(4)
    ) serial_clock_instance (
        .clk(clk),
        .reset_n(reset_n),
        .i_start(i_start),
        .i_cpol(i_cpol),
        .i_divider(i_divider),
        .sclk(sclk)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin
        reset_n = 0;
        i_start = 0;
        i_cpol = 1;
        i_divider = 4'd1;

        #20;

        reset_n = 1;

        #5;
        i_start = 1;

        #20;
        i_start = 0;

        #640;

        $finish;

    end
    
    
endmodule
