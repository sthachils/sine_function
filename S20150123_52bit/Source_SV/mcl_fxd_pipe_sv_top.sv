//-----------------------------------------------------------------------//
// Horner's scheme implementation on a fixed pipeline for sine
//-----------------------------------------------------------------------//

module mcl_fxd_pipe_sv_top #(
  parameter MCL_NUM_COEFFS       = 21,
  parameter FXD_Q                = 4,
  parameter FXD_N                = 8,
  parameter FLT_EXP              = 11,
  parameter FLT_FRAC             = 52,
  parameter NUM_CYCLES_FOR_MULT  = 1,
  parameter NUM_CYCLES_FOR_ADD   = 1
) (
  input  logic                      clk,
  input  logic                      rst_n,
  //x available
  input  logic                      pre_mcl_top_avail_x,
  output logic                      pre_mcl_top_get_x,
  input  logic [FLT_EXP+FLT_FRAC:0] pre_mcl_top_data_x,
  //x2 available
  //input  logic                      pre_mcl_top_avail_x2,
  //output logic                      pre_mcl_top_get_x2,
  //input  logic [FXD_N-1:0]          pre_mcl_top_data_x2,
  //final value available
  output logic                      post_mcl_top_avail,
  input  logic                      post_mcl_top_get,
  output logic [FLT_EXP+FLT_FRAC:0] post_mcl_top_data
);

  const logic [FXD_N-1:0] MCL_COEFF_ARRAY [0:MCL_NUM_COEFFS-1]; 
  initial begin
    $readmemh("SVCoeff.dat",MCL_COEFF_ARRAY);
  end
  
//  = {
//    //Format- 1-Sign 3-Integer 60-Fractional (2's compliment is NOT used)
//    //logic used is that Max(x) = Pi / 2; Max (x square) needs only 2 bits of integer
//    //3 bits of integer is used to align the coeffs values for ease of use
//    64'h 8_000_0000_0000_000a,  //-19 Subscript[9.7a4da340a0ab92650f61dbdcb, 16]*16^(-15)
//    64'h 0_000_0000_0000_0caa,  // 17 Subscript[c.a963b81856a53593028cbbb8d, 16]*16^(-13)
//    64'h 8_000_0000_000d_73fa,  //-15 Subscript[d.73f9f399dc0f88ec32b587746, 16]*16^(-11)
//    64'h 0_000_0000_0b09_230a,  // 13 Subscript[b.092309d43684be51c198e91d8, 16]*16^(-9)
//    64'h 8_000_0006_b991_59fe,  //-11 Subscript[6.b99159fd5138e3f9d1f92e0df, 16]*16^(-7)
//    64'h 0_000_02e3_bc74_aad9,  //  9 Subscript[0.00002e3bc74aad8e671f5583911ca00, 16]
//    64'h 8_000_d00d_00d0_0d01,  //- 7 Subscript[0.000d00d00d00d00d00d00d00d00d0, 16]
//    64'h 0_022_2222_2222_2222,  //  5 Subscript[0.0222222222222222222222222222, 16]
//    64'h 8_2aa_aaaa_aaaa_aaab,  //- 3 Subscript[0.2aaaaaaaaaaaaaaaaaaaaaaaaab, 16]
//    64'h 1_000_0000_0000_0000   //  1 Subscript[1.00000000000000000000000000, 16]
//    
//  };
  localparam PRE_AVAIL_COEFF_ARRAY = 1'b1;

  logic                 pre_avail_mult_1   [0:MCL_NUM_COEFFS-1];
  logic                 pre_get_mult_1     [0:MCL_NUM_COEFFS-1];
  logic [FXD_N-1:0]     pre_data_mult_1    [0:MCL_NUM_COEFFS-1];
  logic                 pre_avail_mult_2   [0:MCL_NUM_COEFFS-1];
  logic                 pre_get_mult_2     [0:MCL_NUM_COEFFS-1];
  logic [FXD_N-1:0]     pre_data_mult_2    [0:MCL_NUM_COEFFS-1];
  logic                 pre_avail_add_1    [0:MCL_NUM_COEFFS-1];
  logic                 pre_get_add_1      [0:MCL_NUM_COEFFS-1];
  logic [FXD_N-1:0]     pre_data_add_1     [0:MCL_NUM_COEFFS-1];
  logic                 post_avail_mul_add [0:MCL_NUM_COEFFS-1];
  logic                 post_get_mul_add   [0:MCL_NUM_COEFFS-1];
  logic [FXD_N-1:0]     post_data_mul_add  [0:MCL_NUM_COEFFS-1];
  logic                 pre_avail_x        [0:MCL_NUM_COEFFS-1];
  logic                 pre_get_x          [0:MCL_NUM_COEFFS-1];
  logic [FXD_N-1:0]     pre_data_x         [0:MCL_NUM_COEFFS-1];
  logic                 post_avail_x       [0:MCL_NUM_COEFFS-1];
  logic                 post_get_x         [0:MCL_NUM_COEFFS-1];
  logic [FXD_N-1:0]     post_data_x        [0:MCL_NUM_COEFFS-1];
  logic                 pre_avail_x2       [0:MCL_NUM_COEFFS-1];
  logic                 pre_get_x2         [0:MCL_NUM_COEFFS-1];
  logic [FXD_N-1:0]     pre_data_x2        [0:MCL_NUM_COEFFS-1];
  logic                 post_avail_x2      [0:MCL_NUM_COEFFS-1];
  logic                 post_get_x2        [0:MCL_NUM_COEFFS-1];
  logic [FXD_N-1:0]     post_data_x2       [0:MCL_NUM_COEFFS-1];

  logic                 post_fxd_pipe_bb_avail;
  logic                 post_fxd_pipe_bb_get;
  logic [FXD_N-1:0]     post_fxd_pipe_bb_data;

  logic                 post_fxd_pipe_bb_x_avail;
  logic                 post_fxd_pipe_bb_x_get;  
  logic [FXD_N-1:0]     post_fxd_pipe_bb_x_data;  
//------------------------------------------------------------------------------
// Pre-processing part - float to fixed conversion, x -> x2 calculation
// pipeline stage as x*x stage is heavily combinatorial 
//------------------------------------------------------------------------------
  //float to fixed conversion
  logic                 post_avail_flt2fxd_x;
  logic                 post_get_flt2fxd_x;
  logic [FXD_N-1:0]     post_data_flt2fxd_x;
  logic                 post_avail_mult_x2;
  logic                 post_get_mult_x2;
  logic [FXD_N-1:0]     post_data_mult_x2;
  logic                 post_avail_preproc_x;
  logic                 post_get_preproc_x;
  logic [FXD_N-1:0]     post_data_preproc_x;
  logic                 post_avail_preproc_x2;
  logic                 post_get_preproc_x2;
  logic [FXD_N-1:0]     post_data_preproc_x2;
  logic                 post_avail_mult_postproc;
  logic                 post_get_mult_postproc;
  logic [FXD_N-1:0]     post_data_mult_postproc;

 float_to_fixed #(
    .FLT_EXP            (FLT_EXP),
    .FLT_FRAC           (FLT_FRAC),
    .FXD_N              (FXD_N),
    .FXD_Q              (FXD_Q)
  ) i_float_to_fixed (
    .pre_avail          (pre_mcl_top_avail_x),
    .pre_get            (pre_mcl_top_get_x),
    .pre_data           (pre_mcl_top_data_x),  //floating point num input
    .post_avail         (post_avail_flt2fxd_x),
    .post_get           (post_get_flt2fxd_x),
    .post_data          (post_data_flt2fxd_x)  //fixed point num output
  );
  
  //x -> x2 calculation
  multiplier #(
    .FXD_Q              (FXD_Q),
    .FXD_N              (FXD_N),
    .NUM_CYCLES_FOR_MULT(NUM_CYCLES_FOR_MULT)
  ) i_multiplier_preproc_x2 (
    //.clk                (clk),
    //.rst_n              (rst_n),
    .pre_avail_1        (post_avail_flt2fxd_x),
    .pre_get_1          (), 
    .pre_data_1         (post_data_flt2fxd_x),
    .pre_avail_2        (post_avail_flt2fxd_x),
    .pre_get_2          (), 
    .pre_data_2         (post_data_flt2fxd_x),
    .post_avail         (post_avail_mult_x2),
    .post_get           (post_get_mult_x2),
    .post_data          (post_data_mult_x2)
  );
  //register stage for x
  pipeline #(
    .FXD_N              (FXD_N)
  ) i_pipeline_preproc_x (
    .clk                (clk),
    .rst_n              (rst_n),
    .pre_avail          (post_avail_flt2fxd_x),
    .pre_get            (post_get_flt2fxd_x), 
    .pre_data           (post_data_flt2fxd_x),
    .post_avail         (post_avail_preproc_x),
    .post_get           (post_get_preproc_x),
    .post_data          (post_data_preproc_x)
  );
  //register stage for x2
  pipeline #(
    .FXD_N              (FXD_N)
  ) i_pipeline_preproc_x2 (
    .clk                (clk),
    .rst_n              (rst_n),
    .pre_avail          (post_avail_mult_x2),
    .pre_get            (post_get_mult_x2), 
    .pre_data           (post_data_mult_x2),
    .post_avail         (post_avail_preproc_x2),
    .post_get           (post_get_preproc_x2),
    .post_data          (post_data_preproc_x2)
  );
//------------------------------------------------------------------------------
//MCL pipeline
//------------------------------------------------------------------------------
  generate for (genvar gen_i = 0; gen_i < MCL_NUM_COEFFS-1; gen_i++) begin
    if(gen_i == 0) begin //first iteration connect to first element of coeff array
      assign pre_avail_mult_1  [gen_i] = PRE_AVAIL_COEFF_ARRAY;
      //pre_get_mult_1[0] is not used
      assign pre_data_mult_1   [gen_i] = MCL_COEFF_ARRAY    [gen_i];    //1/41!
      assign pre_avail_mult_2  [gen_i] = post_avail_preproc_x2;
      //pre_get_mult_2[0] is not used 
      assign pre_data_mult_2   [gen_i] = post_data_preproc_x2;
      assign pre_avail_add_1   [gen_i] = PRE_AVAIL_COEFF_ARRAY;
      //pre_get_add_1[0] is not used
      assign pre_data_add_1    [gen_i] = MCL_COEFF_ARRAY    [gen_i+1];  //-1/39!
      //post_avail_mul_add[0]
      assign post_get_mul_add  [gen_i] = pre_get_mult_1   [gen_i+1]; 
      //post_data_mul_add [0]
 
      assign pre_avail_x       [gen_i] = post_avail_preproc_x;
      assign post_get_preproc_x        = pre_get_mult_1     [gen_i];  //data is consumed based on movement in mul_add pipeline
      assign pre_data_x        [gen_i] = post_data_preproc_x;
      //post_avail_x[0]  
      assign post_get_x        [gen_i] = pre_get_mult_1     [gen_i+1];//data is consumed based on movement in mul_add pipeline
      //post_data_x[0]
  
      assign pre_avail_x2      [gen_i] = post_avail_preproc_x2;
      assign post_get_preproc_x2       = pre_get_mult_1     [gen_i];  //data is consumed based on movement in mul_add pipeline
      assign pre_data_x2       [gen_i] = post_data_preproc_x2;
      //post_avail_x2[0]
      assign post_get_x2       [gen_i] = pre_get_mult_1     [gen_i+1];//data is consumed based on movement in mul_add pipeline
      //post_data_x2[0] 
    end
    else if(gen_i == (MCL_NUM_COEFFS-2)) begin
      assign pre_avail_mult_1  [gen_i] = post_avail_mul_add [gen_i-1];
      //pre_get_mult_1
      assign pre_data_mult_1   [gen_i] = post_data_mul_add  [gen_i-1];
      assign pre_avail_mult_2  [gen_i] = post_avail_x2      [gen_i-1];
      //pre_get_mult_2
      assign pre_data_mult_2   [gen_i] = post_data_x2       [gen_i-1];
      assign pre_avail_add_1   [gen_i] = PRE_AVAIL_COEFF_ARRAY;
      //pre_get_add_1
      assign pre_data_add_1    [gen_i] = MCL_COEFF_ARRAY    [gen_i+1];
      //post_avail_mul_add
      assign post_get_mul_add  [gen_i] = post_fxd_pipe_bb_get;  //data is consumed based on movement in mul_add pipeline
      //post_data_mul_add

      assign pre_avail_x       [gen_i] = post_avail_x       [gen_i-1];
      //pre_get_x
      assign pre_data_x        [gen_i] = post_data_x        [gen_i-1];
      
      assign post_fxd_pipe_bb_x_avail  = post_avail_x       [gen_i];
      assign post_get_x        [gen_i] = post_fxd_pipe_bb_x_get;  //data is consumed based on movement in mul_add pipeline
      assign post_fxd_pipe_bb_x_data   = post_data_x        [gen_i];
  
      assign pre_avail_x2      [gen_i] = post_avail_x2      [gen_i-1];
      //pre_get_x2
      assign pre_data_x2       [gen_i] = post_data_x2       [gen_i-1];
      //post_avail_x2
      assign post_get_x2       [gen_i] = post_fxd_pipe_bb_x_get;  //data is consumed based on movement in mul_add pipeline
      //post_data_x2

      assign post_fxd_pipe_bb_avail    = post_avail_mul_add [gen_i];
      assign post_fxd_pipe_bb_data     = post_data_mul_add  [gen_i];
    end
    else begin
      assign pre_avail_mult_1  [gen_i] = post_avail_mul_add [gen_i-1];
      //pre_get_mult_1
      assign pre_data_mult_1   [gen_i] = post_data_mul_add  [gen_i-1];
      assign pre_avail_mult_2  [gen_i] = post_avail_x2      [gen_i-1];
      //pre_get_mult_2
      assign pre_data_mult_2   [gen_i] = post_data_x2       [gen_i-1];
      assign pre_avail_add_1   [gen_i] = PRE_AVAIL_COEFF_ARRAY;
      //pre_get_add_1
      assign pre_data_add_1    [gen_i] = MCL_COEFF_ARRAY    [gen_i+1];
      //post_avail_mul_add
      assign post_get_mul_add  [gen_i] = pre_get_mult_1     [gen_i+1]; 
      //post_data_mul_add
  
      assign pre_avail_x       [gen_i] = post_avail_x       [gen_i-1];
      //pre_get_x
      assign pre_data_x        [gen_i] = post_data_x        [gen_i-1];
      //post_avail_x  
      assign post_get_x        [gen_i] = pre_get_mult_1     [gen_i+1];  //data is consumed based on movement in mul_add pipeline
      //post_data_x
  
      assign pre_avail_x2      [gen_i] = post_avail_x2      [gen_i-1];
      //pre_get_x2
      assign pre_data_x2       [gen_i] = post_data_x2       [gen_i-1];
      //post_avail_x2
      assign post_get_x2       [gen_i] = pre_get_mult_1     [gen_i+1];  //data is consumed based on movement in mul_add pipeline
      //post_data_x2
    end
    //Generation of basic block for MCL
    mcl_fxd_pipe_basic_block #(
      .FXD_Q               (FXD_Q),
      .FXD_N               (FXD_N),
      .NUM_CYCLES_FOR_MULT (NUM_CYCLES_FOR_MULT),
      .NUM_CYCLES_FOR_ADD  (NUM_CYCLES_FOR_ADD)
    ) i_mcl_fxd_pipe_basic_block (
      .clk                 (clk),
      .rst_n               (rst_n),
      //mult add pipeline
      .pre_avail_mult_1    (pre_avail_mult_1  [gen_i]),
      .pre_get_mult_1      (pre_get_mult_1    [gen_i]),
      .pre_data_mult_1     (pre_data_mult_1   [gen_i]),
      .pre_avail_mult_2    (pre_avail_mult_2  [gen_i]),
      .pre_get_mult_2      (pre_get_mult_2    [gen_i]),
      .pre_data_mult_2     (pre_data_mult_2   [gen_i]),
      .pre_avail_add_1     (pre_avail_add_1   [gen_i]),
      .pre_get_add_1       (pre_get_add_1     [gen_i]),
      .pre_data_add_1      (pre_data_add_1    [gen_i]),
      .post_avail_mul_add  (post_avail_mul_add[gen_i]),
      .post_get_mul_add    (post_get_mul_add  [gen_i]),
      .post_data_mul_add   (post_data_mul_add [gen_i]),
      //x pipeline
      .pre_avail_pl_x      (pre_avail_x       [gen_i]),
      .pre_get_pl_x        (pre_get_x         [gen_i]),
      .pre_data_pl_x       (pre_data_x        [gen_i]),
      .post_avail_pl_x     (post_avail_x      [gen_i]),
      .post_get_pl_x       (post_get_x        [gen_i]),
      .post_data_pl_x      (post_data_x       [gen_i]),
      //x2 pipeline
      .pre_avail_pl_x2     (pre_avail_x2      [gen_i]),
      .pre_get_pl_x2       (pre_get_x2        [gen_i]),
      .pre_data_pl_x2      (pre_data_x2       [gen_i]),
      .post_avail_pl_x2    (post_avail_x2     [gen_i]),
      .post_get_pl_x2      (post_get_x2       [gen_i]),
      .post_data_pl_x2     (post_data_x2      [gen_i])
    );
  
  end
  endgenerate
//------------------------------------------------------------------------------
// Post-processing part - multiplication of MCL result with x for sine and
// fixed to float conversion
//------------------------------------------------------------------------------
  //multiplication of MCL result with x for sine
  multiplier #(
    .FXD_Q              (FXD_Q),
    .FXD_N              (FXD_N),
    .NUM_CYCLES_FOR_MULT(NUM_CYCLES_FOR_MULT)
  ) i_multiplier_postproc (
    //.clk                (clk),
    //.rst_n              (rst_n),
    .pre_avail_1        (post_fxd_pipe_bb_avail),
    .pre_get_1          (post_fxd_pipe_bb_get), 
    .pre_data_1         (post_fxd_pipe_bb_data),
    .pre_avail_2        (post_fxd_pipe_bb_x_avail),
    .pre_get_2          (post_fxd_pipe_bb_x_get), 
    .pre_data_2         (post_fxd_pipe_bb_x_data),
    .post_avail         (post_avail_mult_postproc),
    .post_get           (post_get_mult_postproc),
    .post_data          (post_data_mult_postproc)
  );

  fixed_to_float #(
    .FLT_EXP            (FLT_EXP),
    .FLT_FRAC           (FLT_FRAC),
    .FXD_N              (FXD_N),
    .FXD_Q              (FXD_Q)
  ) i_fixed_to_float (
    .pre_avail          (post_avail_mult_postproc),
    .pre_get            (post_get_mult_postproc),
    .pre_data           (post_data_mult_postproc),  //fixed point num input
    .post_avail         (post_mcl_top_avail),
    .post_get           (post_mcl_top_get),
    .post_data          (post_mcl_top_data)  //floating point num output
  );

endmodule 
