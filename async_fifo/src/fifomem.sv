/*******************************************************************************
#   +html+<pre>
#
#   FILENAME: fifomem.sv
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

module fifomem #(
    parameter DATAWIDTH = 8,
    parameter ADDRWIDTH = 4
) (    
    input wire wclk,
    input wire wclken,
    input wire wfull,
    input wire [ADDRWIDTH-1:0] waddr,
    input wire [ADDRWIDTH-1:0] raddr,
    input wire [DATAWIDTH-1:0] wdata,
    output logic [DATAWIDTH-1:0] rdata
);    
    localparam DEPTH = 1<<ADDRWIDTH;
    
    logic [DATAWIDTH-1:0] mem [0:DEPTH-1];
    
    always_comb rdata = mem[raddr];
    
    always_ff @(posedge wclk)
        if (wclken && !wfull) 
            mem[waddr] <= wdata;
endmodule
`default_nettype wire