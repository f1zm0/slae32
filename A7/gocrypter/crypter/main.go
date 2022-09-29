package main

import (
	"crypto/rand"
	"flag"
	"fmt"
	"io/ioutil"
	"os"

	"golang.org/x/crypto/chacha20poly1305"
)

const (
	// keysize is the encryption key size (32-bytes = 256-bit)
	keysize = 32
)

func printBytearray(varName string, byteArr []byte) {
	fmt.Printf("%s := []byte{\n", varName)
	for idx, bt := range byteArr {
		if idx%12 == 0 {
			if idx != 0 {
				fmt.Printf("\n    ")
			} else {
				fmt.Printf("    ")
			}
		}

		if bt < 16 {
			fmt.Printf("0x0%x,", bt)
		} else {
			fmt.Printf("0x%x,", bt)
		}
	}
	fmt.Printf("\n}\n\n")
}

func readShellcodeFile(filepath string) []byte {
	shellcodeFile := filepath
	_, err := os.Stat(shellcodeFile)
	if os.IsNotExist(err) {
		panic(err)
	}

	// Read shellcode from file
	shellcode, err := ioutil.ReadFile(shellcodeFile)
	if err != nil {
		panic(err)
	}

	return shellcode
}

func main() {
	var shellcodeFile string

	flag.StringVar(
		&shellcodeFile,
		"i",
		"shellcode.bin",
		"Shellcode file in raw format (default: shellcode.bin)",
	)
	flag.Parse()

	shellcode := readShellcodeFile(shellcodeFile)

	fmt.Println("[+] Generating random 256-bit key ...\n")
	key := make([]byte, keysize)
	if _, err := rand.Read(key); err != nil {
		panic(err)
	}
	printBytearray("key", key[:])

	// XChaCha20-Poly1305 AEAD
	aead, _ := chacha20poly1305.NewX(key[:])

	// Get random nonce and leave space for encrypted shellcode, which will be appended to nonce
	fmt.Println("[+] Generating random nonce ...")
	nonce := make([]byte, aead.NonceSize(), aead.NonceSize()+len(shellcode)+aead.Overhead())
	if _, err := rand.Read(nonce); err != nil {
		panic(err)
	}

	// Encryption (output: nonce+enc_shellcode)
	fmt.Println("[+] Encrypting shellcode ...\n")
	var encSc []byte
	encSc = aead.Seal(nonce, nonce, shellcode, nil)
	printBytearray("scBuf", encSc)
}
