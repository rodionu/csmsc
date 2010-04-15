#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include <time.h>
#include <fcntl.h>
#include <string.h>
#include "serial.h"

#define PORT "/dev/ttyUSB1"

int main(int argc, char **argv){
	
	unsigned char chr;
	int filedes;	//File descriptor from init serial port
	int avrnum=0;
	char buf[64];	//Transmission buffer
	time_t ttime;	//Output from system time (time.h)
	int tflags;
	double voltage;
	//Attempt to open serial communications
	filedes = setupserial(PORT);
	printf("setupserial done");
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
		 //Reads one byte from serial port
		avrnum = read(filedes, &chr, 1); // save recieved measurement to chr
		if(avrnum == 0) break;	// break if it failed
		strncat(buf, &chr, 1);  // add the measurement to current string
		
		printf("THIS IS WORKING %d\n",ttime);	
		
		if(chr!=44){
			voltage = (double) chr/117;		//If comma not returned
			fprintf(out, "%lf\n", voltage);	//Print just voltage
		}	
		else fprintf(out,"%d,",(int) ttime);	// print data 
		fflush(out);

		usleep(500000); //Sleep half a second
	}
	fclose(out);
	return 0;		//Successful completion
}
