`timescale 1ns / 1ps

// Combinational binary-to-BCD converter for 10-bit input (0–1023).
// Uses the double-dabble (shift-and-add-3) algorithm unrolled into
// 7 combinational stages.  Each dd_add3 instance adds 3 to its
// 4-bit input when the value is >= 5, matching the add-3 step of
// the algorithm.
//
// Output layout (16-bit BCD):
//   bcd_out[15:12] = thousands digit (0 or 1)
//   bcd_out[11: 8] = hundreds digit  (0–9)
//   bcd_out[ 7: 4] = tens digit      (0–9)
//   bcd_out[ 3: 0] = units digit     (0–9)

module doubdab_10bits (
    input  [ 9:0] b_in,
    output [15:0] bcd_out
);

  wire [15:0] a0, a1, a2, a3, a4, a5, a6, a7;

  // Seed: 6 leading BCD zeros above the 10-bit input
  assign a0 = {6'b0, b_in};

  // -------------------------------------------------------------------
  // Stage 1 – first window that can reach >= 5: bits [10:7]
  // -------------------------------------------------------------------
  dd_add3 u1  (a0[10:7], a1[10:7]);
  assign a1[15:11] = a0[15:11];
  assign a1[  6:0] = a0[  6:0];

  // -------------------------------------------------------------------
  // Stage 2 – units window slides to [9:6]
  // -------------------------------------------------------------------
  dd_add3 u2  (a1[9:6], a2[9:6]);
  assign a2[15:10] = a1[15:10];
  assign a2[  5:0] = a1[  5:0];

  // -------------------------------------------------------------------
  // Stage 3 – units window slides to [8:5]
  // -------------------------------------------------------------------
  dd_add3 u3  (a2[8:5], a3[8:5]);
  assign a3[15:9] = a2[15:9];
  assign a3[ 4:0] = a2[ 4:0];

  // -------------------------------------------------------------------
  // Stage 4 – units at [7:4], tens digit enters at [11:8]  (non-overlapping)
  // -------------------------------------------------------------------
  dd_add3 u4  (a3[ 7:4], a4[ 7:4]);   // units
  dd_add3 u5  (a3[11:8], a4[11:8]);   // tens  (first check)
  assign a4[15:12] = a3[15:12];
  assign a4[  3:0] = a3[  3:0];

  // -------------------------------------------------------------------
  // Stage 5 – units at [6:3], tens at [10:7]  (non-overlapping)
  // -------------------------------------------------------------------
  dd_add3 u6  (a4[ 6:3], a5[ 6:3]);   // units
  dd_add3 u7  (a4[10:7], a5[10:7]);   // tens
  assign a5[15:11] = a4[15:11];
  assign a5[  2:0] = a4[  2:0];

  // -------------------------------------------------------------------
  // Stage 6 – units at [5:2], tens at [9:6]  (non-overlapping)
  // -------------------------------------------------------------------
  dd_add3 u8  (a5[5:2], a6[5:2]);     // units
  dd_add3 u9  (a5[9:6], a6[9:6]);     // tens
  assign a6[15:10] = a5[15:10];
  assign a6[  1:0] = a5[  1:0];

  // -------------------------------------------------------------------
  // Stage 7 – units at [4:1], tens at [8:5], hundreds at [12:9]
  //           (all non-overlapping)
  // -------------------------------------------------------------------
  dd_add3 u10 (a6[ 4:1], a7[ 4:1]);   // units
  dd_add3 u11 (a6[ 8:5], a7[ 8:5]);   // tens
  dd_add3 u12 (a6[12:9], a7[12:9]);   // hundreds (first/only check)
  assign a7[15:13] = a6[15:13];
  assign a7[    0] = a6[    0];

  // Thousands digit [15:12] is at most 1, so it never needs add-3 correction.
  assign bcd_out = a7;

endmodule
