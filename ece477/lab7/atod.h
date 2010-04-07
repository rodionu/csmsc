#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*This file contains methods for initializing the A-D converter
 * and making A-D readings, it will return the A-D result as an unsigned int
 */

int adconvert(void);
