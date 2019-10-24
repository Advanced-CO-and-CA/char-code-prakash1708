

/******************************************************************************
* file: update_greater.s
* author: Prakash Tiwari
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/

@ BSS section
      .bss

@ DATA SECTION
  
@Input
.data

START1: .asciz  "CAT","CAT","CAT"
START2: .asciz  "BAT","CAT","CUT"
LENGTH: .word    3,3,3,0  @using 0 length as end of list of words

@Output
GREATER: .word   1,1,1

@ TEXT section
      .text

.globl _main

/******************************************************************************
* Limitation : String lengths should be less than word size(4 bytes) for this program to work
* Selected option Stack grows down and uncheck option to stop on unaligned access from Simulator preferences.
* Detail:
* Read START1 and START2 in loop by checking LENGTH, terminate the loop when LENGTH is zero
* Read strings from START1 and START2 and take diffence between each characters at same postion 
* and multiply the difference by 10 when jump to next character and add the subsequent difference between chacaters.
* Read strings from START1 and START2 and take diffence between each characters at same postion 
* String comparision terminates when LENGTH is reached and check the difference
* If difference is positive or zero, set corresponding GREATER to 0 else -1.
******************************************************************************/
main:
        @variable to iterate the list of words
        mov     r3, #0
        str     r3, [sp, #-8]
        
        @read length from the list
        ldr     r3, =LENGTH
        ldr     r3, [r3]
        str     r3, [sp, #-20]

find_greater_loop:
        @ check length if 0
        ldr     r3, [sp, #-20]
        cmp     r3, #0
        ble     find_greater_loop_end
        
        @ read the first array of strings
        ldr     r2, =START1
        ldr     r3, [sp, #-8]
        /*ldr     r3, [r2, r3, lsl #2]*/
        add     r3,r2,r3,lsl #2
        
        @save the string1 to stack
        str     r3, [sp, #-24]
        
        @ read the second array of strings
        ldr     r2, =START2
        ldr     r3, [sp, #-8]
        /*ldr     r3, [r2, r3, lsl #2]*/
        add     r3,r2,r3,lsl #2
        
        @save the string2 to stack
        str     r3, [sp, #-28]
        
        @variable on stack to iterate the characters in string
        mov     r3, #0
        str     r3, [sp, #-12]
        
        @variable on stack to save the difference in string1 and string2
        mov     r3, #0
        str     r3, [sp, #-16]

find_diff:
        @ read the number of scanned characters scanned
        ldr     r2, [sp, #-12]
        
        @ read the length of string
        ldr     r3, [sp, #-20]
        
        @compare if all characters are scanned
        cmp     r2, r3
        bge     update_greater

        @read the diffenece in string1 and string2 from stack updated in last iteration
        ldr     r2, [sp, #-16]
        mov     r3, r2

        @update the diff by multiplying by 10
        lsl     r3, r3, #2
        add     r3, r3, r2
        lsl     r3, r3, #1
        @save the diff for update after comparing characters
        mov     r1, r3
        
        @read the string1 and current characer position to comparare from stack
        ldr     r3, [sp, #-12]
        ldr     r2, [sp, #-24]
        
        @Find the current character to compare from string1
        add     r3, r2, r3
        ldrb    r3, [r3]
        
        @Current character is saved in r0
        mov     r0, r3
        
        @read the string1 and current characer position to comparare from stack
        ldr     r3, [sp, #-12]
        ldr     r2, [sp, #-28]
        
        @Find the current character to compare from string1
        add     r3, r2, r3
        ldrb    r3, [r3]
        
        @Compare character from string1 and string2 by subtracting character of string2 from string1
        sub     r3, r0, r3
        
        @Update the difference by adding the difference in characters ascii values
        add     r3, r1, r3
        
        @Update the difference value to stack for next iteration
        str     r3, [sp, #-16]
        
        @Update the number of scanned characters for next iteration
        ldr     r3, [sp, #-12]
        add     r3, r3, #1
        str     r3, [sp, #-12]
        b       find_diff

update_greater:
        @read the difference in string1 and string2 from stack for current string
        ldr     r3, [sp, #-16]
        cmp     r3, #0
        @if difference is less than 0 , update GREATER to 0xFFFFFFFF
        blt     update_greater_neg
        
        @ read the GREATER array base
        ldr     r2, =GREATER
        
        @read the current word position from stack
        ldr     r3, [sp, #-8]
        
        @update the GREATER to 0 for current word
        mov     r1, #0
        str     r1, [r2, r3, lsl #2]
        b       find_next_string

update_greater_neg:
        @ read the GREATER array base
        ldr     r2, =GREATER
        @read the current word position from stack
        ldr     r3, [sp, #-8]
        
        @update the GREATER to 0xFFFFFFFF for current word
        mvn     r1, #0
        str     r1, [r2, r3, lsl #2]

find_next_string:
        @update the next word postion to stack for next iteration
        ldr     r3, [sp, #-8]
        add     r3, r3, #1
        str     r3, [sp, #-8]
        
        @read the length from the list for next iteration
        ldr     r2, =LENGTH
        ldr     r3, [sp, #-8]
        ldr     r3, [r2, r3, lsl #2]
        
        @save the length from the list to stack for next iteration
        str     r3, [sp, #-20]
        b       find_greater_loop
find_greater_loop_end:
        swi 0x11  @ end of program
        .end