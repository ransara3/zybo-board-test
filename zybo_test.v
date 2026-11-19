`timescale 1ns / 1ps

module zybo_test #(
    parameter integer STEP_CYCLES = 31250000
)(
    input wire clk,
    input wire [3:0] sw,
    input wire [3:0] btn,
    output reg [3:0] led
);
    (* ASYNC_REG = "TRUE" *) reg [3:0] sw_meta = 0;
    (* ASYNC_REG = "TRUE" *) reg [3:0] sw_sync = 0;
    (* ASYNC_REG = "TRUE" *) reg [3:0] btn_meta = 0;
    (* ASYNC_REG = "TRUE" *) reg [3:0] btn_sync = 0;
    reg [31:0] divider = 0;
    reg [3:0] count = 0;
    reg [3:0] chase = 4'b0001;

    always @(posedge clk) begin
        sw_meta <= sw;
        sw_sync <= sw_meta;
        btn_meta <= btn;
        btn_sync <= btn_meta;
        if (divider == STEP_CYCLES - 1) begin
            divider <= 0;
            count <= count + 1'b1;
            chase <= {chase[2:0], chase[3]};
        end else begin
            divider <= divider + 1'b1;
        end
    end

    always @* begin
        case (sw_sync[1:0])
            2'b00: led = chase;
            2'b01: led = sw_sync;
            2'b10: led = btn_sync;
            2'b11: led = count;
        endcase
    end
endmodule
