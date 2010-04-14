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
	}
	if(buf[cur] != 0) return (-1);
	else return 0;	
}
