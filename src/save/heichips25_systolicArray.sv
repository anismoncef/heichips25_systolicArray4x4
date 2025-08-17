// 4x4 Systolic Array Module
// Implements an output-stationary systolic array for matrix multiplication
`include "./pe.sv"
module heichips25_systolicArray (
    input               clk,            // System clock
    input               reset,          // Active-high reset
    input [3:0]         data_in,        // 4-bit input data (weights or inputs)
    input               load_weights,   // High during weight loading phase
    input               load_inputs,    // High during input loading phase
    output logic [3:0][7:0]  results,   // 4x 8-bit output results
    output logic        valid_out       // High when results are valid
);

    // Memory elements
    reg [3:0] weights [0:3][0:6];    // 4x4 array of 4-bit weights
    reg [3:0] inputs [0:3][0:6];     // 4-element input vector (4-bit each)
    reg [3:0] pe_inputs [0:3][0:3];  // Data moving between PEs
    reg [3:0] pe_weights [0:3][0:3]; // Weights moving between PEs
    reg [7:0] accum [0:3][0:3];      // 4x4 array of 8-bit accumulators (stationary)
    
    // Control signals
    reg [3:0] load_counter;          // Counter for loading weights/inputs
    reg compute_en;                  // High during computation phase
    reg [2:0] cp;         // Tracks computation phase
    reg [2:0] cp2;         // Tracks computation phase

    // Main operation - synchronous logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers
            for (int i=0; i<4; i++) begin
                for (int j=0; j<7; j++) begin
                    weights[i][j] <= 0;
                    inputs[i][j] <= 0;
                end                
            end
            load_counter <= 0;
            compute_en <= 0;
            cp <= 0;
            cp2 <= 0;
            valid_out <= 0;
        end
        else begin
            valid_out <= 0;  // Default to results not valid
            
            // Weight loading phase
            if (load_weights) begin
                case (load_counter)
                    0: weights[0][0] <= data_in;
                    1: weights[1][1] <= data_in;
                    2: weights[2][2] <= data_in;
                    3: weights[3][3] <= data_in;
                    4: weights[0][1] <= data_in;
                    5: weights[1][2] <= data_in;
                    6: weights[2][3] <= data_in;
                    7: weights[3][4] <= data_in;
                    8: weights[0][2] <= data_in;
                    9: weights[1][3] <= data_in;
                    10:weights[2][4] <= data_in;
                    11:weights[3][5] <= data_in;
                    12:weights[0][3] <= data_in;
                    13:weights[1][4] <= data_in;
                    14:weights[2][5] <= data_in;
                    15:weights[3][6] <= data_in;
                    default: weights[0][0] <= data_in;
                endcase
                load_counter <= load_counter + 1;
            end
            // Input loading phase
            else if (load_inputs) begin
                case (load_counter)
                    0: inputs[0][0] <= data_in;
                    1: inputs[0][1] <= data_in;
                    2: inputs[0][2] <= data_in;
                    3: inputs[0][3] <= data_in;
                    4: inputs[1][1] <= data_in;
                    5: inputs[1][2] <= data_in;
                    6: inputs[1][3] <= data_in;
                    7: inputs[1][4] <= data_in;
                    8: inputs[2][2] <= data_in;
                    9: inputs[2][3] <= data_in;
                    10:inputs[2][4] <= data_in;
                    11:inputs[2][5] <= data_in;
                    12:inputs[3][3] <= data_in;
                    13:inputs[3][4] <= data_in;
                    14:inputs[3][5] <= data_in;
                    15:inputs[3][6] <= data_in;
                    default: inputs[0][0] <= data_in;
                endcase
                load_counter <= load_counter + 1;
                
                if (load_counter == 15) begin
                    compute_en <= 1;
                    load_counter <= 0;
                end
            end
            // Computation phase
            else if (compute_en) begin
                // After 7 cycles (for 4x4 array), results are ready
                if (cp == 6) begin
                    if (cp2 == 3) begin 
                        compute_en <= 0;
                        valid_out <= 1;
                        cp <= 0;
                        for (int i=0; i<4; i++) begin
                            results[i] <= accum[3][i]; // Rightmost column has final results
                        end

                    end else begin
                        cp2 <= cp2 + 1 ;
                        compute_en <= 1;
                        valid_out <= 0;
                        cp <= cp ;
                    end
                end
                else begin
                    cp <= cp + 1;
                end
            end else
            begin
                load_counter <= 0;
            end    
        end
    end
    genvar i, j;
    generate
        for (i=0; i<4; i++) begin : row
            for (j=0; j<4; j++) begin : col
                pe processing_element (
                    .clk(clk),
                    .compute_en(compute_en),
                    .reset(reset),
//                    .in_data(((j == 0)) ? (((cp < 4+i)&&(cp >= i)) ? (inputs[i][cp-i]) : 4'b0) : pe_inputs[i][j-1]),
                    .in_data(((j == 0)) ? inputs[i][cp] : pe_inputs[i][j-1]),
                    .in_weight((i == 0) ? weights[j][cp] : pe_weights[i-1][j]),
                    .out_data(pe_inputs[i][j]),
                    .out_weight(pe_weights[i][j]),
                    .out_result(accum[i][j]) // Accumulator stays in place
                );
            end
        end
    endgenerate 
endmodule
