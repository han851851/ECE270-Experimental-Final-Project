//basically 'draws' the screen by generating sync signals and pixel coordinates

module vga_controller (
    input logic clk, reset,
    output logic video_on, hsync, vsync,
    output logic [9:0] pixel_x, pixel_y
);
    localparam HD=640, HF=16, HB=48, HR=96, HT=800;
    localparam VD=480, VF=10, VB=33, VR=2,  VT=525;
    logic [9:0] h_count, v_count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) h_count <= 0;
        else if (h_count == HT-1) h_count <= 0;
        else h_count <= h_count + 1;
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) v_count <= 0;
        else if (h_count == HT-1) begin
            if (v_count == VT-1) v_count <= 0;
            else v_count <= v_count + 1;
        end
    end

    assign hsync = ~((h_count >= (HD+HF)) && (h_count < (HD+HF+HR)));
    assign vsync = ~((v_count >= (VD+VF)) && (v_count < (VD+VF+VR)));
    assign video_on = (h_count < HD) && (v_count < VD);
    assign pixel_x = h_count;
    assign pixel_y = v_count;
endmodule