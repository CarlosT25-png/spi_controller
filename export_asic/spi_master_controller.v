// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: UTSA
// // Engineer: Carlos Torres Valle
// // 
// // Create Date: 11/19/2025 09:08:22 PM
// // Design Name: SPI Controller
// // Module Name: spi_controller
// // Project Name: SPI Master Controller
// // Target Devices: ASIC DESIGN
// // Tool Versions: AMD VIVADO 2025.1 & Cadence INNOVUS
// // Description: 
// // 
// // Dependencies: serial_clock.v fifo_buffer.v
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments: SPI master controller with up to 4 independandt slaves
// // 
// //////////////////////////////////////////////////////////////////////////////////


// //////////////////////////////////////////////////////////////////////////////////
// // 1. FIFO Buffer


// module fifo_buffer #(
//     parameter DATA_WIDTH = 32,
//     parameter DEPTH = 8 // It has to be a power of 2 number 
// ) (
//     input clk,
//     input reset_n,
//     input i_write_en, i_read_en,
//     input [DATA_WIDTH-1:0] i_data_in,
//     output reg o_is_full, o_is_empty,
//     output reg [DATA_WIDTH-1:0] o_data_out
// );

//     // How many bits we need for our pointers
//     localparam integer ADDR_WIDTH = $clog2(DEPTH);

//     // pointer
//     reg [ADDR_WIDTH-1:0] read_ptr, write_ptr;
//     reg [ADDR_WIDTH:0]   size_cnt;


//     // memory
//     reg [DATA_WIDTH-1:0] memory [0: DEPTH-1];


//     integer i;

//     // write into memory
//     always @(posedge clk) begin
//         if (~reset_n) begin
//             write_ptr <= 0;
//             for (i = 0; i < DEPTH; i = i + 1) begin
//                 memory[i] <= 0;
//             end
//         end else begin
//             if (i_write_en && ~o_is_full) begin
//                 memory[write_ptr] <= i_data_in;
//                 write_ptr <= write_ptr + 1;
//             end
//         end
//     end

//     // read memory
//     always @(posedge clk) begin
//         if (~reset_n) begin
//             read_ptr <= 0;
//             o_data_out <= 0;
//         end else begin
//             if (i_read_en && ~o_is_empty) begin
//                 o_data_out <= memory[read_ptr];
//                 read_ptr <= read_ptr + 1;
//             end
//         end
//     end

//     always @(posedge clk) begin
//         if (~reset_n) begin
//             size_cnt <= 0;
//         end else begin
//             case ({i_write_en && ~o_is_full, i_read_en && ~o_is_empty})
//                 2'b10: size_cnt <= size_cnt + 1; // write only
//                 2'b01: size_cnt <= size_cnt - 1; // read only
//                 default: size_cnt <= size_cnt; // no change or both
//             endcase
//         end
//     end



//     // Output fifo is full or empty
//     always @(*) begin
//         o_is_empty = 0;
//         o_is_full = 0;

//         if (size_cnt == DEPTH) begin
//             o_is_full = 1;
//         end else if (size_cnt == 0) begin
//             o_is_empty = 1;
//         end
//     end



// endmodule

// //////////////////////////////////////////////////////////////////////////////////
// // 2. Serial Clock

// module serial_clock #(
//     parameter DATA_WIDTH = 32 // number of SCLK periods (bits)
// )(
//     input        clk,        // system clock
//     input        reset_n,    // active-low reset
//     input        i_start,    // start pulse/level
//     input        i_cpol,     // clock polarity (idle level)
//     input  [3:0] i_divider,  // clock divider for SCLK
//     output reg   sclk        // serial clock output
// );

//     // counts how many SCLK *periods* (bits) have been generated
//     reg [$clog2(DATA_WIDTH):0] cnt;

//     // divider counter (half-period generation)
//     reg [3:0] tick_cnt;

//     // 0 = IDLE, 1 = SENDING
//     reg sending;

//     always @(posedge clk or negedge reset_n) begin
//         if (!reset_n) begin
//             // async reset
//             sending  <= 1'b0;
//             cnt      <= 'd0;
//             tick_cnt <= 4'd0;
//             sclk     <= i_cpol;
//         end else begin
//             if (!sending) begin
//                 // IDLE state
//                 sclk     <= i_cpol;
//                 tick_cnt <= 4'd0;
//                 cnt      <= 'd0;

//                 if (i_start) begin
//                     // start a new burst
//                     sending  <= 1'b1;
//                     sclk     <= i_cpol;  // make sure we start from idle
//                     tick_cnt <= 4'd0;
//                     cnt      <= 'd0;
//                 end

//             end else begin
//                 // SENDING state
//                 if (cnt == DATA_WIDTH) begin
//                     // done: go back to idle
//                     sending  <= 1'b0;
//                     sclk     <= i_cpol;
//                     tick_cnt <= 4'd0;
//                 end else begin
//                     // still generating SCLK
//                     if (tick_cnt == i_divider) begin
//                         tick_cnt <= 4'd0;

//                         // toggle SCLK
//                         sclk <= ~sclk;

//                         // count *full periods*: increment when SCLK returns to idle
//                         if (~sclk == i_cpol) begin
//                             cnt <= cnt + 1'b1;
//                         end
//                     end else begin
//                         tick_cnt <= tick_cnt + 1'b1;
//                     end
//                 end
//             end
//         end
//     end

// endmodule

// //////////////////////////////////////////////////////////////////////////////////

// module spi_controller #(DATA_WIDTH = 32) (
//     input clk,
//     input reset_n,
//     input i_miso, // master in slave out ; slave -> master
//     input [DATA_WIDTH-1:0] i_data,
//     input i_request, // 1 if a new value wants to be send through spi
//     input i_cpol, // clock polarity
//     input i_cpha, // clock phase 
//     input [1:0] i_cs_selector, // slave selecror
//     output sclk, // serial clock
//     output reg o_mosi, // master out slave in ; master -> slave
//     output reg [DATA_WIDTH-1:0] o_received_data, // master out slave in ; master -> slave
//     output reg o_cs0, // slave 0
//     output reg o_cs1, // slave 1
//     output reg o_cs2, // slave 2
//     output reg o_cs3, // slave 3
//     output o_spi_full
// );

//     // TODO implement i_miso

//     // serial clok

//     reg i_start;
//     reg [3:0] i_divider;

//     serial_clock #(
//         .DATA_WIDTH(DATA_WIDTH)
//     ) serial_clock_instance (
//         .clk(clk),
//         .reset_n(reset_n),
//         .i_start(i_start),
//         .i_cpol(i_cpol),
//         .i_divider(i_divider),
//         .sclk(sclk)
//     );

//     // fifo buffer for data

//     reg fifo_data_write_en, fifo_data_read_en;
//     wire fifo_data_o_is_full, fifo_data_o_is_empty;
//     reg fifo_cs_write_en, fifo_cs_read_en;
//     wire fifo_cs_o_is_full, fifo_cs_o_is_empty;
//     reg [DATA_WIDTH-1:0] fifo_data_in;
//     wire [DATA_WIDTH-1:0] fifo_data_out;
//     reg [1:0] fifo_cs_in;
//     wire [1:0] fifo_cs_out;

//     fifo_buffer #(
//         .DATA_WIDTH(DATA_WIDTH),
//         .DEPTH(4)
//     ) fifo_buffer_instance_data (
//         .clk(clk),
//         .reset_n(reset_n),
//         .i_write_en(fifo_data_write_en),
//         .i_read_en(fifo_data_read_en),
//         .i_data_in(fifo_data_in),
//         .o_is_full(fifo_data_o_is_full),
//         .o_is_empty(fifo_data_o_is_empty),
//         .o_data_out(fifo_data_out)
//     );

//     // fifo buffer for cs selector
//     fifo_buffer #(
//         .DATA_WIDTH(2),
//         .DEPTH(4)
//     ) fifo_buffer_instance_cs (
//         .clk(clk),
//         .reset_n(reset_n),
//         .i_write_en(fifo_cs_write_en),
//         .i_read_en(fifo_cs_read_en),
//         .i_data_in(fifo_cs_in),
//         .o_is_full(fifo_cs_o_is_full),
//         .o_is_empty(fifo_cs_o_is_empty),
//         .o_data_out(fifo_cs_out)
//     );
    
//     // state & registers
//     reg sending;
//     reg [DATA_WIDTH-1:0] miso_data_in_reg;
//     reg [DATA_WIDTH-1:0] shift_reg;
//     reg [1:0] cs_reg;
//     reg [5:0] cnt;

//     // cpha 1
//     always @(negedge sclk) begin
//         if(i_cpha == 1) begin
//             if (sending) begin
//                 // i_start <= 0; // serial clock is already running at this point
//                 $display("sending 1");
//                 o_mosi <= shift_reg[cnt];
//                 case (cs_reg)
//                     2'b00 : o_cs0 <= 0;
//                     2'b01 : o_cs1 <= 0;
//                     2'b10 : o_cs2 <= 0;
//                     2'b11 : o_cs3 <= 0;
//                 endcase

//                 cnt <= cnt - 1;
//                 if (cnt == 0) begin
//                     sending <= 0;
//                     $display("stopped sending");
//                 end
//             end
//         end
//     end

//     // cpha 0
//     always @(posedge sclk) begin
//         if (i_cpha == 0) begin
//             if (sending) begin
//                 // i_start <= 0; // serial clock is already running at this point 
                
//                 // sending info
//                 o_mosi <= shift_reg[cnt];
//                 case (cs_reg)
//                     2'b00 : o_cs0 <= 0;
//                     2'b01 : o_cs1 <= 0;
//                     2'b10 : o_cs2 <= 0;
//                     2'b11 : o_cs3 <= 0;
//                 endcase

//                 // receiving info
//                 miso_data_in_reg[cnt] <= i_miso;

//                 cnt <= cnt - 1;
//                 if (cnt == 0) begin
//                     sending <= 0;
//                     $display("stopped sending");
//                 end
//             end
//         end
//     end



//     // fifo r/w & states
//     always @(posedge clk or negedge reset_n) begin
//         if (~reset_n) begin
//             // serial clock
//             i_divider <= 4'd1;
//             i_start <= 0;
//             // spi
//             o_cs0 <= 1;
//             o_cs1 <= 1;
//             o_cs2 <= 1;
//             o_cs3 <= 1;
//             o_mosi <= i_cpol;
//             sending <= 0;
//         end else begin
//             // write into fifo
//             if(i_request && ~o_spi_full) begin
//                 fifo_data_write_en <= 1;
//                 fifo_cs_write_en <= 1;
//                 fifo_data_in <= i_data;
//                 fifo_cs_in <= i_cs_selector;
//             end else begin
//                 fifo_data_write_en <= 0;
//                 fifo_cs_write_en <= 0;
//                 fifo_data_in <= 0;
//                 fifo_cs_in <= 0;
//             end

//             if(!sending) begin
//                 o_mosi <= i_cpol; // idle state
//                 o_cs0 <= 1;
//                 o_cs1 <= 1;
//                 o_cs2 <= 1;
//                 o_cs3 <= 1;
//                 i_start <= 0; // reset sclk to idle
//                 o_received_data <= miso_data_in_reg ? miso_data_in_reg : DATA_WIDTH-1'd0;

//                 // read from fifo queue; if there's a value start sending
//                 if(~fifo_data_o_is_empty) begin
//                     fifo_data_read_en <= 1;
//                     fifo_cs_read_en <= 1;
//                     sending <= 1;
                    
//                     cnt <= DATA_WIDTH-1;
//                     o_received_data <= miso_data_in_reg;

//                     $display("fifo is not empty");
//                 end
//             end else begin
//                 fifo_data_read_en <= 0; // stop reading
//                 fifo_cs_read_en <= 0;

//                 // start serial clock
//                 i_divider <= 4'd1;
//                 i_start <= 1;

//                 // save info into the register
//                 shift_reg <= fifo_data_out;
//                 cs_reg <= fifo_cs_out;


//             end
//         end
//     end


//     assign o_spi_full = fifo_data_o_is_full;
// endmodule
