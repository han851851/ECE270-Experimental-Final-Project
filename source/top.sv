//top wrapper, connects pong module's signals to actual pins on the pico

module top (
    // Inputs (Mapped to Board Buttons/PMODs)
    input  logic ICE_PB,          // Built-in Button (Active Low)
    input  logic ICE_PMOD2A_IO1,  // External Button Up (Mapped to Pin 27)
    input  logic ICE_PMOD2A_IO2,  // External Button Down (Mapped to Pin 25)

    // Outputs (Mapped to PMODs for VGA)
    
    // Red Channel -> PMOD0A [IO1..IO4]
    output logic ICE_PMOD0A_IO1, // R[0]
    output logic ICE_PMOD0A_IO2, // R[1]
    output logic ICE_PMOD0A_IO3, // R[2]
    output logic ICE_PMOD0A_IO4, // R[3]

    // Green Channel -> PMOD0B [IO1..IO4]
    output logic ICE_PMOD0B_IO1, // G[0]
    output logic ICE_PMOD0B_IO2, // G[1]
    output logic ICE_PMOD0B_IO3, // G[2]
    output logic ICE_PMOD0B_IO4, // G[3]

    // Blue Channel -> PMOD1A [IO1..IO4]
    output logic ICE_PMOD1A_IO1, // B[0]
    output logic ICE_PMOD1A_IO2, // B[1]
    output logic ICE_PMOD1A_IO3, // B[2]
    output logic ICE_PMOD1A_IO4, // B[3]

    // Sync Signals -> PMOD1B
    output logic ICE_PMOD1B_IO1, // HSYNC
    output logic ICE_PMOD1B_IO2  // VSYNC
);

    // Internal Wires to connect Wrapper to Top
    logic [3:0] w_red, w_green, w_blue;
    logic w_hsync, w_vsync;
    
    // Invert the built-in button because ICE_PB is Active Low, 
    // but top.sv expects Active High reset.
    logic w_reset;
    assign w_reset = ~ICE_PB; 

    // Instantiate your original Top Module
    top game_top (
        .reset(w_reset),
        .btn_up(ICE_PMOD2A_IO1),
        .btn_down(ICE_PMOD2A_IO2),
        .hsync(w_hsync),
        .vsync(w_vsync),
        .vga_r(w_red),
        .vga_g(w_green),
        .vga_b(w_blue)
    );

    // --- Wiring Assignments ---
    
    // Map Internal Signals to the "Catalogue" Pin Names
    
    // Red
    assign ICE_PMOD0A_IO1 = w_red[0];
    assign ICE_PMOD0A_IO2 = w_red[1];
    assign ICE_PMOD0A_IO3 = w_red[2];
    assign ICE_PMOD0A_IO4 = w_red[3];

    // Green
    assign ICE_PMOD0B_IO1 = w_green[0];
    assign ICE_PMOD0B_IO2 = w_green[1];
    assign ICE_PMOD0B_IO3 = w_green[2];
    assign ICE_PMOD0B_IO4 = w_green[3];

    // Blue
    assign ICE_PMOD1A_IO1 = w_blue[0];
    assign ICE_PMOD1A_IO2 = w_blue[1];
    assign ICE_PMOD1A_IO3 = w_blue[2];
    assign ICE_PMOD1A_IO4 = w_blue[3];

    // Syncs
    assign ICE_PMOD1B_IO1 = w_hsync;
    assign ICE_PMOD1B_IO2 = w_vsync;

endmodule