
/******************************************************************************
* file: find_substring.s
* author: Prakash Tiwari
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/


/******************************************************************************
* Implementation Detail:
* Selected option Stack grows down and uncheck option to stop on unaligned access from Simulator preferences.
* Arrage the strings and substrings with their addresses for reading the string and substrings from their respective addresses.
* Take variables on stack to track the string to be fetched, to track the character postion in String and Substring and to set 
* a flag whether subsring is found in sting 
* Read String and Substring from STRING and SUBSTR list using their postions
* Program terminates when either of String and Substr is NULL and number of strings and substrs to be equal for this to work
* For every string in STRING, read the characters of string and sustring and compare if chacter match is found.
* Once match found, check if every chacater of substring matches with string from this postion
* If substring is read completely and matched and we reach the NULL terminator of sunstring, set the PRESENT list with corresponding string postion.
* else set to zero
* Update the tracking variable and flag to fetch next string and substring for subsequent itreation.
******************************************************************************/

@ BSS section
      .bss

@ DATA SECTION
  
@Input
.data

NUL   : .word 0 

string1: .asciz  "CS6620"
substring1 : .asciz  "S5"
substring2 : .asciz  "620"
substring3 : .asciz  "6"
null_string : .word 0

STRING:  
.word string1
.word string1
.word string1
.word null_string

SUBSTR:  
.word substring1
.word substring2
.word substring3
.word null_string

@Output
PRESENT: .word   0,0,0,0

@ TEXT section
      .text

.globl _main

main:

find_substr:
        @Variable on stack to traverse strings in the STRING and SUBSTR
        mov     r3, #0
        str     r3, [sp, #-8]
        @Variable on stack to traverse characters in the STRING
        mov     r3, #0
        str     r3, [sp, #-12]
        @Variable on stack to traverse characters in the SUBSTR
        mov     r3, #0
        str     r3, [sp, #-16]
        @Variable on stack to track if SUBSTR is found in STRING
        mov     r3, #0
        str     r3, [sp, #-20]
        @read the base address of list STRING and store it to stack
        ldr     r3, =STRING
        ldr     r3, [r3]
        str     r3, [sp, #-24]
        @read the base address of list SUBSTR and store it to stack
        ldr     r3, =SUBSTR
        ldr     r3, [r3]
        str     r3, [sp, #-28]

loop_string_substr_scan:
        @load the string from STRING
        ldr     r3, [sp, #-24]
        @load the NULL string for comparision
        ldr     r2,=NUL
        ldr     r2,[r2]
        @compare string with NULL string
        cmp     r3, r2
        beq     end_loop_string_substr_scan
        @load the sub-string from SUBSTR
        ldr     r3, [sp, #-28]
        @load the NULL string for comparision
        ldr     r2,=NUL
        ldr     r2,[r2]
        @compare sub-string with NULL string
        cmp     r3, r2
        beq     end_loop_string_substr_scan
        @Variable on stack to traverse characters in the STRING
        mov     r3, #0
        str     r3, [sp, #-12]

subtring_search:
        @load the current character position of string from stack
        ldr     r3, [sp, #-12]
        @load the string from stack
        ldr     r2, [sp, #-24]
        @Load the current character from string
        add     r3, r2, r3
        ldrb    r3, [r3]
        @compare if the end of string
        cmp     r3, #0
        beq     end_substring_search
        @load the current character position of string from stack
        ldr     r3, [sp, #-12]
        @load the string from stack
        ldr     r2, [sp, #-24]
        @Load the current character from string
        add     r3, r2, r3
        ldrb    r2, [r3]
        @Load the current character from sub-string
        ldr     r3, [sp, #-28]
        ldrb    r3, [r3]
        @compare if character from string and sub-string matches
        cmp     r2, r3
        bne     update_present_status
        @Set the found substring flag if character matches
        mov     r3, #1
        str     r3, [sp, #-20]
        @reset the current character position of sub-string to stack
        mov     r3, #0
        str     r3, [sp, #-16]

compare_str_substr:
        @Load the current character position and current character for substring
        ldr     r3, [sp, #-16]
        ldr     r2, [sp, #-28]
        add     r3, r2, r3
        ldrb    r3, [r3]
        @compare the current character of substring with NULL character for end of substring
        cmp     r3, #0
        beq     update_present_status
        @load the current character postition for string and substring respectively and add them
        ldr     r2, [sp, #-12]
        ldr     r3, [sp, #-16]
        add     r3, r2, r3
        mov     r2, r3
        @read the string from stack and find the current character position with above relative position
        ldr     r3, [sp, #-24]
        add     r3, r3, r2
        ldrb    r2, [r3]
        @read the current character position for sub-string and sub-string from stack
        ldr     r3, [sp, #-16]
        ldr     r1, [sp, #-28]
        add     r3, r1, r3
        ldrb    r3, [r3]
        @compare character from string and substring if they are equal
        cmp     r2, r3
        beq     substring_char_found
        @update substring not found: found flag set to zero
        mov     r3, #0
        str     r3, [sp, #-20]
        b       update_present_status

substring_char_found:
        @update the character position for substring for next charcater compare
        ldr     r3, [sp, #-16]
        add     r3, r3, #1
        str     r3, [sp, #-16]
        b       compare_str_substr

update_present_status:
        @read the found flag value from stack
        ldr     r3, [sp, #-20]
        
        @compare if substring found flag is 1
        cmp     r3, #1
        @update_result
        beq     update_PRESENT
        
        @compare remaining substring
        ldr     r3, [sp, #-12]
        add     r3, r3, #1
        str     r3, [sp, #-12]
        b       subtring_search

update_PRESENT:
end_substring_search:
        @check the substring found flag status
        ldr     r3, [sp, #-20]
        cmp     r3, #0
        @ if flag is set, update the substring position in PRESENT
        bne     update_substring_pos
        ldr     r2, =PRESENT
        ldr     r3, [sp, #-8]
        mov     r1, #0
        str     r1, [r2, r3, lsl #2]
        b       search_next_substr

update_substring_pos:
        @read the current character position of string
        ldr     r3, [sp, #-12]
        add     r2, r3, #1
        ldr     r1, =PRESENT
        @read the current string or substring position in the array 
        ldr     r3, [sp, #-8]
        str     r2, [r1, r3, lsl #2]

search_next_substr:
        @read the current string/substring position in array
        ldr     r3, [sp, #-8]
        add     r3, r3, #1
        str     r3, [sp, #-8]
        
        @update the next string from array to stack
        ldr     r2, =STRING
        ldr     r3, [sp, #-8]
        ldr     r3, [r2, r3, lsl #2]
        /*add      r3, r2, r3, lsl #2*/
        str     r3, [sp, #-24]
        
        @update the next substring from array to stack
        ldr     r2, =SUBSTR
        ldr     r3, [sp, #-8]
        ldr     r3, [r2, r3, lsl #2]
        /*add      r3, r2, r3, lsl #2*/
        str     r3, [sp, #-28]
        @reset substring found flag status to zero for next substring search
        mov     r3, #0
        str     r3, [sp, #-20]
        @ Find next substring in corresponding string
        b       loop_string_substr_scan

end_loop_string_substr_scan:
        @read the PRESENT array memory location for substring values in memory watch
        swi 0x11  @ end of program
        .end
