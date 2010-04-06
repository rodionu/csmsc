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
	char buf[25];	// buffer for strings to print
	char win=1;		// win condition
    char i;
	char j = 5;		// Number of numbers in the sequence
	char simon[j] = 0;	// number sequence
	init_serial();
	while(1){
		for(i = 0; i < j; i++){     // Assign each int a position number
	        simon[i] = rand() % 10;	// set up the sequence
		}	
		for(i = 0; i < j; i++){		// Print the pattern for user to see
			UDR = simon[i];
		}
		// Clear Screen?
		for(i = 0; i < j; i++){
			while((UCSR0A&(1<<RXC0)) == 0); // Wait for character input
	        temp = UDR;						// Get character pressed
    	    while((UCSR0A&(1<<UDRE0)) == 0); // Wait for release of input
			if(win != (simon[i] == temp-0x30)) break;	// If correct number
		}											// loop else break
		if(win){
			sprintf(buf,"You Win This Round\n");	// If win true, Player wins
			my_send_string(buf);
		}
		else{
			sprintf(buf,"You Lose\n");					// If win = 0, player loses
			my_send_string(buf);
		}
		sprintf(buf,"Play Again?(N/n=no)\n");				// Play Again? print
		my_send_string(buf);
		while((UCSR0A&(1<<RXC0)) == 0); // Wait for character input
        temp = UDR;
        while((UCSR0A&(1<<UDRE0)) == 0); // Wait for release of input
		if(temp == 'N' || temp == 'n') break;	//If no quit, else start over
	}
	return 1;		
//	sprintf(buf,"The values are:%c\n",temp);
//	my_send_string(buf);
}

/* Initializes AVR USART for 9600 baud (assuming 8MHz clock) */
/* 1MHz/(16*(12+1)) = 4808                                   */
/* 8Mhz/(16*(x+1)) = 9600 --> x = 51.083 -> Rounding: x = 51 */

void init_serial(void){
	UBRR0H=0;
	UBRR0L=51; // 9600 BAUD FOR 8MHZ SYSTEM CLOCK
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
		UDR = buf[x];
   }
}

