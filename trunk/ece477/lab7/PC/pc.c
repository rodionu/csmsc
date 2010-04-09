#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include <time.h>
#include <fcntl.h>
#include <string.h>
#include "serial.h"

#define PORT "/dev/ttyUSB0"

/*		while(avrnum!=0){ //When AVRnum = 0, the data has ended
			
			if(avrnum < 0){ //Reading from no data spits back -1
			
				for(retries = 5; retries>0; retries--){
					avrnum = read(filedes, &chr, 1);
			 	}
				if(retries<1) break;	//If you're out of retries, exit
			}
*/
int main(int argc, char **argv){
	
	char chr;
	int filedes;	//File descriptor from init serial port
	int avrnum=0;		//The number returned from the AVR A-D conversion
	int retries;	//Wait time counter
	char buf[64];	//Transmission buffer
	time_t ttime;	//Output from system time (time.h)
	int tflags;

	//Attempt to open serial communications
	filedes = setupserial(PORT);
	if(filedes > 0){
		if((tflags = fcntl(filedes, F_GETFL, 0))==-1){
			tflags = 0;
			fcntl(filedes, F_SETFL, tflags | O_NONBLOCK);
		}
	}	
	else{
		return - 1;
	}

	FILE *out = fopen("vout.txt", "w");
	if(out == NULL){
		perror("DERPED on file derp:");
		return -1;
	}
	fprintf(out, "#      System Time    Battery Voltage\n");
	
	//This is the part that actually makes the measurements
	//It will run until terminated
	while(1){
		bzero(buf, sizeof(buf));	//Zero out the ENTIRE buffer
		ttime = time(NULL);
		sprintf(buf, "%d,",(int) ttime); //Cast ttime to int ***POSSI PROBLEM
	
		write(filedes, buf, strlen(buf)); //Send the comma and time
		bzero(buf, sizeof(buf));	//Zero out the buffer and prep to receive
		avrnum = read(filedes, &chr, 1); //Reads one byte from serial port
		printf("%d\n",avrnum);
			
		printf("%c\n", chr); //Print a byte if byte is read
		strncat(buf, &chr, 1);	//Append the byte to buffer
		avrnum = read(filedes, &chr, 1);	
		
		fprintf(out,"%s\n", buf);
		fflush(out);
		usleep(500000); //Sleep half a second
	}
	fclose(out);
	return 0;		//Successful completion
}
