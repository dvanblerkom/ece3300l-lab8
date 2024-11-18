`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2024 09:37:03 PM
// Design Name: 
// Module Name: pwm_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pwm_gen(clk, reset, inp, pwm); 
   input clk, reset;
   input [7:0] inp;
   output pwm;

   reg [7:0] pwmcnt;
   wire	       pwm;

   assign pwm = (pwmcnt < inp) ? 1 : 0;

  always@(posedge clk or posedge reset)
     begin
         if (reset) begin
	        pwmcnt <= 0;
         end else begin
	        pwmcnt <= pwmcnt + 1;
	     end
     end

endmodule
