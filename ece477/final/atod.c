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

/*int adconvert(void){
	//ADLAR = ADLAR | 0b00100000; //Set ADLAR Left adjust bit
	//ADMUX |= 0b00000101;    //Select AD5 (Pin 28 for A/D conversion)
	ADMUX = 0b11100101; //This performs the job of the above 3 lines

	PRR &=~(1<<PRADC);
	ADCSRA |=(1<<ADSC); //ADC Start conversion bit
	while(ADCSRA&_BV(ADSC)); //Wait for A/D Conversion
	//BV does bit value
	return(ADCH);   //return most sig. 8 bits.
}

*/


uint16_t adconvert(int adcx){
	uint16_t adclh = 0;	//ADC return value
	int hold;
	//Set internal 1.1v VRef with external capacitor req'd at AREF
	ADMUX = 0b11000000;
	ADMUX |=adcx; //If adcx >7, other bits will be screwed up.
	
	//The following actually does the conversion
	PRR &=~(1<<PRADC);
	ADCSRA |=(1<<ADSC);	//ADC Start conversion bit
	while(ADCSRA&_BV(ADSC)); //Wait for A/D Conversion
	//BV does bit value
	
	//ADCL should be read first, reading ADCH re-enables writing to
	//the ADC output registers, so it is done last for safety
	
	hold = ADCL;
	adclh = ADCH;
	adclh = adclh<<8;
	adclh |= hold;
	
	return(500);	//return 10 bit ADC in 16 bit signed INT
}
