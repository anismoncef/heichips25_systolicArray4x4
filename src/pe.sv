module pe #(
    parameter BITWIDTH = 4,
    parameter OUTWIDTH = 2*BITWIDTH
    ) (
    input                           clk,
    input                           compute_en,
    input                           reset,
    input                           load_weights,
    input        [BITWIDTH -1:0]    in_data,    // Input data from top
    input        [BITWIDTH -1:0]    in_weight,  // Input weight from left
    output logic [BITWIDTH -1:0]    out_data,   // Output data to bottom
    output logic [BITWIDTH -1:0]    out_weight, // Output weight to right
    output logic [OUTWIDTH -1:0]    out_result  // Output accumulated result
);
always @(posedge clk) begin
    if (reset) begin
        out_data    <= 0;
        out_weight  <= 0;
        out_result  <= 0;
    end 
    else 
    begin
        if (load_weights) 
        begin
            out_result  <= 0;
        end else if (compute_en) begin

            out_data    <= in_data;
            out_weight  <= in_weight;
            out_result  <= out_result + (in_data * in_weight);

        end
    end
end
endmodule
