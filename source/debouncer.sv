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


    localparam CNT_MAX = 120000; for actual 12MHz clock in game
    //localparam CNT_MAX = 12; // for faster simulation
    
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