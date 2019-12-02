module tb_pipepline ();

parameter CLK_PERIOD    = 5;
parameter RST_TIME_INIT = 12;

parameter DATA_WIDTH    = 8;

logic                     clk;
logic                     rst_n;

logic                  tb_pre_avail;
logic                  tb_pre_get;
logic [DATA_WIDTH-1:0] tb_pre_data;
logic                  tb_post_avail;
logic                  tb_post_get;
logic [DATA_WIDTH-1:0] tb_post_data;

logic [DATA_WIDTH/2-1:0] tb_lfsr_pre_avail;
logic [DATA_WIDTH/2-1:0] tb_lfsr_post_get;
//LFSR for generating random test vectors
always_ff @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    tb_lfsr_pre_avail <= '0;
    tb_lfsr_post_get  <= '0;
  end
  else begin
    tb_lfsr_pre_avail <= {tb_lfsr_pre_avail[DATA_WIDTH-2:0],!(tb_lfsr_pre_avail[3]^tb_lfsr_pre_avail[1])};
    tb_lfsr_post_get <= {tb_lfsr_post_get[DATA_WIDTH-2:0],!(tb_lfsr_post_get[3]^tb_lfsr_post_get[2])};
  end
end
//pre avail and post get
always_comb begin
  tb_pre_avail = ~tb_lfsr_pre_avail[0];
  tb_post_get = ~tb_lfsr_post_get[0];
end
//pre data
always_ff @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    tb_pre_data <= '0;
  end
  else begin
    if(tb_pre_avail && tb_pre_get) begin
      tb_pre_data <= tb_pre_data + 'd1;
    end
  end
end

pipeline #(
  .DATA_WIDTH (DATA_WIDTH)
) i_pipeline (
  .clk        (clk),
  .rst_n      (rst_n),
  .pre_avail  (tb_pre_avail),
  .pre_get    (tb_pre_get), 
  .pre_data   (tb_pre_data),
  .post_avail (tb_post_avail),
  .post_get   (tb_post_get),
  .post_data  (tb_post_data)
);

//  parameter N
//  parameter Coeff_Array 
//  parameter S

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

endmodule: tb_pipepline