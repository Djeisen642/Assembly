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
        mov     si, 1                   ;moves second number index to si
        mov     di, 0                   ;moves first number index to di  
        mov     al, [bx + si]           ; int value = A[i];
;---------------------------------------
; Insertion sort starts here
;   checks values of di
;   compares the number at index di compared to the number at index si
;       while(j >= 0 && A[j] > value)
;---------------------------------------
insertionsort:
        cmp     di, 0                   ; Is di less than 0?
        jl      insert                  ; Yes, the number at index si is the current smallest number
        cmp     [bx + di], al           ; Is the number at index di below or equal to the number at index si
        jbe     insert                  ; Yes, the number at index si should be inserted right after the number at index di
;---------------------------------------
; Keep moving things down while the above conditions are not met
;   Decrement index di     
;       A[j + 1] = A[j];
;	    j = j - 1; 
;   Since move doesn't move from memory to memory use intermediary ah register
;---------------------------------------
move:
        mov     ah, [bx + di]           ; move number at index di to ah
        mov     [bx + di + 1], ah       ; replace number at index di + 1 with number in ah
        dec     di                      ; decrement di
        jmp     insertionsort           ; jump to insertionsort
;---------------------------------------
; Insert number at index si into its new location
;   then do everything necessary to allow the repetition of the process
;       A[j + 1] = value;
;       i++;
;       i < A.length;
;       int j = i - 1;
;       int value = A[i];
;---------------------------------------
insert:
        mov     [bx + di + 1], al       ; replace number at index di + 1 with number in al
        inc     si                      ; increment si
        cmp     si, cx                  ; Is si equal to cx?
        jae     good                    ; Yes, the end of the array has been reached, sorting is done
        
        mov     al, [bx + si]           ; move number at index si to al
        mov     di, si                  ; move si to di
        dec     di                      ; decrement di
        jmp     insertionsort           ; do some more sorting
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