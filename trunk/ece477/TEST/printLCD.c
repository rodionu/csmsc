#include <stdlib.h>
#include <avr/io.h>
#include <string.h>
#include "lcd_setup.h"
#include "printLCD.h"
#include <util/delay.h>

//PORTB Pins
//PB7 - RS
//PB6 - R/W
//PB5 - E

int printLCD(char *buf){
	int cur;
	for(cur = 0; cur < strlen(buf); cur++){
		PORTB &= 0x1F;	// 0b00111111;
		PORTD = 0x01;	// 0b00000001
		EHIT();
		_delay_ms(50);
		PORTB &= 0xBF;	// 0b10111111;
		PORTB |= 0x80;	// 0b10000000;
		PORTD = buf[cur];
		EHIT();
		PORTB &= 0x1F;	// 0b00111111;
		PORTD = 0x14;	// 0b00010100;
		EHIT();
	}
	return 0;	
}

int plcd(char *buf){
	int i;
	
	PORTB &= 0x1F; // Clear RS, RW, E
	PORTD = 0x01;	//All data except DB0 = 0;
	EHIT();		//Clock command (CLR DISPLAY)
	
	PORTB &= 0x1F;	//Return cursor to 0x00
	PORTD &= 0x02;	//DB1 = 1
	EHIT();
	
	for(i=0; i<strlen(buf); i++;){
		PORTB |= 0x80; 	//Set RS
		PORTD = buf[i]; //Load character from buffer
		EHIT;		//Print character
	}
