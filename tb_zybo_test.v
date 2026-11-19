`timescale 1ns / 1ps

module tb_zybo_test;
    reg clk = 0;
    reg [3:0] sw = 0;
    reg [3:0] btn = 0;
    wire [3:0] led;
    integer pattern;
    integer step;
    reg [3:0] expected;
    zybo_test #(.STEP_CYCLES(16)) dut (.clk(clk), .sw(sw), .btn(btn), .led(led));
    always #4 clk = ~clk;

    task check_led;
        input [3:0] value;
        begin
            if (led !== value) begin
                $display("FAIL: expected %b, got %b at %t", value, led, $time);
                $fatal(1);
            end
        end
    endtask

    initial begin
        #1;
        check_led(4'b0001);
        for (step = 1; step <= 8; step = step + 1) begin
            repeat (16) @(negedge clk);
            expected = 4'b0001 << (step % 4);
            check_led(expected);
        end
        for (pattern = 0; pattern < 4; pattern = pattern + 1) begin
            sw = (pattern << 2) | 4'b0001;
            repeat (3) @(negedge clk);
            check_led(sw);
        end
        sw = 4'b0010;
        for (pattern = 0; pattern < 16; pattern = pattern + 1) begin
            btn = pattern;
            repeat (3) @(negedge clk);
            check_led(btn);
        end
        sw = 4'b0011;
        repeat (3) @(negedge clk);
        expected = dut.count;
        check_led(expected);
        for (step = 0; step < 20; step = step + 1) begin
            repeat (16) @(negedge clk);
            expected = expected + 1'b1;
            check_led(expected);
        end
        $display("PASS: chase, switches, buttons, and counter including wraparound");
        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "Simulation timeout");
    end
endmodule
