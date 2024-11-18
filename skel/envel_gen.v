

module envel_gen(clk, reset, Non, N, start, envout, running, done);
   input clk, reset;
   input [10:0] Non, N;
   input	start;
   output reg [7:0] envout;
   output reg running;
   output reg done;
   
   reg [10:0] Ncnt;
   reg [15:0] clkcnt;

   always@(posedge clk or posedge reset)
     begin
         if (reset) begin
	    Ncnt <= 0;
	    clkcnt <= 0;
	    running <= 0;
	    done <= 0;
	    envout <= 0;
         end else begin
	    done <= 0;
	    if (start) begin
	       running <= 1;
	       Ncnt <= 0;
	       clkcnt <= 0;
	       envout <= 8'hE0;
	    end else if (running) begin
	       clkcnt <= clkcnt + 1;
	       if (clkcnt == 16'hFFFF) begin
		  if (Ncnt >= N) begin     
		     envout <= 0;
		     Ncnt <= 0;
		     running <= 0;
		     done <= 1;
		  end else begin
		     Ncnt <= Ncnt + 1;
		     if (Ncnt >= Non) envout <= 0;
		  end
	       end

	    end 
	 end
     end
endmodule
