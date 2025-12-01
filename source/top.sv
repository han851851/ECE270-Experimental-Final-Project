module top (
    input  logic clk,       // System Clock (External pin, now unused)
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

    // -----------------------------------------------------------
    // 1. Clock Generation (Replaces the old Clock Divider)
    // -----------------------------------------------------------
    // Old divide-by-2 logic is REMOVED. 
    // New PLL instance drives pixel_clk directly at ~25.125 MHz.
    
    pll_clkGen pll_inst (
        .VGA_CLK(pixel_clk)
    );

    // -----------------------------------------------------------
    // 2. Debouncers 
    // -----------------------------------------------------------
    // Note: We are still using pixel_clk to drive the debouncers.
    // Since pixel_clk is now ~25 MHz (up from 6 MHz), we must 
    // update the CNT_MAX inside debouncer.sv (see step 2 below).
    
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

    // --- The rest of the module (VGA Timing, Game Logic, Renderer) remains the same ---
    // ...