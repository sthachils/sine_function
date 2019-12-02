Implementation of 16 decimal point accurate Sine function with McLaurin Expansion. 

Input is angle in radians specified in IEEE 754 double-precision binary floating-point format.
Ouput is the sine value specified in IEEE 754 double-precision binary floating-point format.

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



Note: This code was done with inspiration from Johhny Öberg, KTH in Jan 2015. https://people.kth.se/~johnnyob/
