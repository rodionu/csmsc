/*
** DPSK Modulator. 
**
**   Creates an acoustic DPSK modulated signal for a fixed data sequence.  
**   The modulated signal is created on the left "line-out" channel of the 
**   soundcard.  The right "line-out" channel provides a 5 msec pulse at the
**   at the beginning of the data sequence.  The data sequence is repeated
**   until program execution ends.
**
**   The implementation assumes:
**      Fs = 48 ksps sample rate
**   	500 bits/sec data rate (2 msec/bit... or 96 samples/bit)
**      12.5 kHz carrier  (default)
**
**   "dsp486 -dsp=n" 
**	Terminates execution after nnnn processed buffers of data.
** 	default: n=5000
**
**   "dsp486 -dsp=n,k,m"
**      Generates the DPSK waveform using a carier freqency of (k/m)Fs, and 
**   	terminates execution after n buffers of data.
**	default: n=5000, k=25, m=96 (giving a 12.5 kHz carrier)
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "ece486_mixer.h"
#include "dsp.h"

static int cmax=5000;	/* Default number of buffers processed. */
static int k=25,m=96;   /* Default carrier freq = (25/96)*48000=12.5 kHz */

static int data[] = {
    1,1,0,0,1,0,1,0,0,1,
    1,0,0,0,1,0,0,1,1,1,
    0,0,0,0,0,1,1,1,0,1,
    0,0,1,1,0,0,1,0,1,1,
    0,0,0,0,1,0,1,0,0,1};
static int data_L = 50;
static int data_ind = -1;	/* First transmit a "start bit"*/
static double phase = 10000.0;	/* Transmit +/- 10000 cos(2 pi f0 n) */

/*
** bit_period == # samples per data bit
**  based on 1000 bits/sec at 48 ksps
*/
static int bit_period=48;
static int bit_cnt = 0;

/*
** Mixer parms are static, so that information is saved from init call
** to the dsp_process() call
*/
static MIXER_PARMS *cos_mix;
static double *cos_table;
static const double pi=3.1415926535897932384626;

void dsp_construct(int count, int * vals, size_t c_buf_size)
{
    int i;
    
    /*
    ** Overide defaluts if parameter values are specified.
    */
    if (count>=1) cmax=vals[0];
    if (count==3) {
        k = vals[1];
	m = vals[2];
	}
    if (count==2 || count > 3)
        {
	fprintf(stderr,"Usage: dsp486 \n");
	fprintf(stderr,"       dsp486 -dsp=n \n");
	fprintf(stderr,"       dsp486 -dsp=n,k,m \n");
	fprintf(stderr,"       where n is the number of input buffers processed,\n");
	fprintf(stderr,"       and 48000*k/m is the DPSK Carrier Frequency\n");
	fprintf(stderr,"       (Using Defaults: n=5000, k=25, m=96)\n");
	}

    /*
    ** Mixer initialization.
    */
    cos_table = (double *) malloc( m * sizeof(double) );
    for (i=0; i<m; i++) cos_table[i] = cos(2*pi*k*i/m);
    cos_mix = init_mixer( cos_table, m );

    return;
}

// Process the audio
int dsp_process(short * ibuf, size_t isize, short * obuf, size_t * osize)
{
	int i;
	static int count=0;

	for (i=0;i<isize;i+=2) {	/* Left channel input */
		bit_cnt++;
		if (bit_cnt == bit_period)   /* Time for the next bit? */
		    {
		    bit_cnt = 0;
		    data_ind ++;	

		    if (data_ind == data_L)  /* End of the bit array? */
			data_ind = 0;
			
		    if (data[data_ind] == 0) 
			phase *= -1;	/* 180 degree phase shift indicates 0 */
			
		    }
		/*
		** Left channel: DPSK Modulator output
		*/
		obuf[i]=calc_mixer( phase, cos_mix); 
		
		/*
		** Right channel: sync pulse indicating start of bit sequence.
		*/
		obuf[i+1] = 0;
		if (data_ind == 0) obuf[i+1] = 10000;
	}
	

	count++;		/* Running count of buffers processed */
	if (count>cmax) {
		return -1;	
	}

	// Set the number of output samples.
	*osize=isize;
	return *osize;
}

// Cleanup after finishing processing.
void dsp_destroy(void)
{
	destroy_mixer(cos_mix);
	free(cos_table);
	return;
}
