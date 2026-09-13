`timescale 1ns / 1ps

module forward_register_slice_tb;

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
    forward_register_slice uut (
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
        $display("   Testing Forward Register Slice                ");
        $display("=================================================");

        // Reset Pulse
        #15 rst_n = 1;
        @(posedge clk);

        // Test 1: Single Word Transfer (1 Clock Latency across Forward Path)
        s_data  <= 32'hAAAA_BBBB;
        s_valid <= 1'b1;
        @(posedge clk);
        s_valid <= 1'b0;
        
        // Verification after pipeline delay
        if (m_valid !== 1'b1 || m_data !== 32'hAAAA_BBBB) begin
            $display("[ERROR] Test 1 Failed! Got m_valid=%b, m_data=%h", m_valid, m_data);
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 1: Forward pipeline registered data correctly.");
        end

        @(posedge clk);
        // Clear down

        // Test 2: Backpressure Stall
        m_ready <= 1'b0; // Downstream busy
        s_data  <= 32'h1234_5678;
        s_valid <= 1'b1;
        @(posedge clk);

        // Slice should hold data while m_ready is 0
        if (s_ready !== 1'b0) begin
            $display("[ERROR] Test 2 Failed! s_ready should drop when pipeline is full & downstream stalls.");
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 2: s_ready correctly pulled low during downstream stall.");
        end

        // Release Stall
        m_ready <= 1'b1;
        s_valid <= 1'b0;
        @(posedge clk);

        // Summary
        if (errors == 0)
            $display("SUCCESS: Forward Register Slice passed all tests!");
        else
            $display("FAILURE: Total Errors = %0d", errors);

        $finish;
    end

endmodule
