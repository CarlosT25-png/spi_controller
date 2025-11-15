`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 09:28:30 PM
// Design Name: 
// Module Name: fifo_buffer
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


module fifo_buffer #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 8 // It has to be a power of 2 number 
) (
    input clk,
    input reset_n,
    input i_write_en, i_read_en,
    input [DATA_WIDTH-1:0] i_data_in,
    output o_is_full, o_is_empty,
    output [DATA_WIDTH-1:0] o_data_out
    );

    // How many bits we need for our pointers
    localparam reg ADDR_WIDTH = $clog2(DEPTH);

    // pointer
    reg [ADDR_WIDTH:0] read_ptr, write_ptr, size_cnt;

    // memory
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];


    // write into memory
    always @(posedge clk) begin
        if (~reset_n) begin
            size_cnt <= 0; // Reset size counter
            write_ptr <= 0;
            for (int i = 0; i < DATA_WIDTH; i = i + 1) begin
                memory[i] <= 0;
            end 
        end else begin
            if (i_write_en && ~o_is_full) begin
                memory[write_ptr] <= i_data_in;
                write_ptr = write_ptr + 1;
                size_cnt <= size_cnt + 1; // add 1 to the counter
            end
        end
    end

    // read memory
    always @(posedge clk) begin
        if (~reset_n) begin
            read_ptr <= 0;
            o_data_out <= 0;
        end else begin
            if (i_read_en && ~o_is_empty) begin
                o_data_out <= memory[read_ptr];
                read_ptr = read_ptr + 1;
                size_cnt <= size_cnt - 1; // decrement size
            end else
                o_data_out = 0;
        end
    end

    // Output fifo is full or empty
    always @(*) begin
        o_is_empty = 0;
        o_is_full = 0;

        if (size_cnt == DEPTH) begin
            o_is_full = 1;
        end else if (size_cnt == 0) begin
            o_is_empty = 1;
        end
    end
    
    
    
endmodule
