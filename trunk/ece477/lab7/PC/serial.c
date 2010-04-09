#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <termios.h>
#include <fcntl.h>
#include <string.h>
#include <netinet/in.h>
int setupserial(char *port){
	int serfd;			//Serial file descriptor (where new term reads/writes)
	struct termios nt;	//New termios structure (New Terminal)

	serfd = open(port, O_RDWR|O_NOCTTY);
	if(serfd==-1){
		printf("Error opening serial communication\n");
		return serfd;	//Return a failure
	//If the serial port could not be opened
	}
	printf("Serial FD %d\n",serfd);
	nt.c_iflag = IGNPAR|~INPCK; //
	nt.c_cflag = CS8|CREAD|CLOCAL; //8 bits, reciever enabled
	nt.c_oflag = nt.c_lflag = 0;
	//Basically, c_oflags and c_lflags will all be disabled.
	//This will make input non-canonical, and not do any of the crazy
	//things that oflags do (such as mapping things to other things, etc)
	//Echo is disabled, as well as extended functions, signals, erase,
	//KILL, etc. 

	cfmakeraw(&nt);	//Set terminal to RAW mode	
	cfsetispeed(&nt, B9600);	//Set input and output lines
	cfsetospeed(&nt, B9600);	//to 9600 baud, Stop bits and parity (none)
								//are already set above.
	
	tcsetattr(serfd, TCSANOW, &nt);
	return serfd;
}
