/*
	C implementation of:
	
	function R = FastCorrelation (x, y, meanY);
	
	R needs to be divided by length(x) if compared to correlations of other lengths.
*/

#include "mex.h"

void mexFunction( int nargout, mxArray *varargout[],
                  int nargin, const mxArray *varargin[])
{
	mwSize	numElements;
	bool 	xIsDouble;
	bool	xIsComplex;
	
    if(nargin!=3)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","3 inputs required.");

    if(nargout!=1)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:output","One output required.");
    
    xIsDouble = mxIsDouble(varargin[0]);
    if (!xIsDouble && !mxIsSingle(varargin[0]))
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Input x must be array of singles or doubles.");
    
    if(mxIsDouble(varargin[1]) != xIsDouble)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Input y must be the same type (single or double) as input x.");
    
    xIsComplex = mxIsComplex(varargin[0]);
	if ((xIsComplex) != mxIsComplex(varargin[1])
	  | (xIsComplex) != mxIsComplex(varargin[2]))
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","All inputs must be complex or all real.");

    if(mxGetM(varargin[0]) != mxGetM(varargin[1]) || mxGetN(varargin[0]) != mxGetN(varargin[1]) )
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Inputs x and y must have the same size.");
    
    if (mxGetNumberOfElements(varargin[2]) != 1 || mxIsDouble(varargin[2]) != xIsDouble)
        mexErrMsgIdAndTxt("Horizon:MultiplyAndAdd:input","Input meanY same type (single or double) as input y.");
 
    numElements = mxGetNumberOfElements(varargin[0]);
    
    if (xIsDouble)
    {
		if (xIsComplex)
		{
			double	*xr = mxGetPr(varargin[0]);
			double	*xi = mxGetPi(varargin[0]);
			double	*yr = mxGetPr(varargin[1]);
			double	*yi = mxGetPi(varargin[1]);
			double	sumOfProductsReal = 0;
			double	sumOfProductsImag = 0;
			double	sumOfXreal = 0;
			double	sumOfXimag = 0;

			while (numElements-- > 0)
			{
				double xReal = *xr++;
				double xImag = *xi++;
			
				sumOfXreal += xReal;
				sumOfXimag += xImag;
				sumOfProductsReal += xReal * *yr++;
				sumOfProductsImag += xImag * *yi++;
			}

			varargout[0] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
		
			*mxGetPr(varargout[0]) = sumOfProductsReal - sumOfXreal * *mxGetPr(varargin[2]);
			*mxGetPi(varargout[0]) = sumOfProductsImag - sumOfXimag * *mxGetPi(varargin[2]);
		}
		else
		{
			double	*x = mxGetPr(varargin[0]);
			double	*y = mxGetPr(varargin[1]);
			double	sumOfProducts = 0;
			double	sumOfX = 0;
		
			while (numElements-- > 0)
			{
				double xTemp = *x++;
				sumOfX += xTemp;
				sumOfProducts += xTemp * *y++;
			}

			varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
		
			*mxGetPr(varargout[0]) = sumOfProducts - sumOfX * *mxGetPr(varargin[2]);
		}
    }
    else
    {
		if (xIsComplex)
		{
			float	*xr = (float*) mxGetData(varargin[0]);
			float	*xi = (float*) mxGetImagData(varargin[0]);
			float	*yr = (float*) mxGetData(varargin[1]);
			float	*yi = (float*) mxGetImagData(varargin[1]);
			float	sumOfProductsReal = 0;
			float	sumOfProductsImag = 0;
			float	sumOfXreal = 0;
			float	sumOfXimag = 0;

			while (numElements-- > 0)
			{
				float xReal = *xr++;
				float xImag = *xi++;
			
				sumOfXreal += xReal;
				sumOfXimag += xImag;
				sumOfProductsReal += xReal * *yr++;
				sumOfProductsImag += xImag * *yi++;
			}

			varargout[0] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
		
			*(float*) mxGetData(varargout[0]) = sumOfProductsReal - sumOfXreal * *(float*) mxGetData(varargin[2]);
			*(float*) mxGetImagData(varargout[0]) = sumOfProductsImag - sumOfXimag * *(float*) mxGetImagData(varargin[2]);
		}
		else
		{
			float	*x = (float*) mxGetData(varargin[0]);
			float	*y = (float*) mxGetData(varargin[1]);
			float	sumOfProducts = 0;
			float	sumOfX = 0;
		
			while (numElements-- > 0)
			{
				float xTemp = *x++;
				sumOfX += xTemp;
				sumOfProducts += xTemp * *y++;
			}

			varargout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
		
			*mxGetPr(varargout[0]) = sumOfProducts - sumOfX * *mxGetPr(varargin[2]);
		}
    }
}
