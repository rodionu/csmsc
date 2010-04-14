#include <stdlib.h>
#include <avr/io.h>
#include <string.h>
#include "lcd_setup.h"
#include "printLCD.h"
#include <util/delay.h>

int printLCD(char *buf){
	int cur;
	for(cur = 0; cur < strlen(buf); cur++){
		PORTB &= 0x3F;	// 0b00111111;
		PORTD = 0x01;	// 0b00000001
		EHIGH();
		ELOW();
		_delay_ms(50);
		PORTB &= 0xBF;	// 0b10111111;
		PORTB |= 0x80;	// 0b10000000;
		PORTD = buf[cur];
		EHIGH();
		ELOW();
		PORTB &= 0x3F;	// 0b00111111;
		PORTD = 0x14;	// 0b00010100;
		EHIGH();
		ELOW();
	}
	return 0;	
}
