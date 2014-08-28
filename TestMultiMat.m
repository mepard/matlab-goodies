function results = TestMultiMat (numProcesses, options, echoArgs, processNum)

	if nargin < 4
		processNum = [];
	end
	
	if isempty(processNum)
		results = MultiMat (numProcesses, mfilename, [], options, numProcesses, options, echoArgs);
		return
	end

	fprintf (1, 'Process %d: %s\n', processNum, ToString(echoArgs));
	
	results = echoArgs;
end
