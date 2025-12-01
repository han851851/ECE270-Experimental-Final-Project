module pong (
    input  logic clk, //onboard clk
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
    logic pixel_clk;  // This will now be driven by the PLL
    logic video_on;
    logic [9:0] pixel_x, pixel_y;
    logic [9:0] paddle_y;
    logic [9:0] ball_x, ball_y;
    logic game_over;

    // --- Debounced Signals ---
    logic reset_db;
    logic btn_up_db;
    logic btn_down_db;

    // clkGen
    
    pll_clkGen pll_inst (
        .VGA_CLK(pixel_clk)
    );

    // Debouncers
    
    debouncer db_reset (
        .clk(clk), 
        .in(reset), 
        .out(reset_db)
    );

    debouncer db_up (
        .clk(clk), 
        .in(btn_up), 
        .out(btn_up_db)
    );

    debouncer db_down (
        .clk(clk), 
        .in(btn_down), 
        .out(btn_down_db)
    );

    // 3. VGA Timing Controller
    vga_controller vga_inst (
        .clk(pixel_clk),
        .reset(reset_db),
        .video_on(video_on),
        .hsync(hsync),
        .vsync(vsync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // 4. Game Logic / Physics Engine
    game_core logic_inst (
        .clk(clk),
        .reset(reset_db),
        .frame_tick(vsync), // Update physics once per frame (60Hz)
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
        //.game_over(game_over), unused
        .red(vga_r),
        .green(vga_g),
        .blue(vga_b)
    );

endmodule