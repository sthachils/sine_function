MCLOutSinFilename = "MCLOutGold.dat"
SVInpXFilename    = "SVInpX_Exp.dat"
SVOutFilename     = "SVOut_Exp.dat"
NumSamples        = 1024
PRECISION         = 54

hMCLOutSin = OpenWrite[MCLOutSinFilename]  (* Open file to write output sine value *)

(* Procedure for generating output sine value *)
ProcOutSin[i_] := { tmp = ToCharacterCode[ExportString[Sin[i], "Real64"]]; 
                    BaseForm[tmp[[1]] * 2^0  + tmp[[2]] * 2^8  + tmp[[3]] * 2^16 + tmp[[4]] * 2^24 + 
                             tmp[[5]] * 2^32 + tmp[[6]] * 2^40 + tmp[[7]] * 2^48 + tmp[[8]] * 2^56, 16] }

SVOutL  = SetPrecision[Import[SVOutFilename,"List"],PRECISION]   (*Get the full decimal digits upto 54 points *)
SVInpXL = SetPrecision[Import[SVInpXFilename,"List"],PRECISION]  (*Get the full decimal digits upto 54 points *)
Do[WriteString[hMCLOutSin, ToString[ProcOutSin[SVInpXL[[i]]]], "\n"],{i, 1, NumSamples, 1}]
Close[hMCLOutSin]

MCLOutL = Table[Sin[SVInpXL[[i]]], {i, 1, NumSamples}]
MCLSVDiffL = SVOutL - MCLOutL
ListLinePlot[MCLSVDiffL, PlotRange -> Full,ImageSize -> Large]
