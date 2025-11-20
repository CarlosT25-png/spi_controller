`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 02:57:01 PM
// Design Name: 
// Module Name: serial_clock
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


module serial_clock #(
    parameter DATA_WIDTH = 32 // number of SCLK periods (bits)
)(
    input        clk,        // system clock
    input        reset_n,    // active-low reset
    input        i_start,    // start pulse/level
    input        i_cpol,     // clock polarity (idle level)
    input  [3:0] i_divider,  // clock divider for SCLK
    output reg   sclk        // serial clock output
);

    // counts how many SCLK *periods* (bits) have been generated
    reg [$clog2(DATA_WIDTH):0] cnt;

    // divider counter (half-period generation)
    reg [3:0] tick_cnt;

    // 0 = IDLE, 1 = SENDING
    reg sending;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // async reset
            sending  <= 1'b0;
            cnt      <= 'd0;
            tick_cnt <= 4'd0;
            sclk     <= i_cpol;
        end else begin
            if (!sending) begin
                // IDLE state
                sclk     <= i_cpol;
                tick_cnt <= 4'd0;
                cnt      <= 'd0;

                if (i_start) begin
                    // start a new burst
                    sending  <= 1'b1;
                    sclk     <= i_cpol;  // make sure we start from idle
                    tick_cnt <= 4'd0;
                    cnt      <= 'd0;
                end

            end else begin
                // SENDING state
                if (cnt == DATA_WIDTH) begin
                    // done: go back to idle
                    sending  <= 1'b0;
                    sclk     <= i_cpol;
                    tick_cnt <= 4'd0;
                end else begin
                    // still generating SCLK
                    if (tick_cnt == i_divider) begin
                        tick_cnt <= 4'd0;

                        // toggle SCLK
                        sclk <= ~sclk;

                        // count *full periods*: increment when SCLK returns to idle
                        if (~sclk == i_cpol) begin
                            cnt <= cnt + 1'b1;
                        end
                    end else begin
                        tick_cnt <= tick_cnt + 1'b1;
                    end
                end
            end
        end
    end

endmodule