//==================================================
// 2-Flip-Flop Synchronizer
// Used to safely transfer signals across clock domains
//==================================================

module sync_2ff (
    input  wire clk,
    input  wire rst_n,
    input  wire async_in,
    output reg  sync_out
);

    reg sync_ff1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1 <= 1'b0;
            sync_out <= 1'b0;
        end else begin
            sync_ff1 <= async_in;
            sync_out <= sync_ff1;
        end
    end

endmodule
