#ifndef __DSP_H__
#define __DSP_H__

// Called before DSP processing occurs..
// count is the number of vals
// vals contain passed command line vaules
// c_buf_size is the capture buffer size in BYTES
//   c_buf_size bytes will be passed to dsp_process() every time.
// Pass values like this:  ./dsp -dsp=123,42,523
void dsp_construct(int count, int * vals, size_t c_buf_size);

// Call (within a loop) to process data.
int dsp_process(short * ibuf, size_t isize, short * obuf, size_t * osize);

// Function receives isize 16 bit signed samples (L+R).
// Even indicies are Left channel, odd indicies are Right channel.
// osize short samples in obuf are played
// osize initially is the size of obuf.  Set osize to number of samples to play
//   before returning.


// Return the actual number of samples (L+R) in obuf or -1 to exit the program.
// ibuf and obuf format - each sample is 16 bits - signed short int in C.
// ----------------------------------------------------------
// | Sample 0 | Sample 1 | Sample 2 | Sample 3 | Sample 4 |
// | Left     | Right    | Left     | Right    | Left     | ... isize samples
// | @ t=0    | @ t=0    | @ t=1/f  | @ t=1/f  | @ t=2/f  |
// ----------------------------------------------------------

// Called after all DSP is done.
void dsp_destroy(void);

#endif
