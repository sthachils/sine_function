module tb_mcl_fxd_pipe_sv_top ();

localparam CLK_PERIOD    = 5;
localparam RST_TIME_INIT = 12;

localparam MCL_NUM_COEFFS      = 12;
localparam FXD_Q               = 80;
localparam FXD_N               = 84;
localparam FLT_EXP             = 11;
localparam FLT_FRAC            = 52;
localparam NUM_SAMPLES         = 1024;
localparam NUM_CYCLES_FOR_MULT = 1;
localparam NUM_CYCLES_FOR_ADD  = 1;


localparam BIAS = (2 ** (FLT_EXP-1)) - 1;

logic                      clk;
logic                      rst_n;

logic                      tb_pre_avail;
logic                      tb_pre_get;
logic [FLT_EXP+FLT_FRAC:0] tb_pre_data;
logic                      tb_post_avail;
logic                      tb_post_get;
logic [FLT_EXP+FLT_FRAC:0] tb_post_data;
 
logic [FXD_N/2-1:0]        tb_lfsr_pre_avail;
logic [FXD_N/2-1:0]        tb_lfsr_post_get;

integer                    tb_index;
integer                    in_file_exp_h;
integer                    out_file_exp_h;
integer                    out_file_754_h;
integer                    sample_count;
const logic [FLT_EXP+FLT_FRAC:0] MCL_INPX_ARRAY  [0:NUM_SAMPLES-1]; 
//const logic [FXD_N-1:0] MCL_INPX2_ARRAY [0:NUM_SAMPLES-1]; 
//const logic [FXD_N-1:0] MCL_GOLD_ARRAY  [0:NUM_SAMPLES-1]; 
initial begin
  $readmemh("SVInpX.dat" ,MCL_INPX_ARRAY);
  //$readmemh("SVInpX2.dat",MCL_INPX2_ARRAY);
  //$readmemh("MCLOutSVFormat.dat",MCL_GOLD_ARRAY);
  in_file_exp_h   = $fopen("SVInpX_Exp.dat","w");
  out_file_exp_h  = $fopen("SVOut_Exp.dat","w");
  out_file_754_h  = $fopen("SVOut.dat","w");
end

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    sample_count <= 'd0;
  end
  else begin
    if(sample_count == NUM_SAMPLES) begin
      $fclose(in_file_exp_h);
      $fclose(out_file_exp_h);
      $fclose(out_file_754_h);
    end
    else if(tb_post_avail && tb_post_get) begin
      $fdisplayh(out_file_754_h,"%x",tb_post_data);
      $fdisplay(in_file_exp_h,"%1.16e",$bitstoreal(MCL_INPX_ARRAY[sample_count]));
      $fdisplay(out_file_exp_h,"%1.16e",$bitstoreal(tb_post_data));
      //if(sample_count != (NUM_SAMPLES-1)) begin 
      //  $fwrite(out_file_exp_h,","); 
      //  $fwrite(in_file_exp_h,",");
      //end
      sample_count <= sample_count + 'd1;
    end
  end
end

//LFSR for generating random test vectors
always_ff @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    tb_lfsr_pre_avail <= '0;
    tb_lfsr_post_get  <= '0;
  end
  else begin
    tb_lfsr_pre_avail <= {tb_lfsr_pre_avail[FXD_N-2:0],!(tb_lfsr_pre_avail[3]^tb_lfsr_pre_avail[1])};
    tb_lfsr_post_get  <= {tb_lfsr_post_get[FXD_N-2:0],!(tb_lfsr_post_get[3]^tb_lfsr_post_get[2])};
  end
end
//pre avail and post get
//always_comb begin
//  tb_pre_avail = ~tb_lfsr_pre_avail[0];
//  tb_post_get = ~tb_lfsr_post_get[0];
//end
always_ff @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    tb_pre_avail <= 1'b0;
    tb_post_get  <= 1'b0;
  end
  else begin
    tb_pre_avail <= 1'b1;
    tb_post_get  <= 1'b1;
  end
end

//inc
always_ff @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    tb_index <= '0;
  end
  else begin
    if(tb_pre_avail && tb_pre_get) begin
      tb_index <= tb_index + 'd1;
    end
  end
end

mcl_fxd_pipe_sv_top #(
  .MCL_NUM_COEFFS      (MCL_NUM_COEFFS),
  .FXD_Q               (FXD_Q),
  .FXD_N               (FXD_N),
  .FLT_EXP             (FLT_EXP),
  .FLT_FRAC            (FLT_FRAC),
  .NUM_CYCLES_FOR_MULT (NUM_CYCLES_FOR_MULT),
  .NUM_CYCLES_FOR_ADD  (NUM_CYCLES_FOR_ADD)
) i_mcl_fxd_pipe_sv_top (
  .clk                     (clk),
  .rst_n                   (rst_n),
  
  .pre_mcl_top_avail_x     (tb_pre_avail),
  .pre_mcl_top_get_x       (tb_pre_get),
  .pre_mcl_top_data_x      (MCL_INPX_ARRAY[tb_index]),

  //.pre_mcl_top_avail_x2    (tb_pre_avail),
  //.pre_mcl_top_get_x2      (),
  //.pre_mcl_top_data_x2     (MCL_INPX2_ARRAY[tb_index]),
                                 
  .post_mcl_top_avail      (tb_post_avail),
  .post_mcl_top_get        (tb_post_get),
  .post_mcl_top_data       (tb_post_data)
);

//Pi/2 in hex    Subscript[1.921fb54442d18469898cc51702, 16]
//Square Pi/2 is Subscript[2.77a79937c8bbcb495b89b36602, 16]

//rst_n
initial begin
  clk = 0;
  rst_n = 0;
  #(RST_TIME_INIT) rst_n = 1; 
end
  
//clk
always begin
  #(CLK_PERIOD) clk = ~clk;
end

endmodule: tb_mcl_fxd_pipe_sv_top