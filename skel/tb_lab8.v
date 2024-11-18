`timescale 1ns / 1ps

module tb_lab8;
    // Signal declaration
   reg clk;
   reg reset;
   reg tx_start;
   reg [7:0] tx_data1;
   wire	       tx_done1;
   wire	       tx_ready1;
   wire	       UART_RX;
   reg [7:0]   testdata;
   wire	       ampPWM;
   wire	       ampSD;
   wire	       led1;
   reg	       up_btn;
   
   reg [7:0]   testinput [7:0];
 
    // Clock generation
    always #5 clk = ~clk; // Generate a clock with a period of 10 ns

    // Testbench UART instances
    uart_tx_vlog uart_tx_tb (
        .i_Clock(clk),
        .i_Tx_DV(tx_start),
        .i_Tx_Byte(tx_data1),
        .o_Tx_Serial(UART_RX),
        .o_Tx_Done(tx_done1),
        .o_Tx_Ready(tx_ready1) 
    );

   lab8 dut0 (
		 // Outputs
	      .ampPWM (ampPWM),
	      .ampSD (ampSD),
	      .led1 (led1),
	      // Inputs
	      .clk			(clk),
	      .reset			(reset),
	      .up_button (up_btn),
	      .UART_RX		(UART_RX));
   
   initial begin
      testinput[0] = "A";
      testinput[1] = "B";
      testinput[2] = "C";
      testinput[3] = "D";
      testinput[4] = "E";
      testinput[5] = "F";
      testinput[6] = "G";
      testinput[7] = "A";
   end      

    initial begin
       clk = 0;
       tx_start = 0;
       reset = 1;
       up_btn = 0;
       #11 reset = 0;
       #20;
       #100 up_btn = 1;
       #100 up_btn = 0;

       for (testdata = 0; testdata <= 2; testdata = testdata + 1) begin
          #20;
	  tx_data1 = testinput[testdata]; 
          #20;
	  
          tx_start = 1; 
          #10 tx_start = 0;
	  $display("SENT: '%c", tx_data1);
          #14000000;
       end 

       #100 up_btn = 1;
       #100 up_btn = 0;
       #14000000;
       
    end

endmodule
