module float_to_fixed #(
  parameter FLT_EXP     = 11,
  parameter FLT_FRAC    = 52,
  parameter FXD_N       = 1,
  parameter FXD_Q       = 1
) (
  input  logic                          pre_avail,
  output logic                          pre_get,
  input  logic [FLT_EXP+FLT_FRAC:0]     pre_data,  //floating point num input
  output logic                          post_avail,
  input  logic                          post_get,
  output logic [FXD_N-1:0]              post_data  //fixed point num output
);

  localparam BIAS = (2 ** (FLT_EXP-1)) - 1;
  localparam SHIFT_WITDH = 6;  // Assuming max shift is 64 

  logic                         flt_sign;
  logic [FLT_EXP-1:0]           flt_exp;
  logic [FLT_FRAC:0]            flt_1_point_frac;
  logic [FXD_N-2:0]             fxd_num_tmp;
  logic [SHIFT_WITDH-1:0]       shift;
  logic                         exp_ge_bias;

  assign flt_sign         = pre_data[FLT_EXP+FLT_FRAC];
  assign flt_exp          = pre_data[(FLT_EXP+FLT_FRAC)-1:FLT_FRAC];
  assign flt_1_point_frac = {1'b1,pre_data[FLT_FRAC-1:0]};
  
  //to save gates by operating on lesser width
  always_comb begin
    if(flt_exp >= BIAS) begin
      shift = flt_exp - BIAS;
      exp_ge_bias = 1'b1;
    end
    else begin
      shift = BIAS - flt_exp;
      exp_ge_bias = 1'b0;
    end
  end
  //align the data to get the fixed point
  always_comb begin
    if(exp_ge_bias) begin
      fxd_num_tmp = ({{(FXD_N-FXD_Q-1){1'b0}},flt_1_point_frac} << (FXD_Q - FLT_FRAC)) << shift;
    end
    else begin
      fxd_num_tmp = ({{(FXD_N-FXD_Q-1){1'b0}},flt_1_point_frac} << (FXD_Q - FLT_FRAC)) >> shift;
    end
  end

  assign post_data  = |pre_data ? {flt_sign,fxd_num_tmp} : {FXD_N{1'b0}};  //IEEE 754 bits all 0 => Zero not 1.000
  assign post_avail = pre_avail;
  assign pre_get    = post_avail;

endmodule

//TODO: if exp is > BIAS + FIXED_INTEGER then indicate ERROR
//TODO: check special cases of floating point number NAN, 0, +-INFs


