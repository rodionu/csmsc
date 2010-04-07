#include <avr/io.h>
//#include <avr/iom8.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*This file contains methods for initializing the A-D converter
 * and making A-D readings, it will return the A-D result as an unsigned int
 */

int adconvert(void){
	//ADLAR = ADLAR | 0b00100000; //Set ADLAR Left adjust bit
	//ADMUX &= 0b00010000;	//Leave bit 4 alone
    //ADMUX |= 0b00000101;    //Select AD5 (Pin 28 for A/D conversion)
    ADMUX = 0b11100101; //This performs the job of the above 3 lines

	PRADC = 0;	//Start the conversion, disable Power reduction ADC bit.
	ADSC = 1;	//ADC Start conversion bit
	while(ADSC==1); //Wait for A/D Conversion
	
	return(ADCH);
}	
