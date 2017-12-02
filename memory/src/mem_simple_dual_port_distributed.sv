/*******************************************************************************
#
#   FILENAME: mem_simple_dual_port_distributed.sv
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

module mem_simple_dual_port_distributed #(
    parameter DATA_WIDTH = 0,
    parameter DEPTH = 0,
    parameter OUTPUT_DELAY = 0 // 0, 1, or 2
) (    
    input wire clka,
    input wire clkb,
    input wire wea,
    input wire reb, // only used if OUTPUT_DELAY >0
    input wire [$clog2(DEPTH)-1:0] addra,
    input wire [$clog2(DEPTH)-1:0] addrb,
    input wire [DATA_WIDTH-1:0] dia,    
    output logic [DATA_WIDTH-1:0] dob
);    
    logic [DATA_WIDTH-1:0] dob_p0;
    logic [DATA_WIDTH-1:0] dob_p1 = 0;
    logic [DATA_WIDTH-1:0] dob_p2 = 0;
    
    (* ram_style = "distributed" *)
    logic [DATA_WIDTH-1:0] ram [DEPTH-1:0] = '{default: 0};
    
    always_ff @(posedge clka)
        if (wea)
            ram[addra] <= dia;
        
    always_comb dob_p0 = ram[addrb];
    
    always_ff @(posedge clkb)
        if (reb)
            dob_p1 <= dob_p0;
        
    always_ff @(posedge clkb)
        dob_p2 <= dob_p1;
        
    generate
    if (OUTPUT_DELAY == 0)
        always_comb dob = dob_p0;
    else if (OUTPUT_DELAY == 1)
        always_comb dob = dob_p1;
    else if (OUTPUT_DELAY == 2)
        always_comb dob = dob_p2;
    else
        $fatal("OUTPUT_DELAY must be 0, 1, or 2");
    endgenerate        
endmodule
`default_nettype wire