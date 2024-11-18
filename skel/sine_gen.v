
// Sine Wave PWM generator
// Copyright (C) 2024 Daniel Van Blerkom
//
// Uses freecores/verilog_fixed_point_math_library modules
//   Creates sine and cosine from coupled difference equations
//   Probably not as efficient as just using a lookup table, but more instructive
//
// input N = 100MHz / (256 * Freq), where Freq is the audio frequency
// for example, 440Hz (A above middle C) gives:
//   N = 100 Mhz / (256 * 440 Hz) = 888 cycles
// Note, system clk is 100MHz for Digilent Nexys A7
//
// ampl is the amplitude - use 11'h78 for maximum amplitude
//
// pwm output duty cycle is from 0/256 to 256/256
//
// sine and cosine are created from
//   sin[n] = sin[n-1] + a * cos[n-1]
//   cos[n] = cos[n-1] - a * sin[n-1]
//
// with the starting points sin[0] = 0 and cos[0] = 1
//
// a = (2 * Pi) / N
// Use 32 bits fixed point numbers in 20,32 format
//   i.e. 20 bits for fractions, 11 integer bits, and 1 sign bit

module sine_gen(clk, reset, N, ampl, sinpos);
   input clk, reset;
   input [10:0] N;  
   input [7:0] ampl;
   output [7:0] sinpos;

   wire [31:0] sin_out, cos_out;
   reg [31:0] sin_r, cos_r;
   reg [10:0] Ncnt;
   reg [7:0] pwmcnt;
   wire [31:0] a, delsin, delcos, sinfpos;
   wire [7:0] sinpos;

   reg	       dstart, mstart1, mstart2;
   wire	       dcomp, dovf, mcomp1, movf1, mcomp2, movf2;
   wire [6:0]  ampl_div_2, ampl_div_2_plus_1;

   assign ampl_div_2 = ampl >> 1;  // the sine amplitude is 1/2 the peak-to-peak value
   assign ampl_div_2_plus_1 = ampl_div_2 + 1;

// a = (2 * Pi) / N
//   2 * Pi shifted left by 20 bits = 6588397 = 0x006_487ED in 20,32 format
//   N in 20,32 format: {1'b0, N, 20'b0}   

   qdiv #(20,32) acalc (32'h006_487ED, {1'b0, N, 20'b0}, dstart, clk, a, dcomp, dovf);

//   sin_out = sin_r + a*(cos_r);
//   cos_out = cos_r - a*(sin_r);
   
// its a bit wasteful to use two multipliers, we could multiplex into one,
// but we have plenty of FPGA resouces on this chip...   

   qmults #(20,32) dscalc (a, cos_r, mstart1, clk, delsin, mcomp1, movf1);

   qmults #(20,32) dccalc (a, sin_r, mstart2, clk, delcos, mcomp2, movf2);

   qadd #(20,32) adds (sin_r, delsin, sin_out);

   qadd #(20,32) subc (cos_r, {~delcos[31],delcos[30:0]}, cos_out);

// sin function is positive and negative
// add an offset so the sinpos is always positive


   
   qadd #(20,32) addos (sin_r, {1'b0, {4'b0,ampl_div_2_plus_1}, 20'b0}, sinfpos);
   
   assign sinpos = sinfpos[31] ? 0 : sinfpos[27:20];  // output the integer part, clip to zero if negative
   
   always@(posedge clk or posedge reset)
     begin
         if (reset) begin
            sin_r <= 32'h000_00000;
            cos_r <= {1'b0, {4'b0,ampl_div_2}, 20'b0};
	        Ncnt <= 0;
	        pwmcnt <= 0;
	        dstart <= 0;
	        mstart1 <= 0;
	        mstart2 <= 0;
         end else begin
	        dstart <= 0;
	        mstart1 <= 0;
	        mstart2 <= 0;
	        pwmcnt <= pwmcnt + 1;

	      if (pwmcnt == 8'hFF) begin
	       if (Ncnt >= N-1) begin     
		      sin_r <= 32'h000_00000; // reset sin & cos for the first cycle,
		      cos_r <= {1'b0, {4'b0,ampl_div_2}, 20'b0}; //   so we don't accumulate errors
		      Ncnt <= 0;
	       end else begin
		      sin_r <= sin_out;
		      cos_r <= cos_out;
		      Ncnt <= Ncnt + 1;
	       end
	      end

	    if (pwmcnt == 8'h81) begin
	       mstart1 <= 1;  // recalculte cos & sin
	       mstart2 <= 1;
	    end

 	    if (Ncnt == 0 && pwmcnt == 8'h01) begin 
	       dstart <= 1;   // recalculate a once per audio cycle
	    end
	 end 
     end
endmodule
