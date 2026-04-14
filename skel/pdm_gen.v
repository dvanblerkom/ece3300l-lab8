`timescale 1ns / 1ps

module pdm_gen (
    clk,
    reset,
    inp,
    pdm,
    update
);
  input clk, reset;
  input [5:0] inp;
  output pdm;
  output update;

  reg [2:0] updcnt;
  reg pdm;
  wire [6:0] sum;
  reg [5:0] acc;

  assign update = (updcnt == 3'd7);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      updcnt <= 0;
    end else begin
      updcnt <= updcnt + 1;
    end
  end

  assign sum = {1'b0, acc} + {1'b0, inp};

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      acc <= 0;
      pdm <= 0;
    end else if (update) begin
      acc <= sum[5:0];
      pdm <= sum[6];
    end
  end

endmodule

