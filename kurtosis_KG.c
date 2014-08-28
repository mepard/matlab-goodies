/*
	C implementation of:
	
	function [y, m, m2, m4] = kurtosis_KG (x)
		m = mean(x);
		x = x - m;
		m2 = mean(x.^2);
		m4 = mean(x.^4);
    	y = m4 / (m2^2) / 3;
*/

#include "mex.h"

void mexFunction( int nargout, mxArray *varargout[],
                  int nargin, const mxArray *varargin[])
{
    if(nargin != 1)
        mexErrMsgIdAndTxt("Horizon:kurtosis_dBG:input","One input required.");

    if(!mxIsDouble(varargin[0]))
        mexErrMsgIdAndTxt("Horizon:kurtosis_dBG:input","Input x must be a double array.");
    
    if(nargout < 0 || nargout > 4)
        mexErrMsgIdAndTxt("Horizon:kurtosis_dBG:output","1 - 4 outputs required.");
    
    {
		const mwSize	numElements = mxGetNumberOfElements(varargin[0]);
		double			*x0 = mxGetPr(varargin[0]);
		double			meanX = 0;
		double			meanXpow2 = 0;
		double			meanXpow4 = 0;

		mwSize			n = numElements;
		double			*x = x0;
		while (n-- > 0)
			meanX += *x++;
		
		meanX = meanX/(double) numElements;
		
		x = x0;
		n = numElements;
		while (n-- > 0)
		{
			double	tempX = *x++ - meanX;
			double	xPow2 = tempX*tempX;
			meanXpow2 += xPow2;
			meanXpow4 += xPow2*xPow2;
		}
		
		meanXpow2 = meanXpow2/(double) numElements;
		meanXpow4 = meanXpow4/(double) numElements;

		varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
		*mxGetPr(varargout[0]) = (meanXpow4/(meanXpow2*meanXpow2))/3.0;
		if (nargout > 1)
		{
			varargout[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
			*mxGetPr(varargout[1]) = meanX;
		}
		if (nargout > 2)
		{
			varargout[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
			*mxGetPr(varargout[2]) = meanXpow2;
		}
		if (nargout > 3)
		{
			varargout[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
			*mxGetPr(varargout[3]) = meanXpow4;
		}
    }
}
