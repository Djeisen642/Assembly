;-----------------------------------------------------------
;  MYDRIVER
;
;  This is a very simple driver for a sort subroutine.
;
;  It allows you have full control over
;  - The main program
;  - The list
;  - The sort subroutine
;
;
;  Question: When do you need this?????
;  Answer:   If you may be writing outside the buffer
;            You are sorting data from outside the list
;            You are hurting the stack
;
;----------------------------------
                                  ;
         .model     small         ; 64k code and 64k data segments
         extrn     _sort:proc     ; the sort subroutine is external
         .stack     4096          ; stack
                                  ;
;----------------------------------


         .data
;----------------------------------
;
; You can build your list here.
; You can put data in front of the list
;  and after the list to see if you are
;  working outside the list boundaries
;
;----------------------------------
                                  ;
         db        55h            ; data *before* the list
                                  ;
data     db  9, 255, 100, 5, 40   ; data
                                  ;
         db        0AAh           ; data *after* the list
                                  ;
count    dw        2              ; two items in this list
;----------------------------------


         .code
;----------------------------------
;  Put your breakpoint at _sort to stop at entry to the sort.
;
;  Put your breakpoint at back to stop after the list is sorted.
;----------------------------------
start:                            ;
         mov       ax,@data       ; address the
         mov       ds,ax          ; data segment
                                  ;
         mov       ax,[count]     ; get  list length
         push      ax             ; push list length
         mov       ax,offset data ; get  list pointer
         push      ax             ; push list pointer
         call      _sort          ; call sort
                                  ;
back:                             ;
         mov       ax,4c00h       ; get termination code
         int       21h            ; exit
;----------------------------------
         end       start
