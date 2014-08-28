/* 

Function to check the performance hit from calling utIsInterruptPending()

function output = testUserInterrupt (checkForInterrupt, numIterations)

Be sure to specify the ut library when you compile:

mex testUserInterrupt.c -lut

To test the performance of utIsInterruptPending:

>> tic; testUserInterrupt(true,1e9); toc
Elapsed time is 5.333569 seconds.
>> tic; testUserInterrupt(false,1e9); toc
Elapsed time is 2.713040 seconds.

*/

#include "mex.h"

// utIsInterruptPending is an unsupported, but commonly used function.
//
#ifdef __cplusplus 
    extern "C" bool utIsInterruptPending();
#else
    extern bool utIsInterruptPending();
#endif

void mexFunction( int nargout, mxArray *varargout[],
                  int nargin, const mxArray *varargin[])
{
    if(nargin != 2)
        mexErrMsgIdAndTxt("Horizon:testUserInterrupt:input","Two inputs required.");

    if (!mxIsLogicalScalar(varargin[0]))
        mexErrMsgIdAndTxt("Horizon:testUserInterrupt:input","Input checkForInterrupt must be a logical scalar.");
    
    if(!mxIsDouble(varargin[1]) || mxGetNumberOfElements(varargin[1]) != 1)
        mexErrMsgIdAndTxt("Horizon:testUserInterrupt:input","Input numIterations must be a double scaler.");
    
    if(nargout > 1)
        mexErrMsgIdAndTxt("Horizon:testUserInterrupt:output","Horizon:testUserInterrupt produces only one output.");
    
    {
		const bool		checkForInterrupt = mxIsLogicalScalarTrue(varargin[0]);
		const double	numIterations = mxGetScalar(varargin[1]);
		double			output = 0.0;
		
		if (checkForInterrupt)
		{
			double i;
			for (i = 1.0; i <= numIterations; ++i)
			{
				output += i*i;	// Anything to kill time.
				if (utIsInterruptPending())
					break;	
			}
		}
		else
		{
			double i;
			for (i = 1.0; i <= numIterations; ++i)
			{
				output += i*i;	// Anything to kill time.
			}
		}
		if (nargout > 0)
			varargout[0] = mxCreateDoubleScalar(output);
	}
}
