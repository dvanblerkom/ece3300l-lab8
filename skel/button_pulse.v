`timescale 1ns / 1ps
   
module button_pulse(
		    input clk,
		    input raw_button,
		    output button_pulse
		    );
    
    localparam N = 3;
    
    reg [N - 1:0] Q_reg;
    
    always @(posedge clk)
    begin
        Q_reg <= {Q_reg[N - 2:0], raw_button};
    end
    
    assign button_pulse = (&Q_reg[N - 2:0]) & ~Q_reg[N-1];
endmodule
   
