`timescale 1ns / 1ps

module pwm_gen6 (
    clk,
    reset,
    inp,
    pwm,
    update
);
  input clk, reset;
  input [5:0] inp;
  output pwm;
  output update;

  reg  [5:0] pwmcnt;
  wire       pwm;

  assign pwm = (pwmcnt < inp) ? 1 : 0;
  assign update = (pwmcnt == 6'd63);  // Assert update every 64 cycles

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pwmcnt <= 0;
    end else begin
      pwmcnt <= pwmcnt + 1;
    end
  end

endmodule
