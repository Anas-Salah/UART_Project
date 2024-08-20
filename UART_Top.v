`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Nile University - Nano Electronics Integrated System Center (NIC)
// https://nisc.nu.edu.eg/
// Engineer: 
// 
// Create Date: 04/30/2021 11:47:35 AM
// Design Name: 
// Module Name: UART_Top
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


module UART_Top
    #(
        parameter DBIT = 8,     // # data bits
                  SB_TICK = 16  // # stop bit ticks                  
     )     
    (
        input clk, rst_n,
        
        // receiver port
        output [DBIT - 1: 0] r_data,
        input rd_uart,
        output rx_empty,
        input rx,
        
        // transmitter port
        input [DBIT - 1: 0] w_data,
        input wr_uart,
        output tx_full,
        output tx,
        
        // baud rate generator
        input [10: 0] timer_final_value
    );
    
    // Timer as baud rate generator
    wire tick;
    Timer_Input #(.BITS(11))baud_rate_generator (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .final_value(timer_final_value),
        .done(tick)
    );
    
    // Receiver
    wire rx_done_tick;
    wire [DBIT - 1: 0] rx_dout;
    UART_RX #(.DBIT(DBIT), .SB_TICK(SB_TICK)) UART_RX_U0(
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .s_tick(tick),
        .rx_done_tick(rx_done_tick),
        .rx_dout(rx_dout)
    );
    
    Fifo_Generator_0 Fifo_Generator_0_RX (
        .clk(clk),          // input wire clk
        .srst(~rst_n),    // input wire srst
        .din(rx_dout),      // input wire [7 : 0] din
        .wr_en(rx_done_tick),  // input wire wr_en
        .rd_en(rd_uart),    // input wire rd_en
        .dout(r_data),      // output wire [7 : 0] dout
        .full(),            // output wire full
        .empty(rx_empty)    // output wire empty
    );

    // Transmitter
    wire tx_fifo_empty, tx_done_tick;
    wire [DBIT - 1: 0] tx_din;
    UART_TX #(.DBIT(DBIT), .SB_TICK(SB_TICK)) UART_TX_U0(
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(~tx_fifo_empty),
        .s_tick(tick),
        .tx_din(tx_din),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );
    
    Fifo_Generator_0 Fifo_Generator_0_TX (
        .clk(clk),          // input wire clk
        .srst(~rst_n),    // input wire srst
        .din(w_data),      // input wire [7 : 0] din
        .wr_en(wr_uart),  // input wire wr_en
        .rd_en(tx_done_tick),    // input wire rd_en
        .dout(tx_din),      // output wire [7 : 0] dout
        .full(tx_full),            // output wire full
        .empty(tx_fifo_empty)    // output wire empty
    );    
endmodule
