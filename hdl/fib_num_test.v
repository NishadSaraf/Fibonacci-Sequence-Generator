// =======================================================================
//   Filename:     fib_num_test.v
//   Created by:   Tareque Ahmad
//   Date:         Mar 30, 2017
//
//   Description:  Test module for fib_num_gen dut
// =======================================================================

`timescale 1ns/1ps

`define DATA_WIDTH 64
`define FIB_ORDER  16

module fib_num_test
  (
   // Global inputs
   input                    clk,
   output                   reset_n,

   // Control outputs
   output                   load,
   output                   clear,

   // Data output
   output [`FIB_ORDER-1:0]  order,
   output [`DATA_WIDTH-1:0] data_in,

   // Inputs
   input                    done,
   input                    error,
   input                    overflow,
   input  [`DATA_WIDTH-1:0] data_out
   );

   parameter RESET_DURATION = 500;
   parameter MAX_ORDER = 80;
   parameter MAX_INIT_VAL = 80;
   parameter INIT_VAL = 8'h1;

   // Define internal registers
   reg                   int_reset_n;
   reg                   int_load;
   reg                   int_clear;
   reg [`FIB_ORDER-1:0]  int_order;
   reg [`FIB_ORDER-1:0]  order_count;
   reg [`DATA_WIDTH-1:0] int_data;
   reg [`DATA_WIDTH-1:0] first_data;
   reg [31:0] test_seq;
   reg [3:0] delay;

   initial begin

      // Generate one-time internal reset signal
      int_reset_n = 0;
      int_load = 0;
      int_clear = 0;
      int_order = 0;
      int_data = 8'h00;
      first_data = INIT_VAL;

      # RESET_DURATION int_reset_n = 1;
      $display ("\n@ %0d ns The chip is out of reset", $time);

      repeat (10)  @(posedge clk);

      test_seq = 0;

      repeat (MAX_INIT_VAL) begin

         order_count = 0;

         repeat (MAX_ORDER) begin
            test_seq = test_seq+1;
            order_count = order_count + 1;

            int_load = 1;
            repeat (1)  @(posedge clk);
            int_order = order_count;
            int_data = first_data;
            $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, int_order);

            while (done == 0) @(posedge clk);
            $display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
            int_load = 0;
            int_order = 0;
            int_data = 8'h0;
            delay = ({$random} % 4'hf);
            repeat (delay+2)  @(posedge clk);

         end
         first_data = first_data + 1;

      end

      // Test error case w/ zero order
      test_seq = test_seq+1;
      int_load = 1;
      repeat (1)  @(posedge clk);
      int_order = 0;
      int_data = 1;
      $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, int_order);

      while (error == 0) @(posedge clk);
      $display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
      delay = ({$random} % 4'hf);
      repeat (delay+20)  @(posedge clk);
      int_load = 0;
      int_order = 0;
      int_data = 8'h0;
      int_clear = 1;
      delay = ({$random} % 4'hf);
      repeat (delay+2)  @(posedge clk);

      // Test to make sure FSM recovers from error condition
      test_seq = test_seq+1;
      int_clear = 0;
      int_load = 1;
      repeat (1)  @(posedge clk);
      int_order = 10;
      int_data = 1;
      $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, int_order);

      while (done == 0) @(posedge clk);
      $display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
      int_load = 0;
      int_order = 0;
      int_data = 8'h0;
      delay = ({$random} % 4'hf);
      repeat (delay+2)  @(posedge clk);

      // Test error case w/ zero data
      test_seq = test_seq+1;
      int_load = 1;
      repeat (1)  @(posedge clk);
      int_order = 5;
      int_data = 0;
      $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, int_order);

      while (error == 0) @(posedge clk);
      $display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
      delay = ({$random} % 4'hf);
      repeat (delay+20)  @(posedge clk);
      int_load = 0;
      int_order = 0;
      int_data = 8'h0;
      int_clear = 1;
      delay = ({$random} % 4'hf);
      repeat (delay+2)  @(posedge clk);

      // Test to make sure FSM recovers from error condition
      test_seq = test_seq+1;
      int_clear = 0;
      int_load = 1;
      repeat (1)  @(posedge clk);
      int_order = 10;
      int_data = 2;
      $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, int_order);

      while (done == 0) @(posedge clk);
      $display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
      int_load = 0;
      int_order = 0;
      int_data = 8'h0;
      delay = ({$random} % 4'hf);
      repeat (delay+2)  @(posedge clk);

      // Test  overflow case w/ high order
      test_seq = test_seq+1;
      int_load = 1;
      repeat (1)  @(posedge clk);
      int_order = 1500;
      int_data = 1;
      $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, int_order);

      while (overflow == 0) @(posedge clk);
      repeat (1)  @(posedge clk);
      $display ("@ %0d ns: Result: %h. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
      delay = ({$random} % 4'hf);
      repeat (delay+20)  @(posedge clk);
      int_load = 0;
      int_order = 0;
      int_data = 8'h0;
      int_clear = 1;
      delay = ({$random} % 4'hf);
      repeat (delay+2)  @(posedge clk);

      // Test to make sure FSM recovers from overflow condition
      test_seq = test_seq+1;
      int_clear = 0;
      int_load = 1;
      repeat (1)  @(posedge clk);
      int_order = 15;
      int_data = 1;
      $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, int_order);

      while (done == 0) @(posedge clk);
      $display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
      int_load = 0;
      int_order = 0;
      int_data = 8'h0;
      delay = ({$random} % 4'hf);
      repeat (delay+2)  @(posedge clk);

      $finish;

   end

   // Continuous assignment to output
   assign reset_n = int_reset_n;
   assign load    = int_load;
   assign clear   = int_clear;
   assign order   = int_order;
   assign data_in = int_data;

endmodule //  fib_num_test

