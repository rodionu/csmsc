#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "atod.h"

//uint16_t is 16 bit integer, 32 bit integers can be declared in the same way
//NOTE - 116 ON THE ADC WAS EQUIVALENT TO +1V, some code bits will need changing
//NOTE 2 - All the voltmeters should probably be moved to separate functions


int main(void){
	char measure = 0;
	uint16_t data;
	float decimal;	//Decimal quantity for voltage or current
	char display[24]	//3 Digits, Dot, 3 Digits, NULL termination,
	int i, k;		//Loop Variables
	int vscale = 1.1;	//Mostly a debugging thing, allows us to set voltage
						//scale by reference voltage (default 1.1v)
	
	//Set data direction registers
	DDRB = 0b11110001;	//Activates PB1, PB2, PB3 for input
	PORTB = 0b00001110;	//Activate internal pull-up resistors in PB1,2,3
	DDRD = 0b11111111;	//Set all output for PORTD
	
	if(_BV(PB1)==_BV(PB2)==_BV(PB3)); //PRINT - SELECT MODE
	
	//Running conditions
	//ALL ones from the ADC corresponds to REF voltage (1.1V)
	//Max output from ADC - 0b1111111111 or 1023, scale to 1.1v
	
	
	//DC Voltmeter uses ADC5 (INPUT STAGE GAIN = 1/200) - output in V
	while(_BV(PB1)==0){		//While PB1 is driven LOW - DC Voltmeter
		data = adconvert(5);
		decimal = data;
		decimal = 200*vscale*(decimal/1024); //This will need calibration
		//Scale ADC output to 200(1.1V), Right shift 10 bits.
		//This line should be correct, but vscale needs to be determined
		
		sprintf(display, "%3.3f V", decimal);	
		
		//PRINT DISPLAY to screen! - needs a function!
		//The above lines will have to be replaced (hopefully
		//with something a little more efficient.)	
		
	}	
	
	//DC Ammeter uses ADC4 (INPUT STAGE GAIN = 1000) - output in terms of mA
	//with 1 ohm probe resistance
	
	while(_BV(PB2)==0){		//While PB2 is driven LOW - DC Ammeter
		data = adconvert(4);
		decimal = data;
		
		data = adconvert(5);
		decimal = data;
		decimal = 1000*vscale*(decimal/1024); //This will need calibration
		//Scale ADC output to mA, Right shift 10 bits.
		//This line should be correct, but vscale needs to be determined
		
		
		display[0] = ((int) (decimal)/1000)%10;		//A
		display[1] = ((int) (decimal)/100)%10;		//A/10
		display[2] = ((int) (decimal)/10)%10;		//A/100
		display[3] = ((int) (decimal))%10;			//mA
		display[4] = '\0';	//NULL terminates the string
		
		//PRINT DISPLAY to screen! - needs a function!
		
		
		
	}	
	
	//AC Voltmeter uses ADC3
	while(_BV(PB3)==0){		//While PB3 is driven LOW - AC Voltmeter
		data = adconvert(3);
		decimal = data;
	}	
	
