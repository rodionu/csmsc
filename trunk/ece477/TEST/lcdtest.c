#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "atod.h"
#include "printLCD.h"
#include "lcd_setup.h"
#define F_CPU 10000000UL

void init_serial(void);
void my_send_string (char * buf);

int main(void){
	int i = 0;
	char buf[16];
	char temp;
	init_serial();
	lcd_init();
	while(1){
		while((UCSR0A&(1<<RXC0)) == 0); // Wait for character input
		temp = UDR0;
		while((UCSR0A&(1<<UDRE0)) == 0); // Wait for release of input
		
		if(temp == ','){
			buf[i] = '\0';			
			my_send_string(buf);
			printLCD(buf);
			i = 0;		//Reset indexer
		}	
		else{
			buf[i] = temp;
			i++;
		}
	}
}



void init_serial(void){
	UBRR0H=0;
	UBRR0L=51; // 9600 BAUD FOR 1MHZ SYSTEM CLOCK
	UCSR0C= (1<<UMSEL01)|(1<<USBS0)|(3<<UCSZ00) ;  // 8 BIT NO PARITY 2 STOP
	UCSR0B=(1<<RXEN0)|(1<<TXEN0)  ; //ENABLE TX AND RX ALSO 8 BIT
}   
void my_send_string(char * buf){
	int x;  //uses software polling, assumes serial is set up
    for(x=0;x<strlen(buf);x++){
    	while((UCSR0A&(1<<UDRE0)) == 0); //wait until empty 
		UDR0 = buf[x];
   }
}
