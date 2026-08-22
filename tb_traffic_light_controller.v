`timescale 1s/1ms

module tb_traffic_light_controller;

    reg clk;
    reg reset;
    reg pedestrian_req;

    wire ns_red;
    wire ns_yellow;
    wire ns_green;

    wire ew_red;
    wire ew_yellow;
    wire ew_green;

    wire ped_walk;

    // Instantiate the design
    traffic_light_controller dut (
        .clk(clk),
        .reset(reset),
        .pedestrian_req(pedestrian_req),

        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),

        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green),

        .ped_walk(ped_walk)
    );

    // 1 Hz clock
    always #0.5 clk = ~clk;

    // Generate waveform
    initial
    begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light_controller);
    end

    // Test sequence
    initial
    begin
        clk = 0;
        reset = 1;
        pedestrian_req = 0;

        // Reset
        #1;
        reset = 0;

        // Normal operation
        #16;

        // Pedestrian presses button during EW_GREEN
        pedestrian_req = 1;
        #1;
        pedestrian_req = 0;

        // Continue simulation
        #20;

        $finish;
    end

    // Monitor important signals
    initial
    begin
        $monitor(
            "Time=%0t | State=%b | Count=%d | PedReq=%b | PedPending=%b | PedWalk=%b",
            $time,
            dut.state,
            dut.count,
            pedestrian_req,
            dut.ped_pending,
            ped_walk
        );
    end

endmodule
