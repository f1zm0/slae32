#!/bin/bash

# Check if target file is provided
function check_args {
        if [ -z "$1" ]; then
                echo "[!] ERROR. No nasm file provided"
                echo "[!] Usage $0 example.nasm"
                exit 1
        fi

        # Check if target file exists
        if [ ! -f "$1" ]; then
                echo "[!] $1 is not a valid file." 
                exit 1
        fi
}

# Get opcodes from objdump of an ELF file to use as shellcode 
function getopcodes {
    if [ -z "$1" ]; then
        echo "[!] Error. Can't extract opcodes ..."
        echo "[!] You must provide an ELF file as argument"
    else
        objdump -d $1 \
            |  grep '[0-9a-f]:' \
            | grep -v 'file' \
            | cut -f2 -d: \
            | cut -f1-7 -d' ' \
            | tr -s ' ' \
            | tr '\t' ' ' \
            | sed 's/ $//g' \
            | sed 's/ /\\x/g' \
            | paste -d '' -s 
    fi
}


function add_sc {
    cat > run_sc.c <<- EOF
#include <stdio.h>

const unsigned char code[] = \\
"${2}";

int main() {
    int (*ret)() = (int(*)())code;
    printf("Shellcode length: %d bytes\n", sizeof(code));
    ret();
}
EOF
   
}


check_args $1

TARGET_FILE=$(echo $1 | awk -F'.' '{print $(NF-1)}')

echo "[+] Compiling files ..."
echo "   |- Assembling NASM file ..."
nasm -f elf32 -o $TARGET_FILE.o $TARGET_FILE.nasm

echo "   |- Linking object file ..."
ld -o $TARGET_FILE $TARGET_FILE.o
echo "   |- ELF file saved to: $TARGET_FILE"

echo "   |- Parsing ELF dump to extract opcodes ..." 
OPCODES=$(getopcodes $TARGET_FILE)
echo $OPCODES > opcodes.txt

echo "   |- Adding shellcode buffer to C shellcode tester ..."
add_sc ./run_sc.c $OPCODES

echo "   |- Compiling the tester file ..."
gcc -w -O2 run_sc.c -o run_sc

echo -e "\nDone! Output file: ./run_sc"
