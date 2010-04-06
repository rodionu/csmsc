#include <avr/io.h>
//#include <avr/iom8.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void init_serial(void);
void my_send_string (char * buf);

/* this is the equivalent of Hello World for AVR serial communication */
/* it sets up the serial communication for 9600 baud and repeatedly sends */
/* strings containing a long and an int value */
/* it forms the strings using sprintf         */

int main(void){
//	char buf[1];
	char temp;
	init_serial();
	while(1){
		while((UCSR0A&(1<<RXC0)) == 0); // Wait for character input
		temp = UDR0;
		while((UCSR0A&(1<<UDRE0)) == 0); // Wait for release of input
		if(temp > 0x40 && temp < 0x5C){ // If lowercase
			temp += 0x20;               // make capital
		}
		else if(temp > 0x60 && temp < 0x7C){ // If uppercase
			temp -= 0x20; 					 // make lowercase
		}
		while((UCSR0A&(1<<UDRE0)) == 0); //wait until empty 
		UDR0 = temp;					// Print the toggled character
//	sprintf(buf,"The values are:%c\n",temp);
//	my_send_string(buf);
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

