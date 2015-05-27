//-------------------------------------------------------------------
//  DATAIN ALGORITHM - DOES NOT HANDLE LEADING OR TRAILING SPACES
//-------------------------------------------------------------------

#include <stdio.h>

// datain returns a return code in ax and a value in dx

int datain(int *dx)

{
const int TRUE=1;
int       ch;                // The ASCII character read
unsigned  sum;               // The value of the converted number
int       sign;              // 0=no sign   1=+ sign   -1=- sign
int       retcode;           // 0=no error  1=error     2=end of file
int       signcheck, startnum, endnum;

// Initialize the return code and sum and sign
retcode = sum = sign = signcheck = startnum = endnum =  0;

// Process one complete line of input data before returning
while (TRUE)
   {
   // Read a character. If eof return, else echo and continue
   ch = getchar();
   if (ch == EOF) {retcode = 2; return (retcode);}
   putchar(ch);
   // If the character is EOL we are done converting
   if (ch == '\n') break;

   // If the character is a sign then record it
   if (!signcheck) {
        if (ch == '+') {sign = +1; signcheck ++; continue;}
        if (ch == '-') {sign = -1; signcheck ++; continue;}
    }
   // If the character is a digit then perform conversion
   if ((ch >= '0') && (ch <= '9')) {
        signcheck++;
        startnum++;
    }
    if (ch >= 0x20 && ch <= 0x177) {
        if (ch == ' ' && !startnum && !signcheck) ;
        else if ((ch >= '0') && (ch <= '9') && !endnum) {
            sum = sum*10 + ch - '0';
            if (sum > 0x7FFF && sign > -1) retcode = 1;
            if ((sum > 0x8000 && sum != 0) && sign == -1) retcode = 1;
        } else if (startnum && !endnum && ch == ' ') endnum = 1;
        else if (endnum) ;
        else {printf("^"); retcode = 1;}
        }
    }
printf("%d, %d, %d, %d \n", sum, startnum, signcheck, endnum);
if (sign == -1) sum = -sum;  // negate value if sign was minus
*dx = sum;                   // return the value in dx

// Return to the caller.
return (retcode);            // return the return code in ax
}


//-------------------------------------------------------------------
//  THIS IS A MAIN PROGRAM TO CALL DATAIN.
//-------------------------------------------------------------------

int  main()

{
const  int TRUE=1;
int    dx, ax;

// Call datain until it returns EOF
while (TRUE)
   {
   // Call datain
   printf("\nCalling datain \n");
   printf("Input line is ..... ");
   ax = datain(&dx);

   // Print the converted number
   if (ax == 0) printf("Datain returned ... ax=%04d and dx=%04hX\n",ax,dx);
   if (ax == 2) printf("\n");
   if (ax != 0) printf("Datain returned ... ax=%04d\n",ax);
   if (ax == 2) break;
   }
return(0);
}
