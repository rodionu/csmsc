#include <stdlib.h>
#include <avr/io.h>
#include "lcd_init.h"
#include "m88delay.h"

#define E 5;
#define RW 6;
#define RS 7;


void lcd_init(void){
	DDRD = 0xFF;	// enable output for LCD char sending
	DDRB = 0xE0;	// enable last 3 bits of PORT B for enable, read/write, etc
	
/* LCD Initialization for 16166 LCD used */
	m88delay(20);
	ELOW();			// Set enable low for starting
	PORTB |= (0<<RS)|(0<<RW); // SEE TABLE
	PORTD = 0x38;	// 00111000	// 1, 1 for 8 bit, 1 for 16:1 mux
	EHIGH();
	ELOW();
	m88delay(10);
	EHIGH();
	ELOW();
	m88delay(1);
	EHIGH();
	ELOW();
	m88delay(1);
	PORTD = 0x01;	// Clear DD RAM and LCD
	EHIGH();
	ELOW();
	m88delay(20);
	PORTD = 0x06;	// 00000110	// 1, 1 for increment, 0 for no shift
	EHIGH();
	ELOW();
	m88delay(1);
	PORTD = 0x0C;	// 00001100	// 1,1 for Display on, 0 for cursor off
	m88delay(10);
}

void ELOW(void);
	PORTB &= (0<<E);
}

void EHIGH(void);
	PORTB &= (1<<E);
}
