`timescale 1ns / 1ps

module lab8 (
    input  clk,
    input  reset,
    input  up_button,
    input  dwn_button,
    input  pdm_sel,
    output ampPWM,
    output ampSD,
    output [6:0] inv_leds,
    output [7:0] enb_leds,
    input  UART_RX,
    output led1,
    output led2
);

  wire [ 5:0] sinpos1;
  wire        envout;
  wire        pwm, pdm;
  wire        rx_dv;
  wire [ 7:0] rx_byte;
  wire [31:0] freq;
  wire        up_press, dwn_press;
  wire        update_pwm, update_pdm;

  wire [7:0]  dout_note, dout_octave;
  wire [7:0]  read_note, read_octave;
  wire [15:0] addr_bcd;          // 4 BCD digits for 10-bit addr (0-1023)
  wire [2:0]  sel;
  wire [3:0]  bcd_digit;
  wire        number_dv, letter_dv;
  wire        env_run, env_done;

  wire         writing;
  wire         playback;
  wire  [ 9:0] addr;
  wire  [ 9:0] addr_max;
  wire  [ 7:0] play_now;
  wire         note_start;

  assign led1   = writing;
  assign led2   = playback;
  assign ampPWM = (pdm_sel) ? ((pdm) ? 1'bz : 1'b0) : ((pwm) ? 1'bz : 1'b0);
  assign ampSD  = ~writing;

  button_pulse u_db1 (
      .clk          (clk),
      .raw_button   (up_button),
      .button_pulse (up_press)
  );

  button_pulse u_db2 (
      .clk          (clk),
      .raw_button   (dwn_button),
      .button_pulse (dwn_press)
  );

  uart_rx_vlog rx0 (
      .i_Clock     (clk),
      .i_Rx_Serial (UART_RX),
      .o_Rx_DV     (rx_dv),
      .o_Rx_Byte   (rx_byte)
  );

  assign number_dv = ((rx_byte >= "0") && (rx_byte <= "9")) ? rx_dv : 1'b0;
  assign letter_dv = ((rx_byte >= "A") && (rx_byte <= "z")) ? rx_dv : 1'b0;

  rams_sp_wf bram_let (   // notes SRAM
      .clk  (clk),
      .we   (writing & letter_dv),
      .en   (1'b1),
      .addr (addr[9:0]),
      .di   (rx_byte[7:0]),
      .dout (dout_note[7:0])
  );

  rams_sp_wf bram_num (   // octaves SRAM
      .clk  (clk),
      .we   (writing & number_dv),
      .en   (1'b1),
      .addr (addr[9:0]),
      .di   (rx_byte[7:0]),
      .dout (dout_octave[7:0])
  );

  // Your FSM goes here:
  // it should control the following output signals:
  // - writing: whether we are storing a song in the RAMs or not
  // - playback: whether we are playing back the music or not
  // - addr: the address to write to or read from the RAMs
  // - addr_max: the maximum address that has been written to in the RAMs
  // - note_start: a pulse that starts the envelope generator for a new note
  // - play_now: the note to play immediately when not in playback mode
  //
  // you'll need to figure out what inputs it needs

  envel_gen egen (
      .clk     (clk),
      .reset   (reset),
      .Non     (11'h180),
      .N       (11'h1f0),
      .start   (note_start),
      .envout  (envout),
      .running (env_run),
      .done    (env_done)
  );

  assign read_note   = (playback) ? dout_note   : play_now;
  assign read_octave = (playback) ? dout_octave : "6";

  read_music rmus (
      .note   (read_note[7:0]),
      .octave (read_octave[7:0]),
      .freq   (freq[31:0])
  );

  sine_gen2 sigen (
      .clk       (clk),
      .reset     (reset),
      .phase_inc (freq[31:0]),
      .ampl      (sinpos1[5:0])
  );

  pdm_gen pdmg (
      .clk    (clk),
      .reset  (reset),
      .inp    ({6{envout}} & sinpos1[5:0]),
      .pdm    (pdm),
      .update (update_pdm)
  );

  pwm_gen6 pwmg (
      .clk    (clk),
      .reset  (reset),
      .inp    ({6{envout}} & sinpos1[5:0]),
      .pwm    (pwm),
      .update (update_pwm)
  );

  doubdab_10bits u2 (
      .b_in    (addr[9:0]),
      .bcd_out (addr_bcd)
  );

// add the rest of the seven-segment display logic here
//  note that now we have 4 BCD digits

endmodule
