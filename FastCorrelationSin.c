/*
	C implementation of:
	
	function R = FastCorrelationSin (shift, harmonic, angles, y, meanY);
	
	R needs to be divided by length(y) if compared to correlations of other lengths.
*/

#include "mex.h"
#include "math.h"

void mexFunction( int nargout, mxArray *varargout[],
                  int nargin, const mxArray *varargin[])
{
	mwSize			numElements;
	bool 			argsAreDouble;
	const mwSize	oneByOne[] = {1,1};
	
    if(nargin!=5)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","5 inputs required (shift, harmonic, angles, y, meanY).");

    if(nargout!=1)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:output","One output required.");
    
    argsAreDouble = mxIsDouble(varargin[0]);
    if (!argsAreDouble && !mxIsSingle(varargin[0]))
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","All inputs must be singles or doubles.");
    
    if (argsAreDouble)
    {
    	if (!mxIsDouble(varargin[1]) || !mxIsDouble(varargin[2]) || !mxIsDouble(varargin[3]) || !mxIsDouble(varargin[4]))
        	mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","All inputs must the same type, single or double.");
    }
    else
    {
    	if (!mxIsSingle(varargin[1]) || !mxIsSingle(varargin[2]) || !mxIsSingle(varargin[3]) || !mxIsSingle(varargin[4]))
        	mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","All inputs must the same type, single or double.");
    }
    
	if (mxIsComplex(varargin[0]) || mxIsComplex(varargin[1]) || mxIsComplex(varargin[2]) || mxIsComplex(varargin[3]) || mxIsComplex(varargin[4]))
         mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","All inputs must be real, not complex.");

    if(mxGetM(varargin[2]) != mxGetM(varargin[3]) || mxGetN(varargin[2]) != mxGetN(varargin[3]))
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Inputs angles and y must have the same size.");
    
    numElements = mxGetNumberOfElements(varargin[2]);
    
    if (argsAreDouble)
    {
		double	shift = mxGetScalar(varargin[0]);
		double	harmonic = mxGetScalar(varargin[1]);
		double	*angles = mxGetPr(varargin[2]);
		double	*y = mxGetPr(varargin[3]);
		double	meanY = mxGetScalar(varargin[4]);
		double	sumOfProducts = 0;
		double	sumOfX = 0;
	
		while (numElements-- > 0)
		{
			double xTemp = sin(shift + harmonic * *angles++);
			sumOfX += xTemp;
			sumOfProducts += xTemp * *y++;
		}

		varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
	
		*mxGetPr(varargout[0]) = sumOfProducts - sumOfX * meanY;
    }
    else
    {
		float	shift = *(float*) mxGetData(varargin[0]);
		float	harmonic = *(float*) mxGetData(varargin[1]);
		float	*angles = (float*) mxGetData(varargin[2]);
		float	*y = (float*) mxGetData(varargin[3]);
		float	meanY = *(float*) mxGetData(varargin[3]);
		float	sumOfProducts = 0;
		float	sumOfX = 0;
	
		while (numElements-- > 0)
		{
			float xTemp = sinf(shift + harmonic * *angles++);
			sumOfX += xTemp;
			sumOfProducts += xTemp * *y++;
		}

		varargout[0] = mxCreateNumericArray(1, oneByOne, mxSINGLE_CLASS, mxREAL);
	
		*(float*) mxGetPr(varargout[0]) = sumOfProducts - sumOfX * meanY;
    }
}
