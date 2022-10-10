/*
    Author: James Nock (jpnock/jpn119)
    Date:   2022/09/13
*/

module mod_test (
    input logic clk_i,
    input logic rst_i,
    input logic [7:0] value_i,
    output logic [7:0] value_o
);

  // value_q stores the presented value of value_i at the positive clock edge;
  // therefore the value_i signal is delayed by one clock cycle.
  logic [7:0] value_q;

  // value_q2 stores the value of value_i delayed by two clock cycles.
  logic [7:0] value_q2;

  // It's good practice to make registers for outputs (e.g. value_q2) and then
  // wire them up using constant assignment, rather than assigning directly to
  // the output in an always_ff block.
  assign value_o = value_q2;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      value_q <= 0;
    end else begin
      // All assignments in an always_ff block occur at the same time, so if
      // value_i is updated in clock cycle 1, then value_q will hold this value
      // in clock cycle 2 and value_o will hold the same value in clock cycle 3.
      value_q  <= value_i;
      value_q2 <= value_q;

      /*
      // The following is equivalent to the above.
      value_q2 <= value_q;
      value_q  <= value_i;
      */
    end
  end

endmodule
