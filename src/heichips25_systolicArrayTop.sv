// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

// Adapted from the Tiny Tapeout template
`include "./heichips25_systolicArray.sv"
`default_nettype none

module heichips25_systolicArrayTop (
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
    wire _unused = &{ena, ui_in[7], uio_in[7:0]};
 
heichips25_systolicArray #(
    .BITWIDTH(4),
    .OUTWIDTH(8)
)mydesign(
    .clk(clk),
    .reset(!rst_n),
    .data_in(ui_in[3:0]),
    .load_weights(ui_in[4]),
    .load_inputs(ui_in[5]),
    .store_outputs(ui_in[6]),
    .results(uo_out),
    .valid_out(uio_out[0])
);
    assign uio_out[7:1] = '0;
    assign uio_oe       = '1;

endmodule
