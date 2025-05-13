/*** asmEncrypt.s   ***/

#include <xc.h>

/* Declare the following to be in data memory */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Desiree Werner"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them */
/* (in this lab we return the pointer, so strictly speaking, */
/* does not really need to be defined as global) */
/* .global cipherText */
.type cipherText,%gnu_unique_object

.align
 
@ NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
@ TODO: create a .h file that handles both C and assembly syntax for this definition
.equ CIPHER_TEXT_LEN, 200
 
/* space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    LDR r2, =cipherText       @ r2 = pointer to destination (cipherText)
    MOV r3, r0                @ r3 = pointer to input string (source)
    MOV r4, r1                @ r4 = key (K)

loop:
    LDRB r5, [r3], #1         @ Load byte from input, then increment r3
    CMP r5, #0                @ Check for NULL terminator
    BEQ done                  @ If NULL, we're done

    @ Check for 'A' to 'Z'
    MOV r6, r5
    SUB r6, r6, #'A'          @ r6 = char - 'A'
    CMP r6, #25
    BLS upper_case            @ If <= 25, it's uppercase

    @ Check for 'a' to 'z'
    MOV r6, r5
    SUB r6, r6, #'a'
    CMP r6, #25
    BLS lower_case            @ If <= 25, it's lowercase

    @ Not alphabetic, copy as-is
    STRB r5, [r2], #1
    B loop

upper_case:
    ADD r6, r6, r4            @ Shift by key
    MOV r7, #26
    UDIV r8, r6, r7           @ Get quotient (not needed)
    MLS r6, r8, r7, r6        @ r6 = r6 - (quotient * 26) => modulo 26
    ADD r6, r6, #'A'          @ Convert back to char
    STRB r6, [r2], #1
    B loop

lower_case:
    ADD r6, r6, r4
    MOV r7, #26
    UDIV r8, r6, r7
    MLS r6, r8, r7, r6
    ADD r6, r6, #'a'
    STRB r6, [r2], #1
    B loop

done:
    MOV r5, #0                @ Null terminator
    STRB r5, [r2]             @ Store NULL at the end of cipherText

    LDR r0, =cipherText       @ Return pointer to cipherText in r0


    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    /* restore the caller's registers, as required by the ARM calling convention */
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




