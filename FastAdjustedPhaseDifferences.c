/*
	C implementation of:
	
	angles = FastAdjustedPhaseDifferences (rxAngles, adjustment, txAngles)
*/

#include "mex.h"

#define _USE_MATH_DEFINES		// For Windows
#include <math.h>

static bool IsScaler (const mxArray *arg)
{
    return mxIsDouble(arg)
		&& ~mxIsComplex(arg)
		&& mxGetNumberOfElements(arg)==1;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    if(nrhs!=3)
		mexErrMsgIdAndTxt("Horizon:FastAdjustAngles:input","FastAdjustAngles requires three inputs.");
    if(nlhs != 1)
		mexErrMsgIdAndTxt("Horizon:FastAdjustAngles:output","FastAdjustAngles requires one output.");

	if (mxIsComplex(prhs[0]))
        mexErrMsgIdAndTxt("Horizon:FastAdjustAngles:input","Input rxAngles must not be complex.");
	if (!IsScaler (prhs[1]))
        mexErrMsgIdAndTxt("Horizon:FastAdjustAngles:input","Input adjustment must be a scaler.");
	if (mxIsComplex(prhs[2]))
        mexErrMsgIdAndTxt("Horizon:FastAdjustAngles:input","Input txAngles must not be complex.");

	if (mxGetNumberOfElements(prhs[0]) != mxGetNumberOfElements(prhs[2]))
        mexErrMsgIdAndTxt("Horizon:FastAdjustAngles:input","Input rxAngles and txAngles must be the same length.");

   	plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
	{
 		int                 numAngles = mxGetNumberOfElements(prhs[0]);
		const double		*rxAngles = mxGetPr(prhs[0]);
		const double		adjustment = mxGetScalar(prhs[1]);
		const double		*txAngles = mxGetPr(prhs[2]);
		
    	double				totalPhaseDifferences = 0;

		while (numAngles-- > 0)
		{
			double	rxAngle = *rxAngles++ + adjustment;
			
			while (rxAngle > M_PI)
				rxAngle = rxAngle - 2*M_PI;
			while (rxAngle < -M_PI)
				rxAngle = rxAngle + 2*M_PI;
			
			totalPhaseDifferences += fabs(rxAngle - *txAngles++);
		}
		*mxGetPr(plhs[0]) = totalPhaseDifferences;
	}
}
