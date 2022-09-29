#include <stdio.h>

unsigned char code[] = \
"";

main() {
    printf("Shellcode length: %d bytes\n", sizeof(code));
    int (*ret)() = (int(*)())code;
    ret();
}
