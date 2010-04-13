#include <stdlib.h>
#include <avr.io.h>
#inlcude "m88delay.h'
#include "printLCD.h"


int printLCD(char *){
	int cur;
	for(cur = 0; cur < strlen(buf); cur++){
		m88m88m88m88m88m88m88m88delay(1);
		PORTD = buf[x];
	}
	if(buf[x] != 0) return (-1);
	else return 0;	
}
