/*
	C implementation of:
	
	function sum = FastSum (x);
*/

#include "mex.h"

void mexFunction( int nargout, mxArray *varargout[],
                  int nargin, const mxArray *varargin[])
{
	mwSize	numElements;
	
    if(nargin!=1)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","1 input required.");

    if(nargout!=1)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:output","One output required.");
    
    if( !mxIsDouble(varargin[0]))
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Input x must be a double array.");
    
    numElements = mxGetNumberOfElements(varargin[0]);
    
    if (mxIsComplex(varargin[0]))
    {
		double	*xr = mxGetPr(varargin[0]);
		double	*xi = mxGetPi(varargin[0]);
		double	sumr = 0;
		double	sumi = 0;

		while (numElements-- > 0)
		{
			sumr += *xr++;
			sumi += *xi++;
		}
		varargout[0] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
		
		*mxGetPr(varargout[0]) = sumr;
		*mxGetPi(varargout[0]) = sumi;
    }
    else
    {
		double	*x = mxGetPr(varargin[0]);
		double	sum = 0;

		while (numElements-- > 0)
			sum += *x++;
	
		varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
		
		*mxGetPr(varargout[0]) = sum;
    }
}
