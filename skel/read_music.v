`timescale 1ns / 1ps

module read_music(
   input [7:0] note, 
   output reg [10:0] freq
   );

    always @(*)
      begin
	 freq = 888;
	 case (note)
           "A": freq = 888;
           "B": freq = 791;
           "C": freq = 1493;
           "D": freq = 1330;
           "E": freq = 1185;
           "F": freq = 1119;
           "G": freq = 996;
	 endcase 
      end 

endmodule

