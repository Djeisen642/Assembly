#include <stdlib.h>
#include <stdio.h>

void dataout(unsigned short bin_num) {
    char print_num[6];
    char sign_bit = bin_num >> 15;
    if (!sign_bit) print_num[0] = '+';
    else {
        print_num[0] = '-';
        bin_num = ~bin_num;
        bin_num ++;
    }
    char check = 0;
    unsigned char hold = 0;
    short div = 10000;
    int i = 1;
    while (div > 0) {
        hold = bin_num/div;
        bin_num = bin_num%div;
        if (hold != 0) check = 1;
        if (check) {
            print_num[i] = hold + 48;
            i++;
        }
        div = div/10;
    }
    if (!check) {
        print_num[1] = '0';
        i = 2;
    }
    if (i != 5) print_num[i] = '$';
    i = 0;
    while (print_num[i] != '$') {
        printf("%c", print_num[i]);
        i++;
    }
    printf("\n");
}

int main() {
    dataout(0x0000);
    dataout(0x8000);
    dataout(0x7FFF);
    dataout(0xAAAA);
    dataout(0x5555);
    dataout(0x01A3);
    dataout(0x4CF3);
    dataout(0xFCBB);
}


//+0 
//-32768
//+32767
//-21846
//+21845
//+419
//+19699
//-837

//+0
//-32768
//+32767
//-21846
//+21845
//+419
//+19699
//-837

//+00000
//-32768
//+32767
//-21846
//+21845
//+00419
//+19699
//-00837
