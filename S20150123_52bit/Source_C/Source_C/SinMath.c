#define NumSamples 1024

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

char char_to_hex(char a);

int main()
{
   union ieee754u {
      double x;
	  unsigned char xc[8];
   };
   union ieee754u xu, sin_xu;
   unsigned char xs[17];
   FILE * fp_InpX;
   FILE * fp_InpX_Exp;
   FILE * fp_Out;
   FILE * fp_Out_Exp;
   int i;

   fp_InpX     = fopen ("../../Sim_Data/SVInpX.dat", "r+");
   fp_InpX_Exp = fopen ("../../Sim_Data/CInpX_Exp.dat", "w+");
   fp_Out      = fopen ("../../Sim_Data/COut.dat", "w+");
   fp_Out_Exp  = fopen ("../../Sim_Data/COut_Exp.dat", "w+");
   for (i = 0; i < NumSamples; i++) {
      fscanf(fp_InpX, "%s", &xs);
      printf("String %s\n", xs);
      xu.xc[7] = (char_to_hex(xs[0])  << 4) + char_to_hex(xs[1]);
      xu.xc[6] = (char_to_hex(xs[2])  << 4) + char_to_hex(xs[3]);
      xu.xc[5] = (char_to_hex(xs[4])  << 4) + char_to_hex(xs[5]);
      xu.xc[4] = (char_to_hex(xs[6])  << 4) + char_to_hex(xs[7]);
      xu.xc[3] = (char_to_hex(xs[8])  << 4) + char_to_hex(xs[9]);
      xu.xc[2] = (char_to_hex(xs[10]) << 4) + char_to_hex(xs[11]);
      xu.xc[1] = (char_to_hex(xs[12]) << 4) + char_to_hex(xs[13]);
      xu.xc[0] = (char_to_hex(xs[14]) << 4) + char_to_hex(xs[15]);
      fprintf(fp_InpX_Exp,"%1.17lf\n",xu.x);
	  sin_xu.x = sin(xu.x);
	  fprintf(fp_Out_Exp,"%1.17lf\n",sin_xu.x);
	  fprintf(fp_Out,"%02x%02x%02x%02x%02x%02x%02x%02x\n",sin_xu.xc[7],sin_xu.xc[6],sin_xu.xc[5],sin_xu.xc[4],sin_xu.xc[3],sin_xu.xc[2],sin_xu.xc[1],sin_xu.xc[0]);
   }
   //printf("Sizeof char %d int %d long %d longlong %d float %d double %d union %d\n",sizeof(char),sizeof(int),sizeof(long),sizeof(long long), sizeof(float), sizeof(double), sizeof(xu) );
   fclose(fp_InpX);
   fclose(fp_InpX_Exp);
   fclose(fp_Out);
   fclose(fp_Out_Exp);

   getch();
   return(0);
}

char char_to_hex (char a) {
  if(a == '0') return 0;
  else if(a == '1') return 1;
  else if(a == '2') return 2;
  else if(a == '3') return 3;
  else if(a == '4') return 4;
  else if(a == '5') return 5;
  else if(a == '6') return 6;
  else if(a == '7') return 7;
  else if(a == '8') return 8;
  else if(a == '9') return 9;
  else if(a == 'a' || a == 'A') return 10;
  else if(a == 'b' || a == 'B') return 11;
  else if(a == 'c' || a == 'C') return 12;
  else if(a == 'd' || a == 'D') return 13;
  else if(a == 'e' || a == 'E') return 14;
  else if(a == 'f' || a == 'F') return 15;
  else printf("Unknown char");
}