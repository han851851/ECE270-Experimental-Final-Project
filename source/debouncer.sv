`default_nettype none

module debouncer (
    input  logic clk,
    input  logic in,
    output logic out
);
    logic sync_0, sync_1;
    always_ff @(posedge clk) begin
        sync_0 <= in;
        sync_1 <= sync_0;
    end

    //parameter to meet 25mhz clock
    localparam CNT_MAX = 250000;
    
    logic [17:0] count;
    logic state;

    always_ff @(posedge clk) begin
        if (sync_1 !== state) begin
            count <= count + 1;
            if (count >= CNT_MAX) begin
                state <= sync_1;
                count <= 0;
            end
        end else begin
            count <= 0;
        end
    end

    assign out = state;

endmodule