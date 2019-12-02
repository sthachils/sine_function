module pipeline #(
  parameter FXD_N = 32
) (
  input  logic                   clk,
  input  logic                   rst_n,
  input  logic                   pre_avail,
  output logic                   pre_get, 
  input  logic [FXD_N-1:0]       pre_data,
  output logic                   post_avail,
  input  logic                   post_get,
  output logic [FXD_N-1:0]       post_data
);

typedef enum logic[1:0] {PL_IDLE_ST = 2'b00,PL_EMPTY_ST = 2'b01,PL_FULL_ST = 2'b10} pl_state_typ;
pl_state_typ     pl_state_ps, pl_state_ns;

//state machine
always_ff @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    pl_state_ps <= PL_IDLE_ST;
  end
  else begin
    pl_state_ps <= pl_state_ns;
  end
end
//state machine
always_comb begin
  //default statements
  pl_state_ns = pl_state_ps;
  post_avail = 1'b0;
  pre_get = post_get;
  //case statement
  case(pl_state_ps)
    PL_IDLE_ST: begin
      post_avail = 1'b0;
      pre_get = 1'b0;
      pl_state_ns = PL_EMPTY_ST;
    end
    PL_EMPTY_ST: begin
      pre_get = 1'b1;
      post_avail = 1'b0;
      if(pre_avail) begin
        pl_state_ns = PL_FULL_ST;
      end
    end
    PL_FULL_ST: begin
      post_avail = 1'b1;
      pre_get = post_get;
      if(post_get && !pre_avail) begin
        pl_state_ns = PL_EMPTY_ST;
      end
    end
    //default: begin
    //end
  endcase
end
//post data
always_ff @ (posedge clk) begin
  if(pre_avail && pre_get) begin
    post_data <= pre_data;
  end
end

endmodule 