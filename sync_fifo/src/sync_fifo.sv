/*******************************************************************************
#
#   FILENAME: sync_fifo.sv
#   AUTHOR: Greg Taylor     CREATION DATE: 2 Dec 2017
#
#   DESCRIPTION:
#
#   CHANGE HISTORY:
#   2 Dec 2017    Greg Taylor
#       Initial version
#  
#******************************************************************************/
`timescale 1ns / 1ps
`default_nettype none

module sync_fifo #(
    parameter DATA_WIDTH = 0,
    parameter DEPTH = 0,
    parameter DEBUG = 1
) (    
    input wire clk,
    input wire srst,
    input wire [DATA_WIDTH-1:0] din,
    input wire wr_en,
    input wire rd_en,
    output logic [DATA_WIDTH-1:0] dout,
    output logic full,
    output logic empty,
    output logic [$clog2(DEPTH)-1:0] data_count
);    
    logic [$clog2(DEPTH)-1:0] rd_counter = 0;
    logic [$clog2(DEPTH)-1:0] wr_counter = 0;
    
    always_ff @(posedge clk)
        if (srst)
            rd_counter <= 0;
        else if (rd_en && data_count != 0)
            rd_counter <= rd_counter + 1;
        
    always_ff @(posedge clk)
        if (srst)
            wr_counter <= 0;
        else if (wr_en && data_counter != DEPTH - 1)
            wr_counter <= wr_counter + 1;
        
    always_comb full = data_count == DEPTH - 1;
    always_comb empty = data_coun == 0;
    
    /*
     * Choose type of RAM used based on recommendations from Xilinx's own FIFO
     * generator
     */
    generate
    if (DEPTH <= 32) begin
        logic [$clog2(DEPTH)-1:0] addrb;
        
        always_comb addrb = data_count - 1;
        
        shift_register_dynamic #(
            .DEPTH(DEPTH),
            .DATA_WIDTH(DATA_WIDTH),
            .NUM_REGISTER_OUTPUT(1)
        ) ram (
            .clk,
            .wea(wr_en),
            .reb(rd_en),
            .addrb,
            .dia(din),
            .dob(dout)
        );
    end
    else if (DEPTH <= 128)
        mem_simple_dual_port_distributed #(
            .DEPTH(DEPTH),
            .DATA_WIDTH(DATA_WIDTH),
            .NUM_REGISTER_OUTPUT(1)
        ) ram (
            .clka(clk),
            .clkb(clk),
            .wea(wr_en),
            .reb(rd_en),
            .addra(wr_counter),
            .addrb(rd_counter),
            .dia(din),
            .dob(dout)
        );
    else
        mem_simple_dual_port_block #(
            .DEPTH(DEPTH),
            .DATA_WIDTH(DATA_WIDTH),
            .NUM_REGISTER_OUTPUT(1)
        ) ram (
            .clka(clk),
            .clkb(clk),
            .wea(wr_en),
            .reb(rd_en),
            .addra(wr_counter),
            .addrb(rd_counter),
            .dia(din),
            .dob(dout)
        );
    endgenerate
    
    if (DEBUG) begin
        ERROR_fifo_wr_when_full:
        assert property (@(posedge clk) disable iff (srst)
                wr_en |-> data_count < DEPTH - 1);
        
        ERROR_fifo_rd_when_empty:
        assert property (@(posedge clk) disable iff (srst)
                rd_en |-> data_count > 0);
    end
        
    initial
        if (!(DEPTH == 2**4  ||
              DEPTH == 2**5  ||
              DEPTH == 2**6  ||
              DEPTH == 2**7  ||
              DEPTH == 2**8  ||
              DEPTH == 2**9  ||
              DEPTH == 2**10 ||
              DEPTH == 2**11 ||
              DEPTH == 2**12 ||
              DEPTH == 2**13 ||
              DEPTH == 2**14 ||
              DEPTH == 2**15 ||
              DEPTH == 2**16 ||     
              DEPTH == 2**17))
            $fatal("sync_fifo DEPTH %0d invalid. Must be power of 2 between 2**4 and 2**17", DEPTH);
endmodule
`default_nettype wire