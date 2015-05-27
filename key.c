#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

int main() {
    char input = 0;
    while (input != '.') {
        input = getchar();
        if (isspace(input)) {
            printf("%c", input);
        } else if (isalpha(input)) {
            if (islower(input)) {
                printf("%c", toupper(input));
            } else {
                printf("%c", input);
            }
        } else if (input == '.') {
            printf(".\n");
        }
    }
}