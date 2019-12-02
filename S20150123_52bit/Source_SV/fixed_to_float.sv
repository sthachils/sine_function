module fixed_to_float #(
  parameter FLT_EXP       = 11,
  parameter FLT_FRAC      = 52,
  parameter FXD_N         = 1,
  parameter FXD_Q         = 1
) (
  input  logic                          pre_avail,
  output logic                          pre_get,
  input  logic [FXD_N-1:0]              pre_data,  //fixed point num input
  output logic                          post_avail,
  input  logic                          post_get,
  output logic [FLT_EXP+FLT_FRAC:0]     post_data  //floating point num output
);

localparam SHIFT_WIDTH = 6;
localparam BIAS = (2 ** (FLT_EXP-1)) - 1;

logic [SHIFT_WIDTH-1:0] shift;
logic [SHIFT_WIDTH-1:0] shift_tmp;
logic                   fxd_sign;
logic                   flt_sign;
logic [FLT_EXP-1:0]     flt_exp;
logic [FLT_FRAC-1:0]    flt_frac;
logic [FXD_N-2:0]       fxd_num_tmp;
logic [FXD_N-2:0]       flt_num_tmp;
logic                   shift_ge_0;

assign fxd_sign    = pre_data[FXD_N-1];
assign fxd_num_tmp = pre_data[(FXD_N-2):0];
assign shift_ge_0  = |pre_data[(FXD_N-2):FXD_Q];
//TODO: Optimze the logic for XXXX by replacing with LNZ
always_comb begin
  for(int i = 0; i < (FXD_N-2); i++) begin
    if(fxd_num_tmp[i] == 1'b1) begin
      shift_tmp = FXD_N-2-i;
    end
  end
end

assign flt_num_tmp = fxd_num_tmp << shift_tmp;
assign shift = shift_ge_0 ? FXD_N-FXD_Q-2-shift_tmp : shift_tmp-(FXD_N-FXD_Q-2);

assign flt_sign = fxd_sign;
assign flt_exp  = shift_ge_0 ? BIAS + shift : BIAS - shift;
assign flt_frac = flt_num_tmp[FXD_N-3:FXD_N-3-FLT_FRAC+1] + flt_num_tmp[FXD_N-3-FLT_FRAC];  //Selecting bits and Rounding (second term)

assign post_data  = |pre_data ? {flt_sign,flt_exp,flt_frac} : {FLT_EXP+FLT_FRAC+1{1'b0}};
assign post_avail = pre_avail;
assign pre_get    = post_get;

endmodule

//TODO: check special cases of floating point number NAN, 0, +-INFs
//TODO: Optimze the logic for XXXX by replacing with LNZ