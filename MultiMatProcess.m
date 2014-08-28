function MultiMatProcess (processNum, options, workingDirectory, functionName, varargin)

	% Called from separate MATLAB instance

	startTic = tic;
	
	quiet = any(strcmpi(options, {'quiet'}));
	
	try
		debugging = any(strcmpi(options, 'debug'));
		noQuit = any(strcmpi(options, 'noQuit'));
		
		cd (workingDirectory)
		
		pathToProcessFolder = MultiMatProcessFolder (functionName, processNum);
		
		diary([pathToProcessFolder, filesep, 'diary.txt'])

		if ~quiet
			disp([functionName, '(', ToString(varargin{:}, processNum), ')'])
		end
		
		results = feval(functionName, varargin{:}, processNum); %#ok<NASGU>
		
		save ([pathToProcessFolder, filesep, 'results.mat'], 'results')
		clear results
	catch err
		fprintf (2, 'Error %s at %s\n', err.message, ToString(err.stack));
	end

	pathToRunningIndicator = [pathToProcessFolder, 'running'];
	if exist(pathToRunningIndicator, 'file')
		delete (pathToRunningIndicator)		% Tell MultiMat we're finished
	end
	if ~quiet
		fprintf (1, 'Process %d: Elapsed time %s.\n', processNum, TimeIntervalString(toc(startTic)));
	end
	diary off
	if ~debugging && ~noQuit
		quit
	end
end
