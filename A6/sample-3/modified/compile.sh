#!/bin/bash


function getopcodes {
    if [ -z "$1" ]; then
        echo "[!] Error. You must provide an ELF file as argument"
        echo "Usage: getopcodes <ELF_file>"
    else
        objdump -d $1 \
            |  grep '[0-9a-f]:' \
            | grep -v 'file' \
            | cut -f2 -d: \
            | cut -f1-6 -d' ' \
            | tr -s ' ' \
            | tr '\t' ' ' \
            | sed 's/ $//g' \
            | sed 's/ /\\x/g' \
            | paste -d '' -s  \
            | sed 's/^/"/' \
            | sed 's/$/"/g'
    fi
}


function check_script_args {
    if [ -z "$1" ]; then
        echo "[!] ERROR. No nasm file provided"
        echo "[!] Usage $0 example.nasm"
        exit 1
    fi
}

function check_file_exists {
    if [ ! -f "$1" ]; then
        echo "[!] $1 is not a valid file."
        exit 1
    fi
}


# Check if target file is provided
check_script_args $1

# Check if target file exists
check_file_exists $1


TARGET_FILE=$(echo $1 | awk -F'.' '{print $(NF-1)}')

echo "[*] Assembling NASM file ..."
nasm -f elf32 -o $TARGET_FILE.o $TARGET_FILE.nasm

echo "[*] Linking object file ..."
ld -N -o $TARGET_FILE $TARGET_FILE.o

echo "[*] Done! ELF file saved to: $TARGET_FILE"

echo "=============================================="
echo "[*] Shellcode:"
echo ""
getopcodes $TARGET_FILE

