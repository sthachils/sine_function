WorkDir           = "C:\KTH\MSim\S20150123_52bit\Sim_Data"
MCLCoeffFilename  = "MCLCoeff.dat"
MCLInpXFilename   = "MCLInpX.dat"
(* MCLInpX2Filename  = "MCLInpX2.dat" *)

MCLNumCoeff       = 12
NumSamples        = 1024
SmallestAngle     = N[(2^-52),50]                     (* Pi / NumSamples *)
StartAngle        = 1.57079632679489655799898173427 (* Pi / 2 *)


Directory[]           (* Present Directory                *)
SetDirectory[WorkDir] (* Change to desired work directory *)
Directory[]           (* Confirm change in work directory *)

(* Procedure for generating the coeff *)
ProcCoeffHex[i_] := BaseForm[N[(1/Factorial[i]), 40], 16]

(* Generate the coefficients in hex format *) 
(* EDIT THE OUPUT FOR SIGN AND BITWIDTH BEFORE RUNNING SIMULATION *)
(* hMCLCoeff = OpenWrite[MCLCoeffFilename] *) (* Open file to write the coeffs *)
(* Do[WriteString[hMCLCoeff, ToString[ProcCoeffHex[2*(MCLNumCoeff-i)-1]], "\n"],{i, 0, MCLNumCoeff - 1, 1}] *)
(* Close[hMCLCoeff] *)


(* Procedure for generating input x, input x2*)
ProcInpX  [i_] := { tmp = ToCharacterCode[ExportString[i, "Real64"]]; 
                    BaseForm[tmp[[1]] * 2^0  + tmp[[2]] * 2^8  + tmp[[3]] * 2^16 + tmp[[4]] * 2^24 + 
                             tmp[[5]] * 2^32 + tmp[[6]] * 2^40 + tmp[[7]] * 2^48 + tmp[[8]] * 2^56, 16] }
(* ProcInpX2 [i_] := BaseForm[N[i*i,    40], 16] *)

hMCLInpX   = OpenWrite[MCLInpXFilename  ]       (* Open file to write input x *)
(* hMCLInpX2  = OpenWrite[MCLInpX2Filename ] *) (* Open file to write input x2 *) 


Do[WriteString[hMCLInpX,   ToString[ProcInpX  [StartAngle - (i*SmallestAngle)]], "\n"],{i, 0, NumSamples - 1, 1}]
(* Do[WriteString[hMCLInpX2,  ToString[ProcInpX2 [StartAngle - (i*SmallestAngle)]], "\n"],{i, 0, NumSamples - 1, 1}] *)


Close[hMCLInpX]
(* Close[hMCLInpX2]  *)
