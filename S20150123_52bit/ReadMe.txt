Steps

1) Run mathematica script generate coeffs and input 
   Command: Run << "Path"\Scripts\mtm_coeff_inp_gen.m
2) Edit MCL* input & coeff files for sign and bitwidth before running simulation
   Transform MCL_Coeff.dat -> SVCoeff.dat and MCLInpX.dat -> SVInpX.dat
3) Invoke ModelSim and run simulation from "Sim_Data" directory
   Command: vsim work.tb_mcl_fxd_pipe_sv_top
   Command: run 3500
   Command: quit -sim
4) Output is stored in SVOut.csv
