#include <avr/io.h>
//#include <avr/iom8.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "atod.h"

void init_serial(void);
void my_send_string (char * buf);

/* this is the equivalent of Hello World for AVR serial communication */
/* it sets up the serial communication for 9600 baud and repeatedly sends */
/* strings containing a long and an int value */
/* it forms the strings using sprintf         */

int main(void){
	char buf[50];
	int input = 0;
	double measure = 0;
	init_serial();
	while(1){
		if((UCSR0A&(1<<UDRE0)) == 0){	// wait for empty register
			while(input != ','){
				while((UCSR0A&(1<<RXC0)) == 0);// wait for input
				input = UDR0;			// save input
				while((UCSR0A&(1<<UDRE0)) == 0); // Wait for release of input
			}
			while((UCSR0A&(1<<UDRE0)) == 0); //wait until empty
      		UDR0 = input; //print a comma
			measure = 11 * ((double) adconvert() / 255); // get voltage 
			sprintf(buf, "%lf\r\n", measure); // print value and newline
			my_send_string(buf);
			}
	}
}

/* Initializes AVR USART for 9600 baud (assuming 8MHz clock) */
/* 1MHz/(16*(12+1)) = 4808                                   */
/* 8Mhz/(16*(x+1)) = 9600 --> x = 51.083 -> Rounding: x = 51 */

void init_serial(void){
	UBRR0H=0;
	UBRR0L=51; // 9600 BAUD FOR 1MHZ SYSTEM CLOCK
	UCSR0C= (1<<UMSEL01)|(1<<USBS0)|(3<<UCSZ00) ;  // 8 BIT NO PARITY 2 STOP
	UCSR0B=(1<<RXEN0)|(1<<TXEN0)  ; //ENABLE TX AND RX ALSO 8 BIT
}   
	
/* simple routine to use software polling to send a string serially */
/* waits for UDRE (USART Data Register Empty) before sending byte   */
/* uses strlen to decide how many bytes to send (must have null     */
/* terminator on the string)                                        */

void my_send_string(char * buf){
	int x;  //uses software polling, assumes serial is set up
    for(x=0;x<strlen(buf);x++){
    	while((UCSR0A&(1<<UDRE0)) == 0); //wait until empty 
		UDR0 = buf[x];
   }
}

