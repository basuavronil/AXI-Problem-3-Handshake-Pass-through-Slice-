`timescale 1ns / 1ps

module backward_register_slice_tb;

    reg        clk;
    reg        rst_n;

    // Upstream Stimulus Signals
    reg [31:0] s_data;
    reg        s_valid;
    wire       s_ready;

    // Downstream Monitor Signals
    wire [31:0] m_data;
    wire        m_valid;
    reg         m_ready;

    // Instantiate Unit Under Test (UUT)
    backward_register_slice uut (
        .clk(clk),
        .rst_n(rst_n),
        .s_data(s_data),
        .s_valid(s_valid),
        .s_ready(s_ready),
        .m_data(m_data),
        .m_valid(m_valid),
        .m_ready(m_ready)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    integer errors = 0;

    initial begin
        // Initialize Signals
        clk     = 0;
        rst_n   = 0;
        s_data  = 32'h0;
        s_valid = 0;
        m_ready = 1;

        $display("=================================================");
        $display("   Testing Backward Register Slice (Skid Buffer) ");
        $display("=================================================");

        // Reset Pulse
        #15 rst_n = 1;
        @(posedge clk);

        // Test 1: Combinational Pass-Through (0-latency Forward Path)
        s_data  <= 32'hDEAD_BEEF;
        s_valid <= 1'b1;
        #1; // Wait 1ns for combinational output update
        
        if (m_valid !== 1'b1 || m_data !== 32'hDEAD_BEEF) begin
            $display("[ERROR] Test 1 Failed! Data did not pass combinationally.");
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 1: Zero-latency combinational forward pass-through verified.");
        end

        @(posedge clk);
        s_valid <= 1'b0;

        // Test 2: Sudden Downstream Stall & Skid Capture
        @(posedge clk);
        s_data  <= 32'hCAFE_BABE;
        s_valid <= 1'b1;
        m_ready <= 1'b0; // Downstream stalls on same edge
        
        @(posedge clk);
        s_valid <= 1'b0; // Producer drops valid, data must be in skid buffer
        
        if (m_valid !== 1'b1 || m_data !== 32'hCAFE_BABE) begin
            $display("[ERROR] Test 2 Failed! Data lost during skid buffer capture.");
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 2: Skid buffer successfully caught payload during stall.");
        end

        // Release Stall
        m_ready <= 1'b1;
        @(posedge clk);

        // Summary
        if (errors == 0)
            $display("SUCCESS: Backward Register Slice passed all tests!");
        else
            $display("FAILURE: Total Errors = %0d", errors);

        $finish;
    end

endmodule
