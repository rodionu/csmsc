#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "atod.h"
#include "printLCD.h"
#include "lcd_setup.h"

int main(void){
	uint16_t data, looper;
	double decimal;	//Decimal quantity for voltage or current
	unsigned char display[8]={'\0'};	//Display up to 24char, including NULL	
	unsigned int i;		//Loop Variables
	int vscale = 1.1;	//Allows single setting of voltage scaling (1.1vref)
	uint16_t acavg[10];	//Used to find AC magnitude and avg
	
	//Set data direction registers
	DDRB = 0b11110000;	//Activates PB1, PB2, PB3 for input
	PORTB = 0b00001111;	//Activate internal pull-up resistors in PB1,2,3
	lcd_init();		//Adds settings to DDRB
	

while(1){

	while((PINB&0x07) == 7){
		sprintf(display, "NO INPUT");
		printLCD(display);
		_delay_ms(1000);
	}
	//Running conditions
	//ALL ones from the ADC corresponds to REF voltage (1.1V)
	//Max output from ADC - 0x03FF or 1023, scale to 1.1v
	
	
	//DC Voltmeter uses ADC5 (INPUT STAGE GAIN = 1/200) - output in V
	while((PINB&_BV(PB0))==0){		//While PB1 is driven LOW - DC Voltmeter
		data = adconvert(3);
		decimal = data;
		decimal = 200*vscale*decimal/255; //This will need calibration
		//Scale ADC output to 200(1.1V), Right shift 10 bits.
		//This line should be correct, but vscale needs to be determined		

		display[0] = (unsigned char) (decimal/100)%10+'0'; //100V		
		display[1] = (unsigned char) (decimal/10)%10+'0'; //10V		
		display[2] = (unsigned char) (decimal)%10+'0'; //1v
		display[3] = '.';		
		display[4] = (unsigned char) (decimal*10)%10+'0'; //1/10v	
		display[5] = (unsigned char) (decimal*100)%10+'0'; //1/100v
		display[6] = 'V';
		display[7] = '\0';
		printLCD(display);	
		_delay_ms(3000);
	}	
	
	//DC Ammeter uses ADC4 (INPUT STAGE GAIN = 1) - output in terms of mA
	//with 1 ohm probe resistance
	
	while((PINB&_BV(PB1))==0){		//While PB2 is driven LOW - DC Ammeter
		data = adconvert(4);
		decimal = data;
		
		decimal = 1000*vscale*(decimal/1024); //Calibration dependent
		//Scale ADC output to mA, Right shift 10 bits.
		//This line should be correct, but vscale needs to be determined
		display[0] = (unsigned char) (decimal/1000)%10+'0'; //1000mA		
		display[1] = (unsigned char) (decimal/100)%10+'0'; //100mA		
		display[2] = (unsigned char) (decimal/10)%10+'0'; //10mA
		display[4] = (unsigned char) (decimal)%10+'0'; //1mA	
		display[5] = 'm';
		display[6] = 'A';
		display[7] = '\0';	
		printLCD(display);	
		_delay_ms(3000);
	}	

	
	//AC Voltmeter uses ADC3
	while((PINB&_BV(PB2))==0){		//While PB3 is driven LOW - AC Voltmeter
		
		for(looper=1; looper!=0; looper++){
			i = looper%10;
			data = adconvert(3);
			if(acavg[i]<data) acavg[i] = data;
		}
		decimal = 0;
		for(i=0; i<10; i++) decimal = decimal+acavg[i];	
		decimal /= 10;	//Average of the highest recorded samples
		display[0] = (unsigned char) (decimal/100)%10+'0'; //100V		
		display[1] = (unsigned char) (decimal/10)%10+'0'; //10V		
		display[2] = (unsigned char) (decimal)%10+'0'; //1v
		display[3] = '.';		
		display[4] = (unsigned char) (decimal*10)%10+'0'; //1/10v	
		display[5] = (unsigned char) (decimal*100)%10+'0'; //1/100v
		display[6] = '~';		
		display[7] = '\0';
		printLCD(display);	
		_delay_ms(3000);
		
		printLCD(display);
	}
}
}
