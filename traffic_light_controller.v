// Code your design here
module traffic_light_controller (
    input clk,
    input reset,
    input pedestrian_req,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,

    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green,

    output reg ped_walk
);

    // State definitions
    parameter NS_GREEN       = 3'b000;
    parameter NS_YELLOW      = 3'b001;
    parameter ALL_RED_1      = 3'b010;
    parameter PED_WALK_TO_EW = 3'b011;
    parameter EW_GREEN       = 3'b100;
    parameter EW_YELLOW      = 3'b101;
    parameter ALL_RED_2      = 3'b110;
    parameter PED_WALK_TO_NS = 3'b111;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [3:0] count;
    reg [3:0] timer_limit;
    reg timer_done;

    reg ped_pending;


    //====================================================
    // STATE REGISTER
    //====================================================
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            state <= NS_GREEN;
        else
            state <= next_state;
    end


    //====================================================
    // TIMER LIMIT
    //====================================================
    always @(*)
    begin
        case (state)

            NS_GREEN:
                timer_limit = 10;

            NS_YELLOW:
                timer_limit = 3;

            ALL_RED_1:
                timer_limit = 2;

            PED_WALK_TO_EW:
                timer_limit = 5;

            EW_GREEN:
                timer_limit = 10;

            EW_YELLOW:
                timer_limit = 3;

            ALL_RED_2:
                timer_limit = 2;

            PED_WALK_TO_NS:
                timer_limit = 5;

            default:
                timer_limit = 10;

        endcase
    end


    //====================================================
    // TIMER DONE
    //====================================================
    always @(*)
    begin
        if (count == timer_limit - 1)
            timer_done = 1'b1;
        else
            timer_done = 1'b0;
    end


    //====================================================
    // COUNTER
    //====================================================
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            count <= 0;

        else if (timer_done)
            count <= 0;

        else
            count <= count + 1;
    end


    //====================================================
    // PEDESTRIAN REQUEST REGISTER
    //====================================================
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            ped_pending <= 1'b0;

        else if (state == PED_WALK_TO_EW ||
                 state == PED_WALK_TO_NS)
            ped_pending <= 1'b0;

        else if (pedestrian_req)
            ped_pending <= 1'b1;
    end


    //====================================================
    // NEXT STATE LOGIC
    //====================================================
    always @(*)
    begin
        // Default: remain in current state
        next_state = state;

        case (state)

            NS_GREEN:
            begin
                if (timer_done)
                    next_state = NS_YELLOW;
            end

            NS_YELLOW:
            begin
                if (timer_done)
                    next_state = ALL_RED_1;
            end

            ALL_RED_1:
            begin
                if (timer_done)
                begin
                    if (ped_pending)
                        next_state = PED_WALK_TO_EW;
                    else
                        next_state = EW_GREEN;
                end
            end

            PED_WALK_TO_EW:
            begin
                if (timer_done)
                    next_state = EW_GREEN;
            end

            EW_GREEN:
            begin
                if (timer_done)
                    next_state = EW_YELLOW;
            end

            EW_YELLOW:
            begin
                if (timer_done)
                    next_state = ALL_RED_2;
            end

            ALL_RED_2:
            begin
                if (timer_done)
                begin
                    if (ped_pending)
                        next_state = PED_WALK_TO_NS;
                    else
                        next_state = NS_GREEN;
                end
            end

            PED_WALK_TO_NS:
            begin
                if (timer_done)
                    next_state = NS_GREEN;
            end

            default:
                next_state = NS_GREEN;

        endcase
    end


    //====================================================
    // OUTPUT LOGIC - MOORE FSM
    //====================================================
    always @(*)
    begin

        // Default: all outputs OFF
        ns_red    = 1'b0;
        ns_yellow = 1'b0;
        ns_green  = 1'b0;

        ew_red    = 1'b0;
        ew_yellow = 1'b0;
        ew_green  = 1'b0;

        ped_walk  = 1'b0;

        case (state)

            NS_GREEN:
            begin
                ns_green = 1'b1;
                ew_red   = 1'b1;
            end

            NS_YELLOW:
            begin
                ns_yellow = 1'b1;
                ew_red    = 1'b1;
            end

            ALL_RED_1:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

            PED_WALK_TO_EW:
            begin
                ns_red   = 1'b1;
                ew_red   = 1'b1;
                ped_walk = 1'b1;
            end

            EW_GREEN:
            begin
                ns_red   = 1'b1;
                ew_green = 1'b1;
            end

            EW_YELLOW:
            begin
                ns_red    = 1'b1;
                ew_yellow = 1'b1;
            end

            ALL_RED_2:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

            PED_WALK_TO_NS:
            begin
                ns_red   = 1'b1;
                ew_red   = 1'b1;
                ped_walk = 1'b1;
            end

            default:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

        endcase

    end

endmodule
