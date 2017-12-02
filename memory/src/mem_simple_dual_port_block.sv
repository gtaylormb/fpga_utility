/*******************************************************************************
#
#   FILENAME: mem_simple_dual_port_block.sv
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

module mem_simple_dual_port_block #(
    parameter DATA_WIDTH = 0,
    parameter DEPTH = 0,
    parameter OUTPUT_DELAY = 1 // 1, 2, or 3
) (    
    input wire clka,
    input wire clkb,
    input wire wea,
    input wire reb,
    input wire [$clog2(DEPTH)-1:0] addra,
    input wire [$clog2(DEPTH)-1:0] addrb,
    input wire [DATA_WIDTH-1:0] dia,    
    output logic [DATA_WIDTH-1:0] dob
);    
    logic [DATA_WIDTH-1:0] dob_p0;
    logic [DATA_WIDTH-1:0] dob_p1 = 0;
    logic [DATA_WIDTH-1:0] dob_p2 = 0;
    logic [DATA_WIDTH-1:0] dob_p3 = 0;    
    
    (* ram_style = "block" *)
    logic [DATA_WIDTH-1:0] ram [DEPTH-1:0] = '{default: 0};
    
    always_ff @(posedge clka)
        if (wea)
            ram[addra] <= dia;
        
    always_comb dob_p0 = ram[addrb];
    
    always_ff @(posedge clkb)
        if (reb)
            dob_p1 <= dob_p0;
        
    always_ff @(posedge clkb) begin
        dob_p2 <= dob_p1;
        dob_p3 <= dob_p2;
    end
        
    generate
    if (OUTPUT_DELAY == 1)
        always_comb dob = dob_p1;
    else if (OUTPUT_DELAY == 2)
        always_comb dob = dob_p2;
    else if (OUTPUT_DELAY == 3)
        always_comb dob = dob_p3;                
    else
        $fatal("OUTPUT_DELAY must be 1, 2, or 3");
    endgenerate        
endmodule
`default_nettype wire