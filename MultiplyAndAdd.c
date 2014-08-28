/*
	C implementation of:
	
	function sum = MultiplyAndAdd (x, y);
*/

#include "mex.h"

void mexFunction( int nargout, mxArray *varargout[],
                  int nargin, const mxArray *varargin[])
{
	mwSize	numElements;
	
    if(nargin!=2)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","2 inputs required.");

    if(nargout!=1)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:output","One output required.");
    
    if( !mxIsDouble(varargin[0]))
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Input x must be a double array.");
    
    if( !mxIsDouble(varargin[1]))
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Input y must be a double array.");
    
	if ((mxIsComplex(varargin[0])) != mxIsComplex(varargin[1]))
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Inputs x and y must both be complex or both real.");

    if(mxGetM(varargin[0]) != mxGetM(varargin[1]) || mxGetN(varargin[0]) != mxGetN(varargin[1]) )
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Inputs x and y must have the same size.");
    
    numElements = mxGetNumberOfElements(varargin[0]);
    
    if (mxIsComplex(varargin[0]))
    {
		double	*xr = mxGetPr(varargin[0]);
		double	*xi = mxGetPi(varargin[0]);
		double	*yr = mxGetPr(varargin[1]);
		double	*yi = mxGetPi(varargin[1]);
		double	sumr = 0;
		double	sumi = 0;

		while (numElements-- > 0)
		{
			sumr += *xr++ * *yr++;
			sumi += *xi++ * *yi++;
		}
		varargout[0] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
		
		*mxGetPr(varargout[0]) = sumr;
		*mxGetPi(varargout[0]) = sumi;
    }
    else
    {
		double	*x = mxGetPr(varargin[0]);
		double	*y = mxGetPr(varargin[1]);
		double	sum = 0;

		while (numElements-- > 0)
			sum += *x++ * *y++;
	
		varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
		
		*mxGetPr(varargout[0]) = sum;
    }
}
