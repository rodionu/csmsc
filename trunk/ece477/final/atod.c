#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*This file contains methods for initializing the A-D converter
 * and making A-D readings, it will return the A-D result as an unsigned int
 NOTE, this code NO LONGER TRUNCATES THE A/D, IT IS RETURNED AS 16bit INT
 The actual A/D is only 10 bits, so the top 6 are 0
 */

uint16_t adconvert(int adcx){
	uint16_t adclh = 0;	//ADC return value
	int hold;
	//Set internal 1.1v VRef with external capacitor req'd at AREF
    ADMUX = 0b1100000;
	if(adcx < 8) ADMUX |=adcx; //If adcx >7, other bits will be screwed up.
	else return(-1);			//Return -1 if failed due to poor adcx select
	
	//The following actually does the conversion
	PRR &=~(1<<PRADC);
	ADCSRA |=(1<<ADSC);	//ADC Start conversion bit
	while(ADCSRA&_BV(ADSC)); //Wait for A/D Conversion
	//BV does bit value
	
	//ADCL should be read first, reading ADCH re-enables writing to
	//the ADC output registers, so it is done last for safety
	
	hold = ADCL;
	adclh |= ADCH;
	adc1h = adc1h<<8;
	adclh |= hold
	
	return(adc1h);	//return 10 bit ADC in 16 bit signed INT
}

