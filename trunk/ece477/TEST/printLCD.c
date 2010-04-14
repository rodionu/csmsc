#include <stdlib.h>
#include <avr/io.h>
#include <string.h>
#include "lcd_setup.h"
#include "m88delay.h"
#include "printLCD.h"


int printLCD(char *buf){
	int cur;
	for(cur = 0; cur < strlen(buf); cur++){
		m88delay(1);
		PORTB &= 0b10111111;
		PORTD = buf[cur];
		EHIGH();
		ELOW();
		PORTB &= 0b00111111;
		PORTD = 0b00010100;
		EHIGH();
		ELOW();
	}
	else return 0;	
}