;---------------------------------------
;  Program: DATAOUT
;
;  Function:
;
;  The dataout subroutine will convert the signed binary number passed to
;  it in ax into this ASCII format and write it to the standard output.
;
;  Output format is:  SNN...
;
;  S      The sign of the number.  It must be a + or - sign.
;  NN...  These are the ASCII digits that make up the number.
;
;  Formatting notes:
;  - Suppress leading zeroes.
;  - There are no blanks/spaces between the sign and the digits.
;  - There are no commas.
;  Nothing else is written to the standard output device.
;
;  Input to dataout:
;  ax = The two's complement signed number to be converted to ASCII.
;
;  All registers are restored to their original value when dataout returns.
;
;  Owner:   Jason Suttles
;
;  Changes:
;  Date          Reason
;  10/4/12       Original
;  10/6/12       Efficiency
;
;---------------------------------------
         .model    small
         .8086
         public    dataout
;---------------------------------------
         .data                          ; start the data segment
;---------------------------------------
ten     dw      10                      ; number used to divide ax
store   dw      ?                       ; stores ax when ax is needed
zero    db      '+', '0', '$'           ; writes +0 when 0
five    db      ?                       ; ten thousands
four    db      ?                       ; thousands
three   db      ?                       ; hundreds
two     db      ?                       ; tens
one     db      ?                       ; ones
term    db      '$'                     ; line terminate
;---------------------------------------
         .code                          ; start the code segment
;---------------------------------------
dataout:                                ;
        push    dx                      ; store dx on stack
        push    ax                      ; store ax on stack
        mov     dx, @data               ; establish addressability to the
        mov     ds, dx                  ; data segment for this program
;---------------------------------------
;   is it zero?
;    if (ax == 0) 
;        printf("+0");
;---------------------------------------
        cmp     ax, 0                   ; it is 0?
        jg      plus                    ; it's more, it's positive
        jl      minus                   ; it's less, it's negative
        mov     dx, offset zero         ; zero is always positive
        mov     ah, 9                   ; code to write a character
        int     21h                     ; write the character
        jmp     exit                    ; jump to exit
;---------------------------------------
;   Write sign character
;    if (ax < 0x8000) printf("+");
;        else {
;            printf("-");
;            ax = ~ax;
;            ax ++;
;        }
;--------------------------------------- 
plus:                                   ; if it's positive
        mov     dl, '+'                 ; set + to print
        jmp     printsign               ; jump to number
minus:                                  ; if it's negative
        mov     dl, '-'                 ; set - to print
        not     ax                      ; one's complement
        inc     ax                      ; add 1 to make it 2's complement
printsign:                              ; print sign
        mov     store, ax               ; store ax in store
        mov     ah, 2                   ; code to write a character
        int     21h                     ; write the character
        mov     ax, store               ; restore ax
;---------------------------------------
;   Process digits
;    do {
;        dx = ax%10;
;        ax = ax/10;
;        stack[si] = dx + 0x30;
;        si++;
;    } while (ax > 0);
;   This implementation removes the loop and writes it out.
;---------------------------------------
number:                                 ; divides and checks
        mov     dx, 0                   ; reset dx to 0
        div     ten                     ; divide
        add     dl, 30h                 ; change digits into ascii characters
        mov     one, dl                 ; push character onto the stack
        cmp     ax, 0                   ; is ax 0 yet?
        je      printone                ; yes, print a digit
;---------------------------------------
;   vvv There are two or more digits. vvv
;---------------------------------------
        mov     dx, 0                   ; reset dx to 0
        div     ten                     ; divide
        add     dl, 30h                 ; change digits into ascii characters
        mov     two, dl                 ; push character onto the stack
        cmp     ax, 0                   ; is ax 0 yet?
        je      printtwo                ; yes, print two digits
;---------------------------------------
;   vvv There are three or more digits. vvv
;---------------------------------------
        mov     dx, 0                   ; reset dx to 0
        div     ten                     ; divide
        add     dl, 30h                 ; change digits into ascii characters
        mov     three, dl               ; push character onto the stack
        cmp     ax, 0                   ; is ax 0 yet?
        je      printthree              ; yes, print three digits
;---------------------------------------
;   vvv There are four or more digits. vvv
;---------------------------------------
        mov     dx, 0                   ; reset dx to 0
        div     ten                     ; divide
        add     dl, 30h                 ; change digits into ascii characters
        mov     four, dl                ; push character onto the stack
        cmp     ax, 0                   ; is ax 0 yet?
        je      printfour               ; yes, print four digits
;---------------------------------------
;   vvv There are five digits. vvv
;---------------------------------------
        mov     dx, 0                   ; reset dx to 0
        div     ten                     ; divide
        add     dl, 30h                 ; change digits into ascii characters
        mov     five, dl                ; push character onto the stack
;---------------------------------------
;   Print the ASCII digits
;    do{
;        si--;
;        printf("%c", stack[si]);
;        stack[si] = '0';
;    } while (si != 0);
;   This implementation removes the loop.
;---------------------------------------
printfive:                              ; print five characters
        mov     dx, offset five         ; point to five
        mov     ah, 9                   ; code to write a line
        int     21h                     ; write the string
        jmp     exit                    ; jump to exit
;---------------------------------------
;   vvv There were two digits. vvv
;---------------------------------------
printone:                               ; print one character
        mov     dx, offset one          ; point to one
        mov     ah, 9                   ; code to write a line
        int     21h                     ; write the string
        jmp     exit                    ; jump to exit
;---------------------------------------
;   vvv There were three digits. vvv
;---------------------------------------
printtwo:                               ; print two characters
        mov     dx, offset two          ; point to two
        mov     ah, 9                   ; code to write a line
        int     21h                     ; write the string
        jmp     exit                    ; jump to exit
;---------------------------------------
;   vvv There were four digits. vvv
;---------------------------------------
printthree:                             ; print three characters
        mov     dx, offset three        ; point to three
        mov     ah, 9                   ; code to write a line 
        int     21h                     ; write the string
        jmp     exit                    ; jump to exit
;---------------------------------------
;   vvv There were five digits. vvv
;---------------------------------------
printfour:                              ; print four characters
        mov     dx, offset four         ; write the string
        mov     ah, 9                   ; code to write a line
        int     21h                     ; write the string
;---------------------------------------
;   terminate subroutine execution
;---------------------------------------
exit:                                   ; finish the subroutine
        pop     ax                      ; pop ax off the stack
        pop     dx                      ; pop dx off the stack
        ret                             ; return
        end                             ;end
;---------------------------------------
