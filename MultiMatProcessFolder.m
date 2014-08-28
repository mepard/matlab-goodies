function pathToProcessFolder = MultiMatProcessFolder (functionName, processNum)
	if nargin < 2 || isempty(processNum)
		pathToProcessFolder = [functionName, filesep, 'Processes'];
	else
		pathToProcessFolder = [functionName, filesep, 'Processes', filesep, ToString(processNum)];
	end
end
