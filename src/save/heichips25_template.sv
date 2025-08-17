// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

// Adapted from the Tiny Tapeout template

`default_nettype none
`include "./heichips25_systolicArray.sv"
module heichips25_template (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in[7:1], uio_in[7:0]};

    logic [7:0] count;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            if (ui_in[0]) begin
                count <= count + 1;
            end
        end
    end
    
    assign uo_out  = count;
    assign uio_out = count;
    assign uio_oe  = '1;
heichips25_systolicArray my_module(
	.clk(clk),
	.reset(!rst_n),
	.data_in(uio_in[3:0]),
	.load_weights(uio_in[4]),
	.load_inputs(uio_in[5]),
	.results[0](uio_out[7:0),
	.valid_out(uio_oe[0])
);
	
endmodule
