 #include <avr/io.h>
#include <avr/iom8.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>

int step_val=0;
int compare_val=0;
char int_counter=0;
char increment=1;

void init_pwm(void);
void init_serial(void);

int main(void) {
init_pwm();
init_serial();

TIMSK=4; //TOV1
sei();   //enable interrupts

 while(1) 
 {
   while((UCSRA&(1<<RXC)) == 0);  //WAIT FOR CHAR
   UDR = UDR+1;
   while((UCSRA&(1<<UDRE)) == 0); //wait until empty (not necessary)
}   
 return 0;
}


ISR(TIMER1_OVF_vect)
{
 int_counter++;
 if(int_counter>1)
 {
   int_counter=0;
   if(step_val>=100) increment = -1;

   if(step_val<=0) increment = 1;

   step_val+=increment;
   compare_val=step_val*step_val;
   OCR1A=compare_val;
 }
}

 void init_pwm(void)
 {
    DDRB=2;  //make led output
    OCR1A=0;
    //Output compare OC1A 8 bit non inverted PWM
    TCCR1A=0xc0;  //inverted on A, nothing on B PWM mode 8
    //start timer without prescaler
    TCCR1B=0x11; //internal clock, no prescaler , PWM mode 8
    ICR1=10000;  //brightness levels from 0-100 control rms (steps are squares)
    }

 void init_serial(void)
 {
    UBRRH=0;
    UBRRL=12; // 4800 BAUD FOR 1MHZ SYSTEM CLOCK
    UCSRC= (1<<URSEL)|(1<<USBS)|(3<<UCSZ0) ;  // 8 BIT NO PARITY 2 STOP
    UCSRB=(1<<RXEN)|(1<<TXEN)  ; //ENABLE TX AND RX ALSO 8 BIT
 }    
