;--------------------------------------------------------------------
;   Program:  Key (MASM version)
;
;   Function: Writes uppercase alphabetic input to the standard output device.
;             By the steps: 
;             1. It reads a character.
;             2. Checks if it is a period or a space
;             3. Checks if it could be a letter, if it could, tries to make it uppercase
;             4. Checks if it is uppercase
;             5. If it was any of the above, it prints it.
;             6. If it was a period it exits, else it reads another character.
;
;   Owner:    Jason Suttles
;
;   Date:     Changes
;   09/18/12  original version
;
;---------------------------------------
        .model      small               ;64k code and 64k data
        .8086                           ;only allow 8086 instructions
        .stack      256                 ;reserve 256 bytes for the stack
;---------------------------------------


;---------------------------------------
        .code                           ;start the code segment
;---------------------------------------

;---------------------------------------
; read a character
;---------------------------------------
read:                                   ; do
        mov         ah, 8               ; set the dos code to read a character
        int         21h                 ; read the character
        mov         dl, al
;---------------------------------------
; if (input == ' ' || input == '.')
;---------------------------------------
        cmp         dl, 20h             ; if (input == ' ')
        je          write               ; printf("%c", input)
        cmp         dl, 2Eh             ; if (input == '.')
        je          write               ; printf("%c", input)
;---------------------------------------
; else if (isalpha(input))
;---------------------------------------
check:
        cmp         dl, 5Ah             ; if (input <= 'Z')
        jbe         upper               ; it might be uppercase
        sub         dl, 20h             ; it's not uppercase, try to make it uppercase
        jmp         check               ; check it again
upper: 
        cmp         dl, 41h             ; is it uppercase?
        jb          read                ; it isn't
;---------------------------------------
; write a character
;---------------------------------------
write:                                  ; printf
        mov         ah, 2               ; set the dos code to write
        int         21h                 ; write the character
        cmp         dl, 2Eh             ; compare input to '.'
        jne         read                ; while (input != '.')
;---------------------------------------
; terminate program execution
;---------------------------------------
exit:                                  ;
        mov         ax,4c00h           ;set dos code to terminate program
        int         21h                ;return to dos
        end         read               ;end marks the end of the source code
                                       ;....and specifies where you want the
                                       ;....program to start execution
;---------------------------------------