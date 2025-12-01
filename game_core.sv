module game_core (
    input logic clk,
    input logic reset,
    input logic frame_tick,
    input logic btn_up,
    input logic btn_down,
    input logic video_on,
    output logic [9:0] paddle_y,
    output logic [9:0] ball_x,
    output logic [9:0] ball_y,
    output logic game_over
);

    // Constants
    localparam X_MAX = 640;
    localparam Y_MAX = 480;
    localparam PADDLE_H = 60;
    localparam PADDLE_W = 10;
    localparam PADDLE_X = 20;
    localparam PADDLE_VEL = 4;
    localparam BALL_SIZE = 10;
    localparam BALL_START_X = X_MAX / 2;
    localparam BALL_START_Y = Y_MAX / 2;
    localparam BALL_VEL_POS = 3;
    localparam BALL_VEL_NEG = -3;
    localparam GAME_OVER_DELAY = 60; // 60 Frames ~ 1 Second

    // FSM States
    typedef enum logic [1:0] {STATE_IDLE, STATE_PLAY, STATE_GAMEOVER} state_t;
    state_t state_reg, state_next;

    // Physics Registers
    logic [9:0] pad_y_reg, pad_y_next;
    logic [9:0] ball_x_reg, ball_x_next;
    logic [9:0] ball_y_reg, ball_y_next;
    logic [9:0] ball_dx_reg, ball_dx_next;
    logic [9:0] ball_dy_reg, ball_dy_next;
    logic [6:0] timer_reg, timer_next; 

    logic frame_tick_d, tick_enable;
    assign tick_enable = (frame_tick && !frame_tick_d);

    // Sequential
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= STATE_IDLE;
            pad_y_reg <= (Y_MAX - PADDLE_H) / 2;
            ball_x_reg <= BALL_START_X;
            ball_y_reg <= BALL_START_Y;
            ball_dx_reg <= BALL_VEL_POS;
            ball_dy_reg <= BALL_VEL_POS;
            frame_tick_d <= 1'b0;
            timer_reg <= 0;
        end else begin
            state_reg <= state_next;
            pad_y_reg <= pad_y_next;
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            ball_dx_reg <= ball_dx_next;
            ball_dy_reg <= ball_dy_next;
            frame_tick_d <= frame_tick;
            timer_reg <= timer_next;
        end
    end

    // Combinational
    always_comb begin
        state_next = state_reg;
        pad_y_next = pad_y_reg;
        ball_x_next = ball_x_reg;
        ball_y_next = ball_y_reg;
        ball_dx_next = ball_dx_reg;
        ball_dy_next = ball_dy_reg;
        timer_next = timer_reg; 

        case (state_reg)
            STATE_IDLE: begin
                timer_next = 0;
                ball_x_next = BALL_START_X;
                ball_y_next = BALL_START_Y;
                pad_y_next = (Y_MAX - PADDLE_H) / 2;
                if (btn_up || btn_down) state_next = STATE_PLAY;
            end

            STATE_PLAY: begin
                if (tick_enable) begin
                    // Paddle
                    if (btn_up && pad_y_reg > PADDLE_VEL) 
                        pad_y_next = pad_y_reg - PADDLE_VEL;
                    else if (btn_down && pad_y_reg < (Y_MAX - PADDLE_H - PADDLE_VEL)) 
                        pad_y_next = pad_y_reg + PADDLE_VEL;

                    // Ball Move
                    ball_x_next = ball_x_reg + ball_dx_reg;
                    ball_y_next = ball_y_reg + ball_dy_reg;

                    // Collisions
                    if (ball_y_reg < BALL_VEL_POS) ball_dy_next = BALL_VEL_POS;
                    else if (ball_y_reg > (Y_MAX - BALL_SIZE - BALL_VEL_POS)) ball_dy_next = BALL_VEL_NEG;
                    
                    if (ball_x_reg >= PADDLE_X && ball_x_reg <= (PADDLE_X + PADDLE_W + BALL_VEL_POS)) begin
                        if ((ball_y_reg + BALL_SIZE >= pad_y_reg) && (ball_y_reg <= pad_y_reg + PADDLE_H))
                            ball_dx_next = BALL_VEL_POS;
                    end
                    
                    if (ball_x_reg > (X_MAX - BALL_SIZE - BALL_VEL_POS)) ball_dx_next = BALL_VEL_NEG;
                    
                    // Game Over
                    if (ball_x_reg < 5) state_next = STATE_GAMEOVER;
                end
            end

            STATE_GAMEOVER: begin
                if (tick_enable && timer_reg < GAME_OVER_DELAY)
                    timer_next = timer_reg + 1;
                
                if (timer_reg >= GAME_OVER_DELAY) begin
                    if (btn_up || btn_down) state_next = STATE_IDLE;
                end
            end
        endcase
    end

    assign paddle_y = pad_y_reg;
    assign ball_x = ball_x_reg;
    assign ball_y = ball_y_reg;
    assign game_over = (state_reg == STATE_GAMEOVER);

endmodule