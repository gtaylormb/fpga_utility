/*******************************************************************************
#   +html+<pre>
#
#   FILENAME: wptr_full.sv
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

module wptr_full #(
    parameter ADDRWIDTH = 4
) (    
    input wire wclk,
    input wire winc,
    input wire [ADDRWIDTH:0] wq2_rptr,
    output logic wfull,
    output logic [ADDRWIDTH-1:0] waddr,
    output logic [ADDRWIDTH:0] wptr
);    
    logic [ADDRSIZE:0] wbin;
    logic [ADDRSIZE:0] wgraynext, wbinnext;
    
    // GRAYSTYLE2 pointer
    always_ff @(posedge wclk)
        {wbin, wptr} <= {wbinnext, wgraynext};
        
    // Memory write-address pointer (okay to use binary to address memory)
    always_comb waddr = wbin[ADDRSIZE-1:0];
    always_comb wbinnext = wbin + (winc & ~wfull);
    always_comb wgraynext = (wbinnext>>1) ^ wbinnext;
    
    //------------------------------------------------------------------
    // Simplified version of the three necessary full-tests:
    // assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
    // (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
    // (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
    //------------------------------------------------------------------
    always_comb wfull_val = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1],
                wq2_rptr[ADDRSIZE-2:0]});
    
    always_ff @(posedge wclk)
        wfull <= wfull_val;
endmodule
`default_nettype wire