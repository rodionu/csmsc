/*****************************************************************
**
** file: ece486_mixer.c
** Description:  Subroutines to implement a (real) mixer in real-time.
**	         Multiple subroutine calls are used to create a signal
**	             y(n) = x(n)c(n)
**	         where x(n) is the nth input sample, and the values of c(n) 
**	         obtained from a (circularly accessed) array of fixed values.
**	         (Typically, the array c(n) is initialize to give samples of a 
**	         cosine or sine function.)
**
** Implementation:
**   Mixers are implemented using three functions:
**     init_mixer() is called once, and is used to initialize the array
**                  of mixer samples c(n), allocate any required memory,
**		    and perform any other required initialization.
**     calc_mixer() is called multiple times -- once for every input sample.
**                  It returns the mixer output sample y(n).
**     destroy_mixer() is called once at the end of the program, and is used
**                  to de-allocate any memory.
**
**  Function Prototypes and parameters:
**
**    	#include "mixer.h"
**	MIXER_PARMS *init_mixer(double *mixer_coefs, int n_coef);
**
**	   Inputs:
**		mixer_coefs	pointer to the array of values for c(n)
**		n_coef  	Number of samples in the array
**	   Returned:
**		The function returns a pointer to a "MIXER_PARMS" data type
**		(which is defined in "mixer.h")
**		
**	double calc_mixer( double x, MIXER_PARMS *s);
**
**	   Inputs:
**		x	Input sample value
**		s	pointer to MIXER_PARMS, as provided by init_mixer()
**	   Returned:
**		The function returns the mixer output sample, x*c(n), where
**		c(n) is obtained from the mixer_coefs array of values.  Each 
**		call to calc_mixer accesses the next sample in the array.  
**		When the end of the array is reached, the index is reset to the
**		beginning of the array.
**		
**  	void destroy_mixer(MIXER_PARMS *s);   
**  	   Inputs:
**	   	s	pointer to MIXER_PARMS, as provided by init_mixer()
**	   No values is returned.
** 
*******************************************************************/ 

#include <stdlib.h>
#include "ece486_mixer.h"

MIXER_PARMS *init_mixer(double *mixer_coefs, int n_coef)
    {
    MIXER_PARMS *result;
    
    result = (MIXER_PARMS *)malloc( sizeof(MIXER_PARMS) );
    result->coefs = mixer_coefs;
    result->n_coef = n_coef;
    result->index = 0;
    
    return(result);
    }

double calc_mixer( double x, MIXER_PARMS *s)
    {
    double y;
    
    y = x * s->coefs[ s->index ];
    s->index += 1;
    if (s->index == s->n_coef) s->index=0;
    
    return(y);
    }

void destroy_mixer(MIXER_PARMS *s)
    {
    free(s);
    }


