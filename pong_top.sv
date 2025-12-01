`default_nettype none

module pong_top (
    input  logic clk,       // System Clock
    input  logic reset,     // Hardware Reset Button
    input  logic btn_up,    // Up Button
    input  logic btn_down,  // Down Button
    output logic hsync,     // VGA Horizontal Sync
    output logic vsync,     // VGA Vertical Sync
    output logic [3:0] vga_r, // Red Channel
    output logic [3:0] vga_g, // Green Channel
    output logic [3:0] vga_b  // Blue Channel
);

    // --- Internal Signals ---
    logic pixel_clk;
    logic video_on;
    logic [9:0] pixel_x, pixel_y;
    logic [9:0] paddle_y;
    logic [9:0] ball_x, ball_y;
    logic game_over;

    // --- Debounced Signals ---
    logic reset_db;
    logic btn_up_db;
    logic btn_down_db;

    // 1. Clock Divider
    // Assuming input clk is 12MHz, we divide by 2 to get 6MHz pixel clock
    always_ff @(posedge clk) begin
        if (reset_db) 
            pixel_clk <= 0;
        else 
            pixel_clk <= ~pixel_clk;
    end

    // 2. Debouncers (up and down because paddle moves vertically)
    debouncer db_reset (
        .clk(pixel_clk), 
        .in(reset), 
        .out(reset_db)
    );

    debouncer db_up (
        .clk(pixel_clk), 
        .in(btn_up), 
        .out(btn_up_db)
    );

    debouncer db_down (
        .clk(pixel_clk), 
        .in(btn_down), 
        .out(btn_down_db)
    );

    // 3. VGA Timing
    vga_controller vga_inst (
        .clk(pixel_clk),
        .reset(reset_db),
        .video_on(video_on),
        .hsync(hsync),
        .vsync(vsync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // 4. Game Logic
    game_core logic_inst (
        .clk(pixel_clk),
        .reset(reset_db),
        .frame_tick(vsync),
        .btn_up(btn_up_db),
        .btn_down(btn_down_db),
        .video_on(video_on), 
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .game_over(game_over)
    );

    // 5. Pixel Renderer
    pixel_renderer paint_inst (
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        // .game_over(game_over), // Not needed for white/freeze logic
        .red(vga_r),
        .green(vga_g),
        .blue(vga_b)
    );

endmodule