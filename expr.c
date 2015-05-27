#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

int main() {
    char c;
    FILE * input = fopen("SAMPLE.IN", "r");
    FILE * output = fopen("SAMPLE.OUT", "w");
    int state = 0;
    int check = 0;
    int error = 0;
    int operand = 0;
    do {
        
        do {
            c = fgetc(input);
            if (c == -1) fclose(output); //if it's the end of the file
            else fputc(c, output); //otherwise print it
            if ((c > 31 && c < 127) && error == 0) {
                switch (state) {
                    case 0:
                        if ( c != ' ' && !isupper(c) && check == 0) {
                            error = 2; //first character is not a space or upper
                        } else {
                            if (c == ' ' && check == 0) ; //character is space and before upper
                            else if (isupper(c)) { //is upper
                                check = 1; //Variable is started
                                operand = 0; //operand is checks the term
                            } else if (c == ' ' && check == 1) //character is space after upper
                                state = 1;  
                            else error = 1; //not upper or space
                        }
                        break;
                    case 1:
                            if (c == ' ' && check == 1) ; //space after upper
                            else if (c == '+' || c == '-' || c == '=') { //operator
                                check = 0; //
                                operand = 1; //operand is not the last term
                                c = fgetc(input); //get the next character to see if it's a space
                                if (c != ' ') error = 2; //if it's not then there is a format error
                                else state = 0; //if there is then change state
                                ungetc(c, input); //put the character back
                            }
                            else error = 2; //not space or character
                        break;
                }
            }
        
        } while (c != '\n' && c != EOF);
        if (error == 0) fputs("LINE IS VALID\n\n", output); //no error
        if (error == 1) fputs("INVALID VARIABLE\n\n", output); //invalid variable
        if (error == 2 || operand != 0) fputs("INVALID FORMAT\n\n", output); //invalid format (didn't end on operand)
        error = 0;
        state = 0;
        check = 0;
        operand = 0;
    } while (c!= EOF);
    fclose(input);
}