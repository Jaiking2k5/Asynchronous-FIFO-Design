//==================================================
// Asynchronous FIFO (CDC Safe)
// Depth = 8, Data Width = 8
//==================================================

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3   // 2^3 = 8 depth
)(
    // Write domain
    input  wire                 wr_clk,
    input  wire                 wr_rst_n,
    input  wire                 wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                 full,

    // Read domain
    input  wire                 rd_clk,
    input  wire                 rd_rst_n,
    input  wire                 rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire                 empty
);

    // FIFO memory
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // Binary & Gray pointers
    wire [ADDR_WIDTH:0] wr_bin, wr_gray;
    wire [ADDR_WIDTH:0] rd_bin, rd_gray;

    // Synced pointers
    wire [ADDR_WIDTH:0] rd_gray_sync;
    wire [ADDR_WIDTH:0] wr_gray_sync;

    // Write pointer
    gray_counter #(ADDR_WIDTH+1) wr_ptr (
        .clk  (wr_clk),
        .rst_n(wr_rst_n),
        .en   (wr_en && !full),
        .bin  (wr_bin),
        .gray (wr_gray)
    );

    // Read pointer
    gray_counter #(ADDR_WIDTH+1) rd_ptr (
        .clk  (rd_clk),
        .rst_n(rd_rst_n),
        .en   (rd_en && !empty),
        .bin  (rd_bin),
        .gray (rd_gray)
    );

    // Synchronizers
    sync_2ff sync_rd_to_wr [ADDR_WIDTH:0] (
        .clk      (wr_clk),
        .rst_n    (wr_rst_n),
        .async_in (rd_gray),
        .sync_out (rd_gray_sync)
    );

    sync_2ff sync_wr_to_rd [ADDR_WIDTH:0] (
        .clk      (rd_clk),
        .rst_n    (rd_rst_n),
        .async_in (wr_gray),
        .sync_out (wr_gray_sync)
    );

    // Write operation
    always @(posedge wr_clk) begin
        if (wr_en && !full)
            mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data;
    end

    // Read operation
    always @(posedge rd_clk) begin
        if (rd_en && !empty)
            rd_data <= mem[rd_bin[ADDR_WIDTH-1:0]];
    end

    // Full condition
    assign full =
        (wr_gray == {~rd_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
                      rd_gray_sync[ADDR_WIDTH-2:0]});

    // Empty condition
    assign empty = (rd_gray == wr_gray_sync);

endmodule
