#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "atod.h"
#include "printLCD.h"
#include "lcd_setup.h"
#include "m88delay.h"

//uint16_t is 16 bit integer, 32 bit integers can be declared in the same way
//NOTE - 116 ON THE ADC WAS EQUIVALENT TO +1V, some code bits will need changing
//NOTE 2 - All the voltmeters should probably be moved to separate functions


int main(void){
	uint16_t data, looper;
	float decimal;	//Decimal quantity for voltage or current
	char display[24];	//Display up to 24char, including NULL	
	unsigned int i;		//Loop Variables
	int vscale = 1.1;	//Allows single setting of voltage scaling (1.1vref)
	uint16_t acavg[10];	//Used to find AC magnitude and avg
	
	//Set data direction registers
	DDRB = 0b11110000;	//Activates PB1, PB2, PB3 for input
	PORTB = 0b00001111;	//Activate internal pull-up resistors in PB1,2,3
	lcd_init();		//Adds settings to DDRB

	
	if((_BV(PB1))==(_BV(PB2))==(_BV(PB3))) printLCD("Select Mode");
	
	//Running conditions
	//ALL ones from the ADC corresponds to REF voltage (1.1V)
	//Max output from ADC - 0x03FF or 1023, scale to 1.1v
	
	
	//DC Voltmeter uses ADC5 (INPUT STAGE GAIN = 1/200) - output in V
	while(_BV(PB1)==0){		//While PB1 is driven LOW - DC Voltmeter
		data = adconvert(5);
		decimal = data;
		decimal = 200*vscale*(decimal/1024); //This will need calibration
		//Scale ADC output to 200(1.1V), Right shift 10 bits.
		//This line should be correct, but vscale needs to be determined
		
		sprintf(display, "%3.3f V", decimal);	
		
		//PRINT DISPLAY to screen! - needs a function!
		
	}	
	
	//DC Ammeter uses ADC4 (INPUT STAGE GAIN = 1000) - output in terms of mA
	//with 1 ohm probe resistance
	
	while(_BV(PB2)==0){		//While PB2 is driven LOW - DC Ammeter
		data = adconvert(4);
		decimal = data;
		
		data = adconvert(5);
		decimal = data;
		decimal = 1000*vscale*(decimal/1024); //Calibration dependent
		//Scale ADC output to mA, Right shift 10 bits.
		//This line should be correct, but vscale needs to be determined
		sprintf(display, "%5f mA", decimal);	
	
		printLCD(display);	
		
		
	}	
	
	//AC Voltmeter uses ADC3
	while(_BV(PB3)==0){		//While PB3 is driven LOW - AC Voltmeter
		
		for(looper=1; looper!=0; looper++){
			i = looper%10;
			data = adconvert(3);
			if(acavg[i]<data) acavg[i] = data;
		}
		decimal = 0;
		for(i=0; i<10; i++) decimal = decimal+acavg[i];	
	}	decimal /= 10;	//Average of the highest recorded samples
		sprintf(display, "%3.3f V", decimal);
		
		printLCD(display);
}
