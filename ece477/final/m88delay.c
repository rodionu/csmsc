//The 8MHz/8000 = 1000 cycles/second, compare statements likely take
//more than just one cycle to execute, so this is actually around
//a 1-2ms delay as it is now.

void m88delay(unsigned int ms){
	uint16_t x = 0;
	for(ms; ms>0; ms--){
		for(x=0; x<5000; x++);
	}
}
