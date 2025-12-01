module pixel_renderer (
    input  logic video_on,
    input  logic [9:0] pixel_x,
    input  logic [9:0] pixel_y,
    input  logic [9:0] paddle_y,
    input  logic [9:0] ball_x,
    input  logic [9:0] ball_y,
    // input logic game_over, // Unused for rendering now (visuals don't change, just movement stops)
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);

    // Colors
    localparam COLOR_WHITE = 12'hFFF;
    localparam COLOR_BLACK = 12'h000;
    localparam COLOR_BG    = 12'h113; // Dark Blue

    // Dimensions
    localparam PADDLE_H = 60;
    localparam PADDLE_W = 10;
    localparam PADDLE_X = 20;
    localparam BALL_SIZE = 10;

    logic paddle_on, ball_on;
    logic [11:0] rgb_out;

    // Object Hit Detectors
    always_comb begin
        paddle_on = (pixel_x >= PADDLE_X) && (pixel_x < PADDLE_X + PADDLE_W) &&
                    (pixel_y >= paddle_y) && (pixel_y < paddle_y + PADDLE_H);
                    
        ball_on   = (pixel_x >= ball_x) && (pixel_x < ball_x + BALL_SIZE) &&
                    (pixel_y >= ball_y) && (pixel_y < ball_y + BALL_SIZE);
    end

    // Color Priority Multiplexer
    always_comb begin
        if (!video_on) begin
            rgb_out = COLOR_BLACK;
        end else if (ball_on) begin
            rgb_out = COLOR_WHITE;
        end else if (paddle_on) begin
            rgb_out = COLOR_WHITE; // Now White
        end else begin
            rgb_out = COLOR_BG;
        end
    end

    assign red   = rgb_out[11:8];
    assign green = rgb_out[7:4];
    assign blue  = rgb_out[3:0];
endmodule