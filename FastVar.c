/*
	C implementation of:
	
	function variance = FastVar (x);
*/

#include "mex.h"
#include <math.h>

void mexFunction( int nargout, mxArray *varargout[],
                  int nargin, const mxArray *varargin[])
{
	bool		xIsDouble;
	
	if(nargin!=1)
        mexErrMsgIdAndTxt("Horizon:FastVar:input","1 input required.");

    if(nargout!=1)
        mexErrMsgIdAndTxt("Horizon:FastVar:output","One output required.");
    
    xIsDouble = mxIsDouble(varargin[0]);
    if (!xIsDouble && !mxIsSingle(varargin[0]))
        mexErrMsgIdAndTxt("Horizon:FastVar:input","Input x must be a single or double array.");
    
    if (xIsDouble)
    {
		if(mxIsComplex(varargin[0]))
		{
			mwSize	numElements = mxGetNumberOfElements(varargin[0]);
			double	meanR = 0;
			double	meanI = 0;
			double	var = 0;
			double	*xInR = mxGetPr(varargin[0]);
			double	*xInI = mxGetPi(varargin[0]);
			double	*xr = xInR;
			double	*xi = xInI;
			double	n = numElements;
		
			while (n-- > 0)
			{
				meanR += *xr++;
				meanI += *xi++;
			}
			meanR = meanR / (double) numElements;
			meanI = meanI / (double) numElements;
		
			xr = xInR;
			xi = xInI;
			n = numElements;
			while (n-- > 0)
			{
				double	r = fabs(*xr++ - meanR);
				double	i = fabs(*xi++ - meanI);
			
				var += r*r + i*i;
			}
			if (numElements > 1)
				var = var / (double) (numElements-1);
			else
				var = var / (double) numElements;
			
			varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
		
			*mxGetPr(varargout[0]) = var;
		}
		else
		{
			mwSize	numElements = mxGetNumberOfElements(varargin[0]);
			double	mean = 0;
			double	var = 0;
			double	*xIn = mxGetPr(varargin[0]);
			double	*x = xIn;
			double	n = numElements;
		
			while (n-- > 0)
				mean += *x++;
			mean = mean / (double) numElements;
		
			x = xIn;
			n = numElements;
			while (n-- > 0)
			{
				double	tempX = fabs(*x++ - mean);
				var += tempX*tempX;
			}
			if (numElements > 1)
				var = var / (double) (numElements-1);
			else
				var = var / (double) numElements;
			
			varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
		
			*mxGetPr(varargout[0]) = var;
		}
    }
    else
    {
		if(mxIsComplex(varargin[0]))
		{
			mwSize	numElements = mxGetNumberOfElements(varargin[0]);
			float	meanR = 0;
			float	meanI = 0;
			float	var = 0;
			float	*xInR = (float*) mxGetData(varargin[0]);
			float	*xInI = (float*) mxGetImagData(varargin[0]);
			float	*xr = xInR;
			float	*xi = xInI;
			float	n = numElements;
		
			while (n-- > 0)
			{
				meanR += *xr++;
				meanI += *xi++;
			}
			meanR = meanR / (float) numElements;
			meanI = meanI / (float) numElements;
		
			xr = xInR;
			xi = xInI;
			n = numElements;
			while (n-- > 0)
			{
				float	r = fabs(*xr++ - meanR);
				float	i = fabs(*xi++ - meanI);
			
				var += r*r + i*i;
			}
			if (numElements > 1)
				var = var / (float) (numElements-1);
			else
				var = var / (float) numElements;
			
			varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
		
			*(float*) mxGetData(varargout[0]) = var;
		}
		else
		{
			mwSize	numElements = mxGetNumberOfElements(varargin[0]);
			float	mean = 0;
			float	var = 0;
			float	*xIn = (float*) mxGetData(varargin[0]);
			float	*x = xIn;
			float	n = numElements;
		
			while (n-- > 0)
				mean += *x++;
			mean = mean / (float) numElements;
		
			x = xIn;
			n = numElements;
			while (n-- > 0)
			{
				float	tempX = fabs(*x++ - mean);
				var += tempX*tempX;
			}
			if (numElements > 1)
				var = var / (float) (numElements-1);
			else
				var = var / (float) numElements;
			
			varargout[0] = mxCreateNumericMatrix(1, 1, mxSINGLE_CLASS, mxREAL);
		
			*(float*) mxGetData(varargout[0]) = var;
		}
    }
}
