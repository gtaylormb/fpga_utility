/*******************************************************************************
#
#   FILENAME: shift_register_dynamic.sv
#   AUTHOR: Greg Taylor     CREATION DATE: 2 Dec 2017
#
#   DESCRIPTION:
#   Will infer SLR16s or SLR32s. Write port always pushes onto the front of the
#   SR, but read port is run-time dynamic.
#
#   CHANGE HISTORY:
#   2 Dec 2017    Greg Taylor
#       Initial version
#  
#******************************************************************************/
`timescale 1ns / 1ps
`default_nettype none

module shift_register_dynamic #(
    parameter DATA_WIDTH = 0,
    parameter DEPTH = 0,
    parameter NUM_REGISTER_OUTPUT = 0 // 0 or 1
) (    
    input wire clk,
    input wire wea,
    input wire reb, // only used if NUM_REGISTER_OUTPUT = 1
    input wire [$clog2(DEPTH)-1:0] addrb,
    input wire [DATA_WIDTH-1:0] dia,    
    output logic [DATA_WIDTH-1:0] dob
);    
    logic [DATA_WIDTH-1:0] dob_p0;
    logic [DATA_WIDTH-1:0] dob_p1 = 0;  
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
        
    always_comb dob_p0 = sr[addrb];
    
    always_ff @(posedge clkb)
        if (reb)
            dob_p1 <= dob_p0;
        
    generate
    if (NUM_REGISTER_OUTPUT == 0)
        always_comb dob = dob_p0;
    else if (NUM_REGISTER_OUTPUT == 1)
        always_comb dob = dob_p1;              
    else
        $fatal("NUM_REGISTER_OUTPUT must be 0 or 1");
    endgenerate        
endmodule
`default_nettype wire