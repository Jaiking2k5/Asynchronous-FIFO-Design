//==================================================
// Binary to Gray Counter
// Gray code reduces CDC glitches during pointer sync
//==================================================

module gray_counter #(
    parameter WIDTH = 4
)(
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    output reg  [WIDTH-1:0] bin,
    output reg  [WIDTH-1:0] gray
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bin <= 0;
        else if (en)
            bin <= bin + 1'b1;
    end

    always @(*) begin
        gray = (bin >> 1) ^ bin;
    end

endmodule
