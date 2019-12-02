//-----------------------------------------------------------------------//
//post_data = pre_data_1 + pre_data_2
//adder will start only when both pre_avail_1 and pre_avail_2 are high
//there are no registers / pipeline stages in adder
//-----------------------------------------------------------------------//
module adder #(
  parameter FXD_Q                = 4,
  parameter FXD_N                = 8,
  parameter NUM_CYCLES_FOR_ADD   = 1
) (
  //input  logic                   clk,
  //input  logic                   rst_n,
  input  logic                  pre_avail_1,
  output logic                  pre_get_1, 
  input  logic [FXD_N-1:0]      pre_data_1,
  input  logic                  pre_avail_2,
  output logic                  pre_get_2, 
  input  logic [FXD_N-1:0]      pre_data_2,
  output logic                  post_avail,
  input  logic                  post_get,
  output logic [FXD_N-1:0]      post_data
);

  generate if(NUM_CYCLES_FOR_ADD == 1) begin
    logic [FXD_N-1:0]           post_data_tmp;
    logic                       post_data_sign;
    logic                       pre_data_1_sign;
    logic                       pre_data_2_sign;
    logic [FXD_N-2:0]           pre_data_1_tmp;
    logic [FXD_N-2:0]           pre_data_2_tmp;
 
    assign post_avail           = pre_avail_1 && pre_avail_2;
    assign pre_get_1            = post_get;
    assign pre_get_2            = post_get;
    
    //assign post_data_tmp = pre_data_1 + pre_data_2;
    //assign post_data = post_data_tmp[FXD_N-1:0];
    assign pre_data_1_sign      = pre_data_1[FXD_N-1];
    assign pre_data_1_tmp       = pre_data_1[FXD_N-2:0];
    assign pre_data_2_sign      = pre_data_2[FXD_N-1];
    assign pre_data_2_tmp       = pre_data_2[FXD_N-2:0];
    assign post_data[FXD_N-1]   = post_data_sign;
    assign post_data[FXD_N-2:0] = post_data_tmp[FXD_N-2:0];
    
    always_comb begin
      if(!pre_data_1_sign && !pre_data_2_sign) begin  //+ and +
        post_data_sign          = 1'b0;
        post_data_tmp           = pre_data_1_tmp + pre_data_2_tmp;
      end
      else if(pre_data_1_sign && pre_data_2_sign) begin  //- and -
        post_data_sign          = 1'b1;
        post_data_tmp           = pre_data_1_tmp + pre_data_2_tmp;
      end
      else begin  //+ and -
        if (pre_data_1[FXD_N-1-1:0] > pre_data_2[FXD_N-1-1:0]) begin  //a > b
          post_data_sign        = pre_data_1_sign;
          post_data_tmp         = pre_data_1_tmp - pre_data_2_tmp;
        end
        else begin
          post_data_sign        = pre_data_2_sign;
          post_data_tmp         = pre_data_2_tmp - pre_data_1_tmp;
        end
      end
    end
    
    //pre_data_1, pre_data_2 and the result is converted to the same fixed point format
    //qadd #(
    //  .Q                 (FXD_Q),
    //  .N                 (FXD_N)
    //) i_qadd (
    //  .a                 (pre_data_1),
    //  .b                 (pre_data_2),
    //  .c                 (post_data)
    //);

  end
  endgenerate

endmodule 