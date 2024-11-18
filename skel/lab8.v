`timescale 1ns / 1ps

module lab8(
   input  clk,
   input  reset,
   input  up_button, 
   output ampPWM,
   output ampSD,
   input  UART_RX,
   output led1 
    );
   
   wire [7:0] sinpos1, envout;
   wire	      pwm;
   wire	      rx_dv;
   wire [7:0] rx_byte;
   wire [10:0] freq;
   reg	       note_start;
   wire	       up_press;

   reg	       writing = 0;
   reg [9:0]   addr = 0;
   reg [9:0]   addr_max = 0;
   wire [7:0]	  dout;

   assign led1 = writing;
   assign ampPWM = (pwm) ? 1'bz : 1'b0;
   assign ampSD = ~writing;

   button_pulse u_db1 (clk, up_button, up_press);

   uart_rx_vlog rx0 (clk, UART_RX, rx_dv, rx_byte);

   rams_sp_wf bram (clk, (writing & rx_dv), 1'b1, addr[9:0], rx_byte[7:0], dout[7:0]);

   // create the finite state machine module / other logic required
   //  to switch between writing the notes into the memory
   //  and playing the notes.

   // You'll need to figure out the states that you need for your FSM from the following
   //  description:
   
   // when the up button is pressed, you should switch between writing and playing

   // when you first start writing, you should set the memory address to 0,
   //  and increment the memory address whenever a new note is received from the UART
   //  (i.e. rx_dv goes high)

   // when you end writing, you should store the largest memory address in addr_max so you know
   //  where the song stops.
   
   // when you first start playing, you should reset the memory address to 0,
   //  set note_start high for one clock cycle to start playing the first note,
   //  wait for env_done to go high to indicate the note is complete.
   //  then increment the memory address and set note_start high again to start playing the second note.
   //  if you have reached the maximum address you should set it back to 0.
   
   envel_gen egen (clk, reset, 11'h180, 11'h1f0, note_start, envout[7:0], env_run, env_done);

   read_music rmus (dout[7:0], freq[10:0]);
    
   sine_gen sigen(clk, reset, freq[10:0], envout[7:0], sinpos1[7:0]);
   
   pwm_gen pwmg(clk, reset, sinpos1[7:0], pwm);
    
endmodule

