`timescale 1ns/1ps

module tb_debouncer;
    logic clk, in, out;

    // Instantiate the module (Uses localparam CNT_MAX = 12 from your file)
    debouncer uut (
        .clk(clk),
        .in(in),
        .out(out)
    );

    // Clock Generation: 10ns period (100MHz)
    // 12 cycles = 120ns threshold
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize
        clk = 0; in = 0;
        $display("Starting Test with CNT_MAX = 12 (120ns threshold)...");
        #100; // Wait a bit

        // 2. TEST GLITCH (Hold High for 50ns / 5 cycles)
        // Expected: 'out' stays 0 because 5 < 12
        in = 1;
        #50; 
        in = 0;
        #100; // Wait to see if output changes (it shouldn't)
        
        if (out == 0) $display("PASS: Glitch correctly ignored.");
        else          $display("FAIL: Glitch triggered output!");

        // 3. TEST VALID PRESS (Hold High for 200ns / 20 cycles)
        // Expected: 'out' turns 1 after ~120ns
        in = 1;
        #200; 
        
        if (out == 1) $display("PASS: Valid press detected.");
        else          $display("FAIL: Valid press ignored!");

        // 4. TEST RELEASE (Hold Low for 200ns)
        // Expected: 'out' turns 0 after ~120ns
        in = 0;
        #200;
        
        if (out == 0) $display("PASS: Release detected.");
        else          $display("FAIL: Release ignored!");

        $stop;
    end
endmodule