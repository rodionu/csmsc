#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <termios.h>
#include <fcntl.h>
#include <string.h>
#include <netinet/in.h>

int main(void){
	FILE *vout;
	if(vout=fopen(vout.txt, "w") == NULL){
		printf("File access error\n");
		exit(0);
	}

	if(setupserial("COM1"));
	else{
		printf("Serial Initialization Failure\n");
		exit(1);
	}
	

}

	








char setupserial(char *arg){ //Not entirely sure what this does
	char err = 0;			//Or even how it works
	struct termios newio;	//This was ported from lab4 with very
	int fd;					//little modification, removed mode

	fd = open(arg, O_RDWR|O_NOCTTY);
	if(fd == -1){
	err++;
	
	tcgetattr(fd, &newio);

	newio.c_iflag = IGNPAR | ~INPCK ;
	newio.c_oflag = 0;
	newio.c_cflag = CS8 | CREAD | CLOCAL;
	newio.c_lflag =0 ;

	cfmakeraw(&newio);

	cfsetispeed(&newio, B9600);
	cfsetispeed(&newio, B9600);

	int i = tcsetattr(fd, TCSANOW, &newio);
	if(i == -1) err++;
	}
	return err;
}
