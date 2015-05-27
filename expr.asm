;--------------------------------------------------------------------
;   Program:  expr (MASM version)
;
;   Function: Checks a line to determine whether it is a valid expression.
;             A line can be valid, have invalid format, or invalid variables.
;             This program only finds the first error.
;             Uses a switch to switch between determining 
;             whether an operand or an operator is being looked at.
;
;   Owner:    Jason Suttles
;
;   Date:     Changes
;   09/25/12  original version
;
;---------------------------------------
        .model  small                   ;64k code and 64k data
        .8086                           ;only allow 8086 instructions
        .stack  256                     ;reserve 256 bytes for the stack
;---------------------------------------


;---------------------------------------
        .data                           ;start the data segment
;---------------------------------------
msg1    db      'LINE IS VALID',13,10,13,10,'$' ; valid line message       
msg2    db      'INVALID VARIABLE',13,10,13,10,'$' ; invalid variable message
msg3    db      'INVALID FORMAT',13,10,13,10,'$' ; invalid format message
check2  dw      0                       ; checks character after operator
errnum  dw      0                       ; holds error
check   dw      0                       ; holds space check
operand dw      0                       ; holds operand
state   dw      0                       ; holds state
msgtbl  dw      valid, format, variable ; message jump table
fjmptbl dw      isspace, errortype, isupper ; first state jump table
sjmptbl dw      read, errortype2, isoperator ; second state jump table
firsttbl    db  32 dup (0)              ; table to determine valid characters in the first state
        db      0                       ; space
        db      32 dup (2)              ; invalid
        db      26 dup (4)              ; uppercase
        db      165 dup (2)             ; invalid
sectbl  db      32 dup (0)              ; table to determine valid characters in the second state
        db      0                       ; space
        db      10 dup (2)              ; invalid
        db      4, 2, 4                 ; +, invalid, -
        db      15 dup (2)              ; invalid
        db      4                       ; =
        db      193 dup (2)             ; invalid
;---------------------------------------


;---------------------------------------
        .code                           ;start the code segment
;---------------------------------------
expr:                                   ;
        mov     ax, @data               ; establish addressability to the
        mov     ds, ax                  ; data segment for this program
        jmp     read                    ; jump to write
;---------------------------------------
;   sets the message to be written
;---------------------------------------
valid:                                  ;
        mov     dx, offset msg1         ; point to the valid message
        jmp     write                   ; jump to write
format:                                 ;
        mov     dx, offset msg3         ; point to the invalid format message
        jmp     write                   ; jump to write
variable:                               ;
        mov     dx, offset msg2         ; point to the invalid variable message
;---------------------------------------
;   writes the message and resets variables
;---------------------------------------
write:                                  ;
        mov     errnum, 0               ; reset error 
        mov     check, 0                ; reset check     
        mov     operand, 0              ; reset operand
        mov     state, 0                ; reset state
        mov     ah, 9                   ; set the dos code to write a string
        int     21h                     ; write the string
;---------------------------------------
;   echo a new character
;---------------------------------------
read:                                   ;
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character
        mov     dl, al                  ; no, move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
        cmp     check2, 1               ; is the second state checking something?
        je      isspace2                ; it is
;---------------------------------------
;   check a character for eol and eof
;---------------------------------------
eolfcheck:                              ;
        cmp     dl, 1Ah                 ; is the char eof
        je      exit                    ; exit program
        cmp     dl, 0Ah                 ; is the char eol
        je      eol                     ; process line error
;---------------------------------------
;   check for first error
;---------------------------------------
        cmp     errnum, 0               ; Has there been an error?
        jne     read                    ; jump to read
        mov     ah, 0                   ; change al to word
        cmp     state, 1                ; Which state are we in?
        je      second                  ; jump to the second state
        jb      first                   ; jump to the first state
;---------------------------------------
;   figure out what message to write at the end of a line
;---------------------------------------
eol:                                    ; what to write at the end of line
        cmp     operand, 0              ; did the message end on an operand?
        jne     operanderror            ; if it didn't
        mov     si, errnum              ; move errnum to si register
        add     si, si                  ; double because it's a word
        jmp     [word ptr msgtbl + si]  ; message jump table
operanderror:                           ; Did not end on an operand
        jmp     format                  ; jump to the correct message
;---------------------------------------
;   switch statement: first case
;   if ( c != ' ' && !isupper(c) && check == 0) {
;       error = 2; //first character is not a space or upper
;   } else {
;       if (c == ' ' && check == 0) ; //character is space and before upper
;       else if (isupper(c)) { //is upper
;           check = 1; //Variable is started
;           operand = 0; //operand is checks the term
;       } else if (c == ' ' && check == 1) //character is space after upper
;           state = 1;  
;       else error = 1; //not upper or space
;   }
;---------------------------------------        
first:                                  ; first case label
        mov     bx, offset firsttbl     ; bx points to table
        xlat                            ; translate the character to see if there is an error
        mov     si, ax                  ; move ax to si
        jmp     [word ptr fjmptbl + si] ; first state jump table
errortype:                              ; check the type of error
        mov     cx, check               ; move check to cx
        inc     cx                      ; increment cx
        mov     errnum, cx              ; move cx to errnum
        jmp     read                    ; jump to read
;---------------------------------------
;   valid character in the first case
;---------------------------------------
isspace:                                ; deal with a space
        cmp     check, 0                ; has an uppercase character been seen?
        je      read                    ; no, jump to read
        mov     state, 1                ; yes, change the state to 1
        jmp     read                    ; jump to read
isupper:                                ; deal with uppercase
        mov     check, 1                ; an uppercase character has been seen
        mov     operand, 0              ; an operand is the last term
        jmp     read                    ; jump to read
;---------------------------------------
;   switch statement: second case
;       if (c == ' ' && check == 1) ; //space after upper
;       else if (c == '+' || c == '-' || c == '=') { //operator
;           check = 0; //
;           operand = 1; //operand is not the last term
;           c = fgetc(input); //get the next character to see if it's a space
;           if (c != ' ') error = 2; //if it's not then there is a format error
;           else state = 0; //if there is then change state
;           ungetc(c, input); //put the character back
;       }
;       else error = 2; //not space or character
;---------------------------------------
second:                                 ; second case
        mov     bx, offset sectbl       ; bx points to table
        xlat                            ; translate the character to see if there is an error
        mov     si, ax                  ; move ax to si
        jmp     [word ptr sjmptbl + si] ; second state jump table
errortype2:                             ; deal with the error
        mov     errnum, 1               ; there's a format error
        cmp     check2, 1               ; was doing a check when error was found
        mov     check2, 0               ; reset check2
        je      eolfcheck               ; jump back to where it left off in the read/write section
        jmp     read                    ; jump back to the start of read
;---------------------------------------
;   dealing with an operator
;---------------------------------------
isoperator:                             ; it's an operator
        mov     check, 0                ; the operand has not been seen
        mov     operand, 1              ; the last term seen was an operator
        mov     check2, 1               ; check next character
        jmp     read                    ; jump to read
isspace2:                               ; is the next character a space?
        cmp     al, ' '                 ; is it?
        jne     errortype2              ; it's not, format error
        mov     state, 0                ; it is, change state
        mov     check2, 0               ; reset check2
        jmp     eolfcheck               ; jump back to where it left off
;---------------------------------------
; terminate program execution
;---------------------------------------
exit:                                   ;
        mov     ax,4c00h                ;set dos code to terminate program
        int     21h                     ;return to dos
        end     expr                    ;end marks the end of the source code
                                        ;....and specifies where you want the
                                        ;....program to start execution
;---------------------------------------
