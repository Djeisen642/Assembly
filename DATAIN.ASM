;---------------------------------------------------------------------
;   DATAIN
;
;   The input to datain comes from the standard input device.  It is an
;   ASCII file with zero or more lines of text.  Each line consists of one
;   or more printable ASCII characters (20h - 7Fh).  All lines are
;   terminated by the character pair Carriage Return (CR=0Dh) and Line Feed
;   (LF=0Ah).  The file is terminated by an end of file character
;   (EOF=1Ah).  A valid line of text has the following format.  The fields
;   in brackets [ ] are optional.
;
;   [ LB ]  [ SIGN ]  NN...  [ TB ]  [ COMMENT ]  CR  LF
;
;   LB        0 or more leading blanks/spaces.
;
;   SIGN      A single optional sign character which can be a + or -
;             sign.  If it is not present then the number is assumed to be
;             positive.
;
;   NN...     A multiple digit number consisting of 1 or more ASCII digits
;             in the range of 0 through 9. No other characters are allowed.
;             The only restriction is that valid numbers must fit in a
;             two's complement signed word.  This means they must be in the
;             range of -32768 through +32767.  If the user inputs any form
;             of ASCII negative zero then that is to be accepted as valid
;             and converted into two's complement positive zero.
;
;   TB        0 or more trailing blanks/spaces.
;
;   COMMENT   An optional comment field.  If it is present then it must be
;             separated from the number field by at least one blank/space
;             (this means TB must be one or more blanks/spaces).  It may
;             consist of any number of characters and continues until the
;             end of the line.
;
;   CR LF     The required end of line character pair.
;
;   Each time the datain subroutine is called it will:
;   - Read and echo a single complete input line.  This includes all
;     characters including the CR/LF pair.
;   - Convert the ASCII number into two's complement format if the input
;     line is valid.
;   - Return the two's complement value and a return code indicating the
;     status of the conversion operation.
;
;   Output from datain:
;   ax Contains the return code indicating the status of the conversion
;      0 = The input line was valid.  A number was converted from ASCII into
;          two's complement.  The converted number is returned in dx
;      1 = The input line was not valid.  A number was not converted.
;      2 = End of file (1Ah) was found.  There was no input line.
;   dx Contains the converted number if ax = 0.
;   All registers except ax and dx are restored to their input value.
;---------------------------------------
                                       ;
         .model     small              ;64k code and 64k data
         .8086                         ;only allow 8086 instructions
         public     datain             ;allow linker to access datain
;---------------------------------------




;---------------------------------------
        .data                          ;start the data segment
;---------------------------------------
sum     dw      ?                       ; sum of the number
sign    db      ?                       ; sign of the number
chara   dw      ?                       ; character input

types   dw      bad, number, signs, read ; jump table

tbl     db      14  dup (6)             ; nothing to do here
        db      0                       ; carriage return before number
        db      18  dup (6)             ; nothing to do here
        db      10  dup (0)             ; bad things to see
        db      4, 0, 4                 ; '+', bad, '-'
        db      2   dup (0)             ; bad
        db      10  dup (2)             ; first number
        db      199 dup (0)             ; bad

tbltwo  db      32  dup (4)             ; nothing to do here
        db      2                       ; handle a space
        db      15  dup (6)             ; bad things to see
        db      10  dup (0)             ; number
        db      199 dup (6)             ; bad
;---------------------------------------
        .code                          ;start the code segment
;---------------------------------------
; Save registers
; Initialize variables
;---------------------------------------
datain:                                 ;
        push    bx                      ; store bx
        push    si                      ; store si
        push    cx                      ; store cx
        mov     ax, @data               ; move data section to ax
        mov     ds, ax                  ; move ax to data segment
        mov     bx, offset tbl          ; offset bx to tbl
        mov     cx, 10                  ; store 10 to cx for mul
;---------------------------------------
;   reset all variables to 0
;    retcode = sum = sign = signcheck = startnum = endnum =  0;
;--------------------------------------- 
        mov     dx, 0                   ; clear dx
        mov     sum,    0               ; sum = 0
        mov     sign,   0               ; sign = 0
;---------------------------------------
;   read a character
;    ch = getchar();
;---------------------------------------
read:                                   ;
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character
;---------------------------------------
;   check for eof
;    if (ch == EOF) {retcode = 2; return (retcode);}
;---------------------------------------        
        cmp     al, 1Ah                 ; is the char eof
        je      eof                     ; exit program     
;---------------------------------------
;   check for eof
;    putchar(ch);
;---------------------------------------         
        mov     dl, al                  ; no, move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
        
        mov     ah, 0                   ; clear 2 from ah
;---------------------------------------
;   Trying to find the first sign or number
;---------------------------------------        
        xlat                            ; translate to a label
        mov     si, ax                  ; move the label to si
        jmp     [word ptr types + si]   ; jump to the label
;---------------------------------------
;   Bad input
;---------------------------------------        
bad:                                    ; handles bad input
        jmp     badread                 ; it was bad so, jump to faster badread
;---------------------------------------
;   space after a number indicating the beginning of comments
;---------------------------------------
endspace:                               ;
        jmp     endread                 ; jump to comment reader
;---------------------------------------
;   handles signs before a number
;    if (!signcheck) {
;        if (ch == '+') {sign = +1; signcheck ++; continue;}
;        if (ch == '-') {sign = -1; signcheck ++; continue;}
;    }
;---------------------------------------
signs:                                  ;
        cmp     dl, '+'                 ; is it a plus sign?
        je      next                    ; yes, jump to next
        
        mov     sign,   1               ; it's a minus sign
;---------------------------------------
;   read character after sign and check for number
;---------------------------------------
next:
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character   
;---------------------------------------
;    putchar(ch);
;---------------------------------------         
        mov     dl, al                  ; no, move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character

        xlat                            ; translate al
        cmp     al, 2                   ; was al a number?
        jne     bad                     ; no, then it's bad
;---------------------------------------
;   handles all numbers
;    if ((ch >= '0') && (ch <= '9') && !endnum)
;       sum = sum*10 + ch - '0';
;---------------------------------------
number:                                 ;
        mov     bx, offset tbltwo       ; offset bx to table two
        cmp     dl, '0'                 ; check character for 0
        je      leadingzeros            ; it's a leading zero
;---------------------------------------
;   handles first number 
;    sum = sum*10 + ch - '0';
;       chara = dl - '0'
;       ax = sum* 10
;       ax = ax + chara
;       sum = ax
;---------------------------------------        
numbergo:        
        mov     chara,  dx              ; store dx because it will be used in mul
        sub     chara,  '0'             ; ch - '0'
        mov     ax, sum                 ; move sum to ax since mul is done on ax
        mul     cx                      ; ax*10
        add     ax, chara               ; ax*10 + ch - '0'
        mov     sum,    ax              ; move ax back to sum
;---------------------------------------
;   get a character
;---------------------------------------
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character      
;---------------------------------------
;   print a character
;---------------------------------------
        mov     dl, al                  ; move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
;---------------------------------------
;   translate al to a type
;   depending on type jump to another label
;---------------------------------------
        xlat                            ; translate al
        cmp     al, 2                   ; What type is it?
        jb      twodigits               ; it's the next digit
        je      endspace                ; it's a space after the number
        cmp     al, 4                   ; it's either the end or bad
        je      endread                 ; it's the end
        jmp     bad                     ; it's bad
;---------------------------------------
;   handles the second digit 
;    sum = sum*10 + ch - '0';
;       chara = dl - '0'
;       ax = sum* 10
;       ax = ax + chara
;       sum = ax
;---------------------------------------
twodigits:                              ; 
        mov     chara,  dx              ; store dx because it will be used in mul
        sub     chara,  '0'             ; ch - '0'
        mov     ax, sum                 ; move sum to ax since mul is done on ax
        mul     cx                      ; ax*10
        add     ax, chara               ; ax*10 + ch - '0'
        mov     sum,    ax              ; move ax back to sum
;---------------------------------------
;   get a character
;---------------------------------------
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character      
;---------------------------------------
;   print a character
;---------------------------------------
        mov     dl, al                  ; move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
;---------------------------------------
;   translate al to a type
;   depending on type jump to another label
;---------------------------------------        
        xlat                            ; translate al
        cmp     al, 2                   ; What type is it?
        jb      threedigits             ; it's the next digit
        je      endspace                ; it's a space after the number
        cmp     al, 4                   ; it's either the end or bad
        je      endread                 ; it's the end
        jmp     bad                     ; it's bad
;---------------------------------------
;   handles the third digit
;    sum = sum*10 + ch - '0';
;       chara = dl - '0'
;       ax = sum* 10
;       ax = ax + chara
;       sum = ax
;---------------------------------------
threedigits:                            ; 
        mov     chara,  dx              ; store dx because it will be used in mul
        sub     chara,  '0'             ; ch - '0'
        mov     ax, sum                 ; move sum to ax since mul is done on ax
        mul     cx                      ; ax*10
        add     ax, chara               ; ax*10 + ch - '0'
        mov     sum,    ax              ; move ax back to sum
;---------------------------------------
;   get a character
;---------------------------------------
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character      
;---------------------------------------
;   print a character
;---------------------------------------
        mov     dl, al                  ; move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
;---------------------------------------
;   translate al to a type
;   depending on type jump to another label
;---------------------------------------         
        xlat                            ; translate al
        cmp     al, 2                   ; What type is it?
        jb      fourdigits              ; it's the next digit
        je      endspace                ; it's a space after the number
        cmp     al, 4                   ; it's either the end or bad
        je      endread                 ; it's the end
        jmp     bad                     ; it's bad
;---------------------------------------
;   handles the fourth digit
;    sum = sum*10 + ch - '0';
;       chara = dl - '0'
;       ax = sum* 10
;       ax = ax + chara
;       sum = ax
;---------------------------------------
fourdigits:                             ; 
        mov     chara,  dx              ; store dx because it will be used in mul
        sub     chara,  '0'             ; ch - '0'
        mov     ax, sum                 ; move sum to ax since mul is done on ax
        mul     cx                      ; ax*10
        add     ax, chara               ; ax*10 + ch - '0'
        mov     sum,    ax              ; move ax back to sum
;---------------------------------------
;   get a character
;---------------------------------------
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character      
;---------------------------------------
;   print a character
;---------------------------------------
        mov     dl, al                  ; move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
;---------------------------------------
;   translate al to a type
;   depending on type jump to another label
;---------------------------------------         
        xlat                            ; translate al
        cmp     al, 2                   ; What type is it?
        jb      fivedigits               ; it's the next digit
        je      endspace                ; it's a space after the number
        cmp     al, 4                   ; it's either the end or bad
        je      endread                 ; it's the end
        jmp     bad                     ; it's bad
;---------------------------------------
;   handles the fifth digit
;    sum = sum*10 + ch - '0';
;       chara = dl - '0'
;       ax = sum* 10
;       ax = ax + chara
;       sum = ax
;---------------------------------------
fivedigits:                             ; 
        mov     chara,  dx              ; store dx because it will be used in mul
        sub     chara,  '0'             ; ch - '0'
        mov     ax, sum                 ; move sum to ax since mul is done on ax
        mul     cx                      ; ax*10
        jc      bad                     ; did you go over 65535?
        add     ax, chara               ; ax*10 + ch - '0'
        jc      bad                     ; did you go over 65535?
        mov     sum,    ax              ; move ax back to sum
;---------------------------------------
;   get a character
;---------------------------------------
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character      
;---------------------------------------
;   print a character
;---------------------------------------
        mov     dl, al                  ; move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
;---------------------------------------
;   translate al to a type
;   depending on type jump to another label
;---------------------------------------         
        xlat                            ; translate al
        cmp     al, 2                   ; What type is it?
        jb      check                   ; it's the next digit
        je      endspace                ; it's a space after the number
        cmp     al, 4                   ; it's either the end or bad
        je      endread                 ; it's the end
        jmp     bad                     ; it's bad
;---------------------------------------
;   handles sixth digit
;---------------------------------------
check:        
        jmp     bad                     ; Why is there a sixth digit??? Bad!!
;---------------------------------------
;   handles leading zeros
;   gets a character
;   prints a character
;   checks character
;---------------------------------------
leadingzeros:
;---------------------------------------
;   get a character
;---------------------------------------
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character      
;---------------------------------------
;   print a character
;---------------------------------------
        mov     dl, al                  ; move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
;---------------------------------------
;   loop on zeros
;---------------------------------------        
        cmp     dl, '0'                 ; is it a zero?
        je      leadingzeros            ; loop
;---------------------------------------
;   translate al to a type
;   depending on type jump to another label
;---------------------------------------         
        xlat                            ; translate al
        cmp     al, 2                   ; What type is it?
        jb      numbergo                ; it's the next digit
        je      endspace                ; it's a space after the number
        cmp     al, 6                   ; it's either the end or bad
        je      bad                     ; it's bad
;---------------------------------------
;   handles everything after the last number
;---------------------------------------
endread:
;---------------------------------------
;   get a character
;---------------------------------------
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character      
;---------------------------------------
;   print a character
;---------------------------------------
        mov     dl, al                  ; move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
;---------------------------------------
;   check for eol
;    if (ch == '\n') break;
;    else keep reading
;---------------------------------------          
        cmp     dl, 0Ah                 ; is the char eol
        jne     endread                 ; jump back to endread to keep reading
        jmp     eol                     ; process end of line
;---------------------------------------
;   handles everything after bad input
;---------------------------------------
badread:
;---------------------------------------
;   get a character
;---------------------------------------
        mov     ah, 8                   ; code to read without echo
        int     21h                     ; read a character      
;---------------------------------------
;   print a character
;---------------------------------------
        mov     dl, al                  ; move the char to dl
        mov     ah, 2                   ; echo the character from dl
        int     21h                     ; write the character
;---------------------------------------
;   check for eol
;    if (ch == '\n') break;
;    else keep reading
;---------------------------------------          
        cmp     dl, 0Ah                 ; is the char eol
        jne     badread                 ; jump back to badread to keep reading
        jmp     eolbad                  ; process end of line
;---------------------------------------
;   EOF has been called
;    if (ch == EOF) {retcode = 2; return (retcode);}
;---------------------------------------        
eof:                                    ;
        mov     ax, 2                   ; move eof code to ax
        jmp     exit                    ; jump to exit
;---------------------------------------
;   maybe the number is bad?
;---------------------------------------
maybe:                                  ;
        ja      eolbad                  ; It's definitely bad
        cmp     sign,   0               ; is the sign positive?
        jne     continue                ; it's negative, so 8000h is valid
;---------------------------------------
;   It was bad
;---------------------------------------
eolbad:                                 ; can fall through from above, if over 8000h
        mov     ax, 1                   ; move invalid line code to ax
        jmp     exit                    ; jump to exit
;---------------------------------------
;   handles end of line
;   stores sum to dx
;   stores return code to ax
;   checks whether the number was over 8000h
;   checks which sign it had
;---------------------------------------
eol:                                    ;        
        mov     dx, sum                 ; move sum to dx
        mov     ax, 0                   ; move return code to ax
        
        cmp     sum, 8000h              ; was 8000h or over?
        jae     maybe                   ; yes, it might be bad
        
        cmp     sign,   1               ; was it negative?
        jne     exit                    ; no, jump to exit
        
continue:
        neg     dx                      ; it wasn't over 8000h and it's negative, negate it
        
;---------------------------------------
;   terminate subroutine execution
;---------------------------------------
exit:
        pop     cx                      ; restore cx
        pop     si                      ; restore si
        pop     bx                      ; restore bx
        ret                             ; return
        end                             ; end
;---------------------------------------
