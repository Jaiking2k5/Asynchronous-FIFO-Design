//==================================================
// Testbench for Asynchronous FIFO
//==================================================

`timescale 1ns/1ps

module async_fifo_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 3;

    // Write domain signals
    reg wr_clk;
    reg wr_rst_n;
    reg wr_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire full;

    // Read domain signals
    reg rd_clk;
    reg rd_rst_n;
    reg rd_en;
    wire [DATA_WIDTH-1:0] rd_data;
    wire empty;

    // Instantiate DUT
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .wr_clk (wr_clk),
        .wr_rst_n (wr_rst_n),
        .wr_en (wr_en),
        .wr_data (wr_data),
        .full (full),

        .rd_clk (rd_clk),
        .rd_rst_n (rd_rst_n),
        .rd_en (rd_en),
        .rd_data (rd_data),
        .empty (empty)
    );

    // Write clock: 10ns period
    always #5 wr_clk = ~wr_clk;

    // Read clock: 14ns period (different frequency)
    always #7 rd_clk = ~rd_clk;

    // Test sequence
    initial begin
        // Initialize signals
        wr_clk = 0;
        rd_clk = 0;
        wr_rst_n = 0;
        rd_rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        // Apply reset
        #20;
        wr_rst_n = 1;
        rd_rst_n = 1;

        // Start writing data
        #10;
        wr_en = 1;
        wr_data = 8'hA1; #10;
        wr_data = 8'hB2; #10;
        wr_data = 8'hC3; #10;
        wr_data = 8'hD4; #10;
        wr_en = 0;

        // Wait before reading
        #30;

        // Start reading data
        rd_en = 1;
        #20;
        rd_en = 0;

        // End simulation
        #50;
        $finish;
    end

    // Monitor output
    always @(posedge rd_clk) begin
        if (rd_en && !empty) begin
            $display("Time=%0t | Read Data = %h", $time, rd_data);
        end
    end

endmodule
