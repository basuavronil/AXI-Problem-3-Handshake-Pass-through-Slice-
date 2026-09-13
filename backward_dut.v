module backward_register_slice (
    input  wire        clk,
    input  wire        rst_n,

    // Upstream Interface (Slave)
    input  wire [31:0] s_data,
    input  wire        s_valid,
    output wire        s_ready,

    // Downstream Interface (Master)
    output wire [31:0] m_data,
    output wire        m_valid,
    input  wire        m_ready
);

    // Internal Backward (Ready) Register
    reg ready_reg;

    // Internal Skid Registers (holds payload during downstream stall)
    reg [31:0] skid_data;
    reg        skid_valid;

    // Upstream ready is driven by the internal registered ready signal
    assign s_ready = ready_reg;

    // Multiplex outputs: Serve from skid buffer if valid data is stored, else pass through combinationally
    assign m_valid = skid_valid ? 1'b1 : s_valid;
    assign m_data  = skid_valid ? skid_data : s_data;

    // Sequential Block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_reg  <= 1'b1;
            skid_valid <= 1'b0;
            skid_data  <= 32'h0;
        end else begin
            // Register s_ready output: Ready if downstream accepts OR skid buffer is empty
            ready_reg <= m_ready | (~skid_valid & ~s_valid);

            // Capture incoming data into skid buffer when downstream stalls
            if (s_valid && s_ready && !m_ready) begin
                skid_data  <= s_data;
                skid_valid <= 1'b1;
            end else if (m_ready) begin
                skid_valid <= 1'b0;
            end
        end
    end

endmodule
