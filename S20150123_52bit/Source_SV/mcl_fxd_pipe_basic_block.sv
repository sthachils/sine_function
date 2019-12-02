//-----------------------------------------------------------------------//
// Basic block for Horner's scheme
// Multiplier --> adder --> pipeline 
//-----------------------------------------------------------------------//
module mcl_fxd_pipe_basic_block #(
  parameter FXD_Q = 4,
  parameter FXD_N = 8,
  parameter NUM_CYCLES_FOR_MULT = 1,
  parameter NUM_CYCLES_FOR_ADD = 1
) (
  input  logic                  clk,
  input  logic                  rst_n,
  input  logic                  pre_avail_mult_1,
  output logic                  pre_get_mult_1,
  input  logic [FXD_N-1:0]      pre_data_mult_1,
  input  logic                  pre_avail_mult_2,
  output logic                  pre_get_mult_2,
  input  logic [FXD_N-1:0]      pre_data_mult_2,
  input  logic                  pre_avail_add_1,
  output logic                  pre_get_add_1,
  input  logic [FXD_N-1:0]      pre_data_add_1,
  output logic                  post_avail_mul_add,
  input  logic                  post_get_mul_add,
  output logic [FXD_N-1:0]      post_data_mul_add,

  input  logic                  pre_avail_pl_x,
  output logic                  pre_get_pl_x,
  input  logic [FXD_N-1:0]      pre_data_pl_x,
  output logic                  post_avail_pl_x,
  input  logic                  post_get_pl_x,
  output logic [FXD_N-1:0]      post_data_pl_x,

  input  logic                  pre_avail_pl_x2,
  output logic                  pre_get_pl_x2,
  input  logic [FXD_N-1:0]      pre_data_pl_x2,
  output logic                  post_avail_pl_x2,
  input  logic                  post_get_pl_x2,
  output logic [FXD_N-1:0]      post_data_pl_x2
);

logic                    post_avail_mult;
logic                    post_get_mult;
logic [FXD_N-1:0]        post_data_mult;
logic                    pre_avail_add_2;
logic                    pre_get_add_2;
logic [FXD_N-1:0]        pre_data_add_2;
logic                    post_avail_add;
logic                    post_get_add;  
logic [FXD_N-1:0]        post_data_add;
logic                    pre_avail_pl;
logic                    pre_get_pl;
logic [FXD_N-1:0]        pre_data_pl;
logic                    post_avail_pl;
logic                    post_get_pl;
logic [FXD_N-1:0]        post_data_pl;

multiplier #(
  .FXD_Q                 (FXD_Q),
  .FXD_N                 (FXD_N),
  .NUM_CYCLES_FOR_MULT   (NUM_CYCLES_FOR_MULT)
) i_multiplier (
  //.clk                   (clk),
  //.rst_n                 (rst_n),
  .pre_avail_1           (pre_avail_mult_1),
  .pre_get_1             (pre_get_mult_1), 
  .pre_data_1            (pre_data_mult_1),
  .pre_avail_2           (pre_avail_mult_2),
  .pre_get_2             (pre_get_mult_2), 
  .pre_data_2            (pre_data_mult_2),
  .post_avail            (post_avail_mult),
  .post_get              (post_get_mult),
  .post_data             (post_data_mult)
);

//connect multipler to adder
assign pre_avail_add_2 = post_avail_mult;
assign post_get_mult   = pre_get_add_2; 
assign pre_data_add_2  = post_data_mult;

adder #(
  .FXD_Q                 (FXD_Q),
  .FXD_N                 (FXD_N),
  .NUM_CYCLES_FOR_ADD    (NUM_CYCLES_FOR_ADD)
) i_adder (
  //.clk                   (clk),
  //.rst_n                 (rst_n),
  .pre_avail_1           (pre_avail_add_1),
  .pre_get_1             (pre_get_add_1), 
  .pre_data_1            (pre_data_add_1),
  .pre_avail_2           (pre_avail_add_2),
  .pre_get_2             (pre_get_add_2), 
  .pre_data_2            (pre_data_add_2),
  .post_avail            (post_avail_add),
  .post_get              (post_get_add),
  .post_data             (post_data_add)
);

//connect adder to pipeline
assign pre_avail_pl = post_avail_add;
assign post_get_add = pre_get_pl;
assign pre_data_pl  = post_data_add;

pipeline #(
  .FXD_N                 (FXD_N)
) i_pipeline_mult_add (
  .clk                   (clk),
  .rst_n                 (rst_n),
  .pre_avail             (pre_avail_pl),
  .pre_get               (pre_get_pl), 
  .pre_data              (pre_data_pl),
  .post_avail            (post_avail_pl),
  .post_get              (post_get_pl),
  .post_data             (post_data_pl)
);

//connect pipeline to module interface
assign post_avail_mul_add = post_avail_pl;
assign post_get_pl        = post_get_mul_add;
assign post_data_mul_add  = post_data_pl;


pipeline #(
  .FXD_N                 (FXD_N)
) i_pipeline_x (
  .clk                   (clk),
  .rst_n                 (rst_n),
  .pre_avail             (pre_avail_pl_x),
  .pre_get               (pre_get_pl_x), 
  .pre_data              (pre_data_pl_x),
  .post_avail            (post_avail_pl_x),
  .post_get              (post_get_pl_x),
  .post_data             (post_data_pl_x)
);

pipeline #(
  .FXD_N                 (FXD_N)
) i_pipeline_x2 (
  .clk                   (clk),
  .rst_n                 (rst_n),
  .pre_avail             (pre_avail_pl_x2),
  .pre_get               (pre_get_pl_x2), 
  .pre_data              (pre_data_pl_x2),
  .post_avail            (post_avail_pl_x2),
  .post_get              (post_get_pl_x2),
  .post_data             (post_data_pl_x2)
);

endmodule 
