#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "atod.h"
#include "printLCD.h"
#include "lcd_setup.h"
#include "m88delay.h"

//uint16_t is 16 bit integer, 32 bit integers can be declared in the same way
//NOTE - 116 ON THE ADC WAS EQUIVALENT TO +1V, some code bits will need changing
//NOTE 2 - All the voltmeters should probably be moved to separate functions
void init_serial(void);
void my_send_string (char * buf);

int main(void){
	uint16_t data, looper;
	float decimal;	//Decimal quantity for voltage or current
	char buf[16];	//Display up to 24char, including NULL	
	unsigned int i;		//Loop Variables
	int vscale = 1.1;	//Allows single setting of voltage scaling (1.1vref)
	uint16_t acavg[10];	//Used to find AC magnitude and avg
	char input = 0;
	
	//Set data direction registers
	DDRB = 0b11110001;	//Activates PB1, PB2, PB3 for input
	PORTB = 0b00001110;	//Activate internal pull-up resistors in PB1,2,3
	lcd_init();		//Adds settings to DDRB
	
	init_serial();

	while(1){
		if((UCSR0A&(1<<UDRE0)) == 0){	// wait for empty register
			while(input != ','){
				while((UCSR0A&(1<<RXC0)) == 0);// wait for input
				input = UDR0;			// save input
				while((UCSR0A&(1<<UDRE0)) == 0); // Wait for release of input
			}
		while((UCSR0A&(1<<UDRE0)) == 0); //wait until empty
    	  		UDR0 = input; //print a comma]
			decimal = 50.00;
			sprintf(buf, "%f\r\n", decimal); // print value and newline
			my_send_string(buf);
			printLCD(buf);
			}
	}
}

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
