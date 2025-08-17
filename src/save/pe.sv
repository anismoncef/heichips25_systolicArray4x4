module pe(
    input               clk,
    input               compute_en,
    input               reset,
    input [3:0]         in_data,    // Input data from top
    input [3:0]         in_weight,  // Input weight from left
    output logic [3:0]  out_data,   // Output data to bottom
    output logic [3:0]  out_weight, // Output weight to right
    output logic [7:0]  out_result  // Output accumulated result
);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        out_data    <= 0;
        out_weight  <= 0;
        out_result  <= 0;
    end 
    else if (compute_en) begin
        // Pass data and weighs through
        out_data   <= in_data;
        out_weight <= in_weight;
        // Multiply-accumulate operation
        out_result <= out_result + (in_data * in_weight);
    end
    else if (!compute_en) begin
            out_result  <= 0;
    end else
    begin
        out_result  <= 0;
    end
end

endmodule
