/*******************************************************************************
#   +html+<pre>
#
#   FILENAME: async_fifo.sv
#   AUTHOR: Greg Taylor     CREATION DATE: 18 May 2016
#
#   DESCRIPTION:
#
#   CHANGE HISTORY:
#   18 May 2016    Greg Taylor
#       Initial version
#
#   
#******************************************************************************/
`timescale 1ns / 1ps
`default_nettype none

module async_fifo #(
    parameter DATAWIDTH = 8,
    parameter ADDRWIDTH = 4
) (    
    input wire rclk,
    input wire wclk,
    input wire rinc,
    input wire winc,
    output logic [DATAWIDTH-1:0] rdata,
    input wire [DATA_WIDTH-1:0] wdata,
    output logic wfull,
    output logic rempty
);    
    logic [ADDRWIDTH-1:0] waddr, raddr;
    logic [ADDRWIDTH:0] wptr, rptr, wq2_rptr, rq2_wptr;
       
    generate
    for (genvar i; i < ADDRWIDTH+1; i++) begin
        synchronizer #(
            .WIDTH(ADDRWIDTH+1)
        ) sync_r2w (
            .clk(wclk),
            .in(rptr[i]),        
            .out(wq2_rptr[i])
        );
    
        synchronizer #(
            .WIDTH(ADDRWIDTH+1)
        ) sync_w2r (
            .clk(rclk),
            .in(wptr[i]),        
            .out(rq2_wptr[i])
        );
    end
    endgenerate        
    
    fifomem #(
        .DATAWIDTH, 
        .ADDRWIDTH
    ) fifomem (
        .wclken(winc),
        .*
    );
    
    rptr_empty #(
        .ADDRWIDTH
    ) rptr_empty (.*);
    
    wptr_full #(
        .ADDRWIDTH
    ) wptr_full (.*);
endmodule
`default_nettype wire