`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 10:08:55 PM
// Design Name: 
// Module Name: fifo_buffer_tb
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


module fifo_buffer_tb();
    logic clk, reset_n, i_read_en, i_write_en, o_is_empty, o_is_full;
    logic [31:0] i_data_in, o_data_out;

    fifo_buffer #(
        .DATA_WIDTH(32),
        .DEPTH(4)
    ) fifo_buffer_instance (
        .clk(clk),
        .reset_n(reset_n),
        .i_write_en(i_write_en),
        .i_read_en(i_read_en),
        .i_data_in(i_data_in),
        .o_is_full(o_is_full),
        .o_is_empty(o_is_empty),
        .o_data_out(o_data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_n = 0;
        i_read_en = 0;
        i_write_en = 0;
        i_data_in = 0;

        #17;
        reset_n = 1;
        i_write_en = 1;
        i_data_in = 32'd237;

        #10;

        i_write_en = 1;
        i_data_in = 32'd1987;

        #10;

        i_write_en = 1;
        i_data_in = 32'd561;

        #10;

        i_write_en = 1;
        i_data_in = 32'd88777;

        #10;

        i_write_en = 0;

        #20;

        i_read_en = 1;

        #40;

        i_read_en = 0;

        #20;

        $finish;
    end
    
    
endmodule
