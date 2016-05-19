/*******************************************************************************
#   +html+<pre>
#
#   FILENAME: rptr_empty.sv
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

module rptr_empty #(
    parameter ADDRWIDTH = 4
) (    
    input wire rclk,
    input wire rinc,
    input wire [ADDRWIDTH:0] rq2_wptr,
    output logic rempty,
    output logic [ADDRWIDTH-1:0] raddr,
    output logic [ADDRWIDTH:0] rptr
);    
    logic [ADDRWIDTH:0] rbin;
    logic [ADDRWIDTH:0] rgraynext, rbinnext;
    
    //-------------------
    // GRAYSTYLE2 pointer
    //-------------------
    always_ff @(posedge rclk)
        {rbin, rptr} <= {rbinnext, rgraynext};
        
    // Memory read-address pointer (okay to use binary to address memory)
    always_comb raddr = rbin[ADDRWIDTH-1:0];
    always_comb rbinnext = rbin + (rinc & ~rempty);
    always_comb rgraynext = (rbinnext>>1) ^ rbinnext;
    
    //---------------------------------------------------------------
    // FIFO empty when the next rptr == synchronized wptr or on reset
    //---------------------------------------------------------------
    always_comb rempty_val = (rgraynext == rq2_wptr);
    
    always_ff @(posedge rclk)
        rempty <= rempty_val;
endmodule
`default_nettype wire