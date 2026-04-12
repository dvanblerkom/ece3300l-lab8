`timescale 1ns / 1ps

module read_music (
    input [7:0] note,
    input [7:0] octave,
    output reg [31:0] freq
);

  wire [3:0] octave_shift;

  assign octave_shift = 9 - (octave - "0");

  always @(*) begin
    freq = 0;  // default to a rest (no sound)
    case (note)
      "C": freq = 179788 >> octave_shift;
      "d": freq = 190478 >> octave_shift;
      "D": freq = 201805 >> octave_shift;
      "e": freq = 213805 >> octave_shift;
      "E": freq = 226518 >> octave_shift;
      "F": freq = 239988 >> octave_shift;
      "g": freq = 254258 >> octave_shift;
      "G": freq = 269377 >> octave_shift;
      "a": freq = 285395 >> octave_shift;
      "A": freq = 302366 >> octave_shift;
      "b": freq = 320345 >> octave_shift;
      "B": freq = 339394 >> octave_shift;
      default: freq = 0;  // rest
    endcase
  end

endmodule

