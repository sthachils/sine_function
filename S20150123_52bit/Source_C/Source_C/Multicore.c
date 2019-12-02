#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define FXD_N 16
#define FXD_Q 14

#define FACT_7 0x8003
#define FACT_6 0x8017
#define FACT_5 0x0089
#define FACT_4 0x02AB
#define FACT_3 0x8AAB
#define FACT_2 0xA000
#define FACT_1 0x4000

unsigned short x = 0x5FFF, x2 = 0;
unsigned short y_sin_1, y_sin_2;
unsigned short y_cos_1, y_cos_2;

void core_c0 ();
void core_c1 ();
void core_c2 ();
void core_c3 ();
void core_c4 ();
unsigned short fxd_mul (unsigned short pre_data_1, unsigned short pre_data_2);
unsigned short fxd_add (unsigned short pre_data_1, unsigned short pre_data_2);

void main() {
  //gen x, x2
  core_c0 ();
  //sine 1
  core_c1 ();
  //cos 1
  core_c3 ();
  //gen x, x2
  core_c0 ();
  //sine 1
  core_c2 ();
  //cos 1
  core_c4 ();
  getch();
}
//generate x,x2
void core_c0 () {
  unsigned counter = x;
  unsigned step    = 1;
  x  = counter+step;
  //read step
  x2 = fxd_mul (x, x);
  printf("  x:%04x  x2:%04x",x,x2);
}
//Sine 1
void core_c1 () {
   unsigned short tmp_1, tmp_2, tmp_3, tmp_4, tmp_5, tmp_6;
   tmp_1   = fxd_mul (FACT_7, x2);  tmp_2 = fxd_add (tmp_1, FACT_5);
   tmp_3   = fxd_mul (tmp_2 , x2);  tmp_4 = fxd_add (tmp_3, FACT_3);
   tmp_5   = fxd_mul (tmp_4 , x2);  tmp_6 = fxd_add (tmp_5, FACT_1);
   y_sin_1 = fxd_mul (tmp_6 , x);
   printf("  sine:%04x",y_sin_1);
}
//Sine 2
void core_c2 () {
   unsigned short tmp_1, tmp_2, tmp_3, tmp_4, tmp_5, tmp_6;
   tmp_1   = fxd_mul (FACT_7, x2);  tmp_2 = fxd_add (tmp_1, FACT_5);
   tmp_3   = fxd_mul (tmp_2 , x2);  tmp_4 = fxd_add (tmp_3, FACT_3);
   tmp_5   = fxd_mul (tmp_4 , x2);  tmp_6 = fxd_add (tmp_5, FACT_1);
   y_sin_2 = fxd_mul (tmp_6 , x);
   printf("  sine:%04x",y_sin_2);
}
//Cos 1
void core_c3 () {
   unsigned short tmp_1, tmp_2, tmp_3, tmp_4, tmp_5, tmp_6;
   tmp_1   = fxd_mul (FACT_6, x2);  tmp_2 = fxd_add (tmp_1, FACT_4);
   tmp_3   = fxd_mul (tmp_2 , x2);  tmp_4 = fxd_add (tmp_3, FACT_2);
   tmp_5   = fxd_mul (tmp_4 , x2);  tmp_6 = fxd_add (tmp_5, FACT_1);
   y_cos_1 = tmp_6;
   printf("  cos :%04x",y_cos_1);
}
//Cos 2
void core_c4 () {
   unsigned short tmp_1, tmp_2, tmp_3, tmp_4, tmp_5, tmp_6;
   tmp_1   = fxd_mul (FACT_6, x2);  tmp_2 = fxd_add (tmp_1, FACT_4);
   tmp_3   = fxd_mul (tmp_2 , x2);  tmp_4 = fxd_add (tmp_3, FACT_2);
   tmp_5   = fxd_mul (tmp_4 , x2);  tmp_6 = fxd_add (tmp_5, FACT_1);
   y_cos_2 = tmp_6;
   printf("  cos :%04x\n",y_cos_1);
}

unsigned short fxd_mul (unsigned short pre_data_1, unsigned short pre_data_2) {
  unsigned char  pre_data_1_sign, pre_data_2_sign, post_data_sign;
  unsigned long  pre_data_1_tmp,  pre_data_2_tmp;
  unsigned long  post_data_tmp_1, post_data_tmp_2;
  unsigned short post_data;
  //
  pre_data_1_sign = ((pre_data_1 & 0x8000) == 0x8000);
  pre_data_2_sign = ((pre_data_2 & 0x8000) == 0x8000);
  pre_data_1_tmp  = pre_data_1 & 0x7FFF;
  pre_data_2_tmp  = pre_data_2 & 0x7FFF;
  post_data_tmp_1 = pre_data_1_tmp * pre_data_2_tmp;
  post_data_sign  = (pre_data_1_sign != pre_data_2_sign);
  post_data_tmp_2 = (post_data_sign ? ((post_data_tmp_1 >> 14) | 0x8000) : ((post_data_tmp_1 >> 14) & 0x7FFF));
  post_data       = (unsigned short) post_data_tmp_2;
  //printf("mul: %04x char:%d short:%d int:%d long:%d\n",post_data,sizeof(char), sizeof(short), sizeof(int),sizeof(long long));
  return post_data;
}

unsigned short fxd_add (unsigned short pre_data_1, unsigned short pre_data_2) {
  //format 1 sign bit, 1 integer bit, 14 fractional bits
  unsigned char  pre_data_1_sign, pre_data_2_sign, post_data_sign;
  unsigned short pre_data_1_tmp,  pre_data_2_tmp,  post_data_tmp;
  unsigned short post_data;

  pre_data_1_sign = ((pre_data_1 & 0x8000) == 0x8000);
  pre_data_2_sign = ((pre_data_2 & 0x8000) == 0x8000);
  pre_data_1_tmp  = pre_data_1 & 0x7FFF;
  pre_data_2_tmp  = pre_data_2 & 0x7FFF;
  //
  if(!pre_data_1_sign && !pre_data_2_sign) {  //+ and +
    post_data_sign          = 0;
    post_data_tmp           = pre_data_1_tmp + pre_data_2_tmp;
  }
  else if(pre_data_1_sign && pre_data_2_sign) {  //- and -
    post_data_sign          = 1;
    post_data_tmp           = pre_data_1_tmp + pre_data_2_tmp;
  }
  else {  //+ and -
    if (pre_data_1_tmp > pre_data_2_tmp) {  //a > b
      post_data_sign        = pre_data_1_sign;
      post_data_tmp         = pre_data_1_tmp - pre_data_2_tmp;
    }
    else {
      post_data_sign        = pre_data_2_sign;
      post_data_tmp         = pre_data_2_tmp - pre_data_1_tmp;
    }
  }
  post_data = post_data_sign ? ((post_data_tmp & 0x7FFF) | 0x8000) : (post_data_tmp  & 0x7FFF);

  //printf("add: %04x\n",post_data);
  return post_data;
}
