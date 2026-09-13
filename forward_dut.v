module forward_register_slice (
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

    // Internal Registers
    reg [31:0] data_reg;
    reg        valid_reg;

    // Upstream ready: Ready if downstream accepts data OR current register is empty
    assign s_ready = m_ready | (~valid_reg);

    // Drive outputs directly from internal registers
    assign m_data  = data_reg;
    assign m_valid = valid_reg;

    // Register Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_reg <= 1'b0;
            data_reg  <= 32'h0;
        end else if (s_ready) begin
            valid_reg <= s_valid;
            if (s_valid) begin
                data_reg <= s_data;
            end
        end
    end

endmodule
