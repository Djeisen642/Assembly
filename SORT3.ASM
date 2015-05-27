;--------------------------------------------------------------
; Insertion Sort
;   Uses comparisons to determine the sorting
;   	public static void insertSort(int[] A){
;		    for(int i = 1; i < A.length; i++){      //for all numbers past the first one
;		    	int value = A[i];                   //Place the value of the number at index i in 'value'
;		    	int j = i - 1;                      //place the value of the current index - 1 into j
;		    	while(j >= 0 && A[j] > value){      //while j is greater than or equal to zero and the value in A[j] is greater than 'value'
;		    		A[j + 1] = A[j];                //move things down
;			    	j = j - 1;                      //decrement j
;			    }
;			    A[j + 1] = value;                   //if j < 0 or A[j] <= value, then place 'value' into the space one after A[j]
;		    }
;	    }
;
;   Basically, inserts the number one slot after the number which it is greater than, after having moved all numbers down a slot.
;   Repeats this for all numbers including the last.
;
;
;
; Program:  SORT subroutine
;
; Function: Sorts a list of unsigned bytes from low to high
;
; Input:    - Pointer to a list of unsigned bytes
;           - Count of elements in the list (1...50 is valid)
;
; Output:   - Return Code 0=list sorted  1=count invalid
;
; Owner:    Jason Suttles
;
; Date:     Update Reason
; -----------------------
; 06/24/2012 Original version
;
;---------------------------------------
         .model    small               ;64k code and 64k data
         .8086                         ;only allow 8086 instructions
         public    _sort               ;
;---------------------------------------




;---------------------------------------
         .data                         ;start the data segment
;---------------------------------------
temp    dw  ?                           ;stores the si temporarily so that I don't move from a reg to a reg

;---------------------------------------

;---------------------------------------
         .code                         ;start the code segment
;---------------------------------------
; Save the registers 'C' requires (bp, si,di)
; Access the list and count
;---------------------------------------
_sort:                                  ;
        push    bp                      ;save 'C' registers
        mov     bp,sp                   ;set bp to point to stack
        push    si                      ;save 'C' registers
        push    di                      ;save 'C' registers
        push    dx
        mov     bx,[bp+4]               ;bx points to the list
        mov     cx,[bp+6]               ;cx=count
;---------------------------------------
; Checks count to make sure that it is a valid count
;   Can't be over 50
;   Can't be 0
;   If it's 1, then don't sort it
;---------------------------------------
compares:
        cmp     cx, 50                  ; Is count above than 50?
        ja      bad                     ; It is, it's bad
        cmp     cx, 0                   ; Is count 0?
        je      bad                     ; It is, it's bad
        cmp     cx, 1                   ; Is count 1?
        je      good                    ; Yes, don't sort it
;---------------------------------------
;   Creates the data segment
;   Sets the initial values of si, di, al
;---------------------------------------
        mov     ax, @data               ;moves data section to ax
        mov     ds, ax                  ;moves ax to data segment
        mov     al, cl
        mov     ah, 2
        div     ah
        mov     ch, al
shellsort:
        cmp     ch, 0
        jbe     good
forloop:
        cmp     si, cx
        jae     ifelse
        mov     si, ch
        mov     di, si
        mov     al, [bx + si]
whileloop:
        cmp     di, ch
        jb      done
        push    di
        sub     di, ch
        cmp     [bx + di], al
        pop     di
        jbe     done
        
done:
        mov     [bx + di], al
ifelse:
        cmp     ch, 2
        jne     elsestatement
        dec     ch
        jmp     whileloop
elsestatement:        
        
;---------------------------------------
; Sorting is done
;   It either went well or poorly
;---------------------------------------
good:
        mov     ax,0                    ; set rc = okay
        jmp     exit                    ; jump to exit
bad:                                    ; the count was bad
        mov     ax, 1                   ; set rc = not okay
        
;---------------------------------------
; Restore registers and return
;---------------------------------------
exit:
        pop     di                      ;restore 'C' registers
        pop     si                      ;restore 'C' registers
        pop     bp                      ;restore 'C' registers
        ret                             ;return
;---------------------------------------
        end
