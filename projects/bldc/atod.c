#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*This file contains methods for initializing the A-D converter
 * and making A-D readings, it will return the A-D result as an unsigned int
 */

unsigned int adconvert(int adselect){
    	ADMUX = 0b11100000; 	//Internal 1.1vRef, Left shift enabled
	ADMUX |= adselect;	//Select A/D to use

	PRR &=~(1<<PRADC);
	ADCSRA |=(1<<ADSC);	//ADC Start conversion bit
	while(ADCSRA&_BV(ADSC)); //Wait for A/D Conversion
	//BV does bit value
	return(ADCH);	//return most sig. 8 bits.
}

