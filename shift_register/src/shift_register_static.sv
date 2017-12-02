/*******************************************************************************
#
#   FILENAME: shift_register_static.sv
#   AUTHOR: Greg Taylor     CREATION DATE: 2 Dec 2017
#
#   DESCRIPTION:
#   Will infer SLR16s or SLR32s
#
#   CHANGE HISTORY:
#   2 Dec 2017    Greg Taylor
#       Initial version
#  
#******************************************************************************/
`timescale 1ns / 1ps
`default_nettype none

module shift_register_static #(
    parameter DATA_WIDTH = 0,
    parameter DEPTH = 0
) (    
    input wire clk,
    input wire wea,
    input wire [DATA_WIDTH-1:0] dia,    
    output logic [DATA_WIDTH-1:0] dob
);    
    logic [DATA_WIDTH-1:0] sr [DEPTH] = '{default: 0};
    
    genvar i;
    generate
    for (i = 0; i < DEPTH; i++)    
    always_ff @(posedge clk)
        if (wea)
            if (i == 0)
                sr[i] <= dia;
            else
                sr[i] <= sr[i-1];
    endgenerate        
        
    always_comb dob = sr[DEPTH-1]; 
endmodule
`default_nettype wire