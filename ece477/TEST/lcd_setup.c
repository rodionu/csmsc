#include <stdlib.h>
#include <avr/io.h>
#include <util/delay.h>
#include "lcd_setup.h"

#define E 5;
#define RW 6;
#define RS 7;


void lcd_init(void){
	DDRD = 0xFF;	// enable output for LCD char sending
	//DDRB |= 0xE0;	// enable last 3 bits of PORT B for enable, read/write, etc
	
	/* LCD Initialization for 16166 LCD used */
	_delay_ms(20);
	ELOW();			// Set enable low for starting
	PORTB &= 0x3F;	// 0b00111111
	PORTD = 0x38;	// 0b00111000	// 1, 1 for 8 bit, 1 for 16:1 mux
	EHIGH();
	ELOW();
	_delay_ms(5);
	PORTB &= 0x3F;  // 0b00111111
    PORTD = 0x38;   // 00111000 // 1, 1 for 8 bit, 1 for 16:1 mux
	EHIGH();
	ELOW();
	_delay_ms(1);
	EHIGH();
	ELOW();
//	_delay_ms(1);
//  EHIGH();
//  ELOW();
	_delay_ms(1);
	PORTB &= 0x3F;	// 0b00111111
	PORTD = 0x01;	// 0b00000001	Clear DD RAM and LCD
	EHIGH();
	ELOW();
	_delay_ms(20);
	PORTB &= 0x3F;	// 0b00111111
	PORTD = 0x06;	// 0b00000110	// 1, 1 for increment, 0 for no shift
	EHIGH();
	ELOW();
	_delay_ms(1);
	PORTB &= 0x3F;	// 0b00111111
	PORTD = 0x0E;	// 0b00001100	// 1,1 for Display on, 1 for cursor off
	EHIGH();
	ELOW();
	_delay_ms(10);
}

void ELOW(void){
	PORTB &= 0xDF;	// 0b11011111
}

void EHIGH(void){
	PORTB |= 0x20;	// 0b00100000
}
