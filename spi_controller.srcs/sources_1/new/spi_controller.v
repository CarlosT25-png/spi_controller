`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 09:08:22 PM
// Design Name: 
// Module Name: spi_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: SPI master controller with up to 4 independandt slaves
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_controller #(DATA_WIDTH = 32) (
    input clk,
    input reset_n,
    input i_miso, // master in slave out ; slave -> master
    input [DATA_WIDTH-1:0] i_data,
    input i_request, // 1 if a new value wants to be send through spi
    input i_cpol, // clock polarity
    input i_cpha, // clock phase 
    input [1:0] i_cs_selector, // slave selecror
    output sclk, // serial clock
    output reg [DATA_WIDTH-1:0] o_mosi, // master out slave in ; master -> slave
    output reg o_cs0, // slave 0
    output reg o_cs1, // slave 1
    output reg o_cs2, // slave 2
    output reg o_cs3 // slave 3
);

    // TODO SPI is full

    // serial clok

    reg i_start;
    reg [3:0] i_divider;

    serial_clock #(
        .DATA_WIDTH(DATA_WIDTH)
    ) serial_clock_instance (
        .clk(clk),
        .reset_n(reset_n),
        .i_start(i_start),
        .i_cpol(i_cpol),
        .i_divider(i_divider),
        .sclk(sclk)
    );

    // fifo buffer for data

    reg fifo_data_write_en, fifo_data_read_en;
    wire fifo_data_o_is_full, fifo_data_o_is_empty;
    reg fifo_cs_write_en, fifo_cs_read_en;
    wire fifo_cs_o_is_full, fifo_cs_o_is_empty;
    reg [DATA_WIDTH-1:0] fifo_data_in;
    wire [DATA_WIDTH-1:0] fifo_data_out;
    reg [1:0] fifo_cs_in;
    wire [1:0] fifo_cs_out;

    fifo_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(4)
    ) fifo_buffer_instance_data (
        .clk(clk),
        .reset_n(reset_n),
        .i_write_en(fifo_data_write_en),
        .i_read_en(fifo_data_read_en),
        .i_data_in(fifo_data_in),
        .o_is_full(fifo_data_o_is_full),
        .o_is_empty(fifo_data_o_is_empty),
        .o_data_out(fifo_data_out)
    );

    // fifo buffer for cs selector
    fifo_buffer #(
        .DATA_WIDTH(2),
        .DEPTH(4)
    ) fifo_buffer_instance_cs (
        .clk(clk),
        .reset_n(reset_n),
        .i_write_en(fifo_cs_write_en),
        .i_read_en(fifo_cs_read_en),
        .i_data_in(fifo_cs_in),
        .o_is_full(fifo_cs_o_is_full),
        .o_is_empty(fifo_cs_o_is_empty),
        .o_data_out(fifo_cs_out)
    );

    // cpha 1
    always @(negedge sclk) begin
        if(i_cpha == 1) begin
            if (sending) begin
                // i_start <= 0; // serial clock is already running at this point
                o_mosi <= shift_reg[cnt];
                case (cs_reg)
                    2'b00 : o_cs0 <= 0;
                    2'b01 : o_cs1 <= 0;
                    2'b10 : o_cs2 <= 0;
                    2'b11 : o_cs3 <= 0;
                endcase

                cnt <= cnt + 1;
                if (cnt == DATA_WIDTH) begin
                    sending <= 0;

                end
            end
        end
    end

    // cpha 0
    always @(posedge sclk) begin
        if (i_cpha == 0) begin
            if (sending) begin
                // i_start <= 0; // serial clock is already running at this point
                o_mosi <= shift_reg[cnt];
                case (cs_reg)
                    2'b00 : o_cs0 <= 0;
                    2'b01 : o_cs1 <= 0;
                    2'b10 : o_cs2 <= 0;
                    2'b11 : o_cs3 <= 0;
                endcase

                cnt <= cnt + 1;
                if (cnt == DATA_WIDTH) begin
                    sending <= 0;

                end
            end
        end
    end



    // state
    reg sending;
    reg [DATA_WIDTH-1:0] shift_reg;
    reg [1:0] cs_reg;
    reg [5:0] cnt;
    // fifo r/w & states
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            // serial clock
            i_divider <= 4'd1;
            i_start <= 0;
            // spi
            o_cs0 <= 1;
            o_cs1 <= 1;
            o_cs2 <= 1;
            o_cs3 <= 1;
            o_mosi <= i_cpol;
            sending <= 0;
        end else begin
            // write into fifo
            if(i_request && ~fifo_data_o_is_full) begin
                fifo_data_write_en <= 1;
                fifo_cs_write_en <= 1;
                fifo_data_in <= i_data;
                fifo_cs_in <= i_cs_selector;
            end else begin
                fifo_data_write_en <= 0;
                fifo_cs_write_en <= 0;
                fifo_data_in <= 0;
                fifo_cs_in <= 0;
            end

            if(!sending) begin
                o_mosi <= i_cpol; // idle state
                o_cs0 <= 1;
                o_cs1 <= 1;
                o_cs2 <= 1;
                o_cs3 <= 1;

                // read from fifo queue; if there's a value start sending
                if(~fifo_data_o_is_empty) begin
                    fifo_data_read_en <= 1;
                    fifo_cs_read_en <= 1;
                    sending <= 1;

                    $display("fifo is not empty");
                end
            end else begin
                fifo_data_read_en <= 0; // stop reading
                fifo_cs_read_en <= 0;

                $display("Started serial clock");
                // start serial clock
                i_divider <= 4'd1;
                i_start <= 1;

                // save info into the register
                shift_reg <= fifo_data_out;
                cs_reg <= fifo_cs_out;

                // bit counter
                cnt <= 0;
            end
        end
    end

    // write into fifo
    // always @(*) begin
    //     fifo_data_write_en = 0;
    //     fifo_cs_write_en = 0;
    //     fifo_data_in = 0;
    //     fifo_cs_in = 0;
    //     if(i_request && ~fifo_data_o_is_full) begin
    //         fifo_data_write_en = 1;
    //         fifo_cs_write_en = 1;
    //         fifo_data_in = i_data;
    //         fifo_cs_in = i_cs_selector;
    //     end
    // end




endmodule
