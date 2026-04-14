// sine_gen2.v
// DDS sine generator — no divider, power-of-2 phase accumulator.
//
// phase_inc = round(f_audio * 2^32 / f_clk)
//   e.g. 440 Hz, 100 MHz clk → phase_inc = 18898
//
// ampl is always >= 0 (|sin| output, 0..63)

module sine_gen2 (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] phase_inc,
    output reg  [5:0]  ampl
);

    // ---------------------------------------------------------------
    // Sine LUT: 64 entries of |sin|, one quarter-cycle
    // sine_lut[i] = round(32 * sin(pi * i / 64))
    // ---------------------------------------------------------------
    reg [4:0] sine_lut [0:63];
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            sine_lut[i] = $rtoi(31.0 * $sin(3.14159265358979 * i / 128.0) + 0.5);
    end

    // ---------------------------------------------------------------
    // 32-bit phase accumulator — overflows naturally at 2^32
    // Top 8 bits are the LUT address, no division needed
    // ---------------------------------------------------------------
    reg [31:0] phase;

    always @(posedge clk or posedge reset) begin
        if (reset)
            phase <= 32'd0;
        else
            phase <= phase + phase_inc;   // natural 2^32 overflow
    end

    // Top 2 bits = quadrant (0..3)
    // Next 6 bits = position within quadrant
    wire [1:0] quadrant = phase[31:30];
    wire [5:0] idx      = phase[29:24];

    // Mirror index in Q1 and Q3 (descending half of each half-wave)
    wire [5:0] lut_addr = (quadrant[0]) ? ~idx : idx;
    wire [4:0] lut_out  = sine_lut[lut_addr];

    // Negate in Q2 and Q3 (negative half of sine)
    always @(posedge clk or posedge reset) begin
        if (reset)
            ampl <= 8'd0;
        else
            ampl <= quadrant[1] ?  6'd32-{1'b0, lut_out}
                                :  {1'b0, lut_out}+6'd32;
    end

endmodule