function results = MultiMat (numProcesses, functionName, diaryName, options, varargin)

	startTic = tic;

	if isempty(diaryName)
		diaryName = datestr(now,30);
	end
	
	quiet = any(strcmpi(options, {'quiet'}));
	testing = any(strcmpi(options, 'test'));
	useParallelComputingToolbox = any(strcmpi(options, 'pct'));
	
	pathToProcessesFolder = MultiMatProcessFolder (functionName);
	if exist(pathToProcessesFolder, 'dir')
		rmdir (pathToProcessesFolder, 's')
	end
	[status, message, id] = mkdir (pathToProcessesFolder);
	if status
		error (id, 'mkdir(%s): %s', pathToProcessesFolder, message);
	end

	diary([functionName, filesep, diaryName, '.txt'])
	if ~quiet
		disp([functionName, '(', ToString(varargin{:}), ')'])
	end
	
	args = SplitArguments (numProcesses, varargin{:});
	numProcesses = size(args, 1);
	
	pathsToProcessFolders = cell(numProcesses, 1);
	for p = 1:numProcesses
		pathsToProcessFolders{p} = MultiMatProcessFolder(functionName, p);
		mkdir (pathsToProcessFolders{p})
	end
	
	if numProcesses == 1 && ~testing && ~useParallelComputingToolbox
		results = feval(functionName, args{:}, 1);
		if ~quiet
			fprintf (1, 'All processes finished: Elapsed time %s.\n', TimeIntervalString(toc(startTic)));
		end
		diary off
		return
	end
	
	matlabCommands = cell(numProcesses, 1);
	for p = 1:numProcesses
		matlabCommands{p} = sprintf('MultiMatProcess(%d, %s, ''%s'', ''%s'', %s)', p, ToString(options), pwd(), functionName, ToString(args{p,:}));
	end
	
	if ~useParallelComputingToolbox
		if testing
			for p = 1:numProcesses
				eval(matlabCommands{p});
			end
			results = GatherResults (pathToProcessesFolder, matlabCommands);
			if ~quiet
				fprintf (1, 'All processes finished: Elapsed time %s.\n', TimeIntervalString(toc(startTic)));
			end
			diary off
			return
		end
	
		if isunix
			matlab = '~/MATLAB/R2011b/bin/matlab -nodisplay -nosplash -r';
	
			[~, output] = unix([matlab, ' quit']);
			lengthOfSpewage = length(output);
			
			shellCommands = cell(size(matlabCommands));
			for p = 1:numProcesses
				shellCommands{p} = sprintf('%s "%s" | tail -c +%d &\n', matlab, matlabCommands{p}, lengthOfSpewage);
			end
			
			shellCommands = [shellCommands, {'wait'}];
			
			status = unix([shellCommands{:}], '-echo');
			if status
				diary off
				error ('horizon:impulse:unixFailed', 'unix command failed with error %s', status)
			end
	
			results = GatherResults (pathToProcessesFolder, matlabCommands);
			if ~quiet
				fprintf (1, 'All processes finished: Elapsed time %s.\n', TimeIntervalString(toc(startTic)));
			end
			diary off
			% Don't need to GatherDiaries because the main diary already contains the merged
			% output of all the processes. Unix FTW.
			return
		end
		
		if ispc
			pathsToRunningIndicators = cell(numProcesses, 1);
			for p = 1:numProcesses
				pathsToRunningIndicators{p} = [pathsToProcessFolders{p}, 'running'];
				fclose(fopen(pathsToRunningIndicators{p} , 'w'));	% Deleted in MultiMatProcess when finished
			
				dosCommand = sprintf('start matlab -nodesktop -nosplash -r "%s"', matlabCommands{p});
				
				status = dos(dosCommand, '-echo');
				if status
					diary off
					error ('horizon:impulse:dosFailed', 'dos command %s failed with error %s', dosCommand, status)
				end
			end
			while true
				pause(1)
				allDone = true;
				for p = 1:numProcesses
					if exist(pathsToRunningIndicators{p} , 'file')
						allDone = false;
						break
					end
				end
				if allDone
					break
				end
			end
			%@@@ Could use the Parallel Computing Toolbox's facilities for gathering results and diaries.
			results = GatherResults (pathToProcessesFolder, matlabCommands);
			if ~quiet
				fprintf (1, 'All processes finished: Elapsed time %s.\n', TimeIntervalString(toc(startTic)));
			end
			diary off
			GatherDiaries (functionName, pathToProcessesFolder, diaryName);
			return
		end
	end
	
	% See if we have the Parallel Computing Toolbox
	%
	v = ver;
	hasParallelComputingToolbox = any(strcmpi({v.Name},'Parallel Computing Toolbox'));

	if ~hasParallelComputingToolbox
		diary off
		error ('horizon:impulse:noMultiMat', 'MultiMat has not been implemented on this platform')
	end

	sched = findResource('scheduler', 'type', 'local');
	jobs = cell(size(matlabCommands));
	for p = 1:numProcesses
		jobs{p} = batch(sched, @MultiMatProcess, 0, {p, [options, 'noQuit'], pwd(), functionName, args{p,:}});
	end
	for p = 1:numProcesses
		wait(jobs{p});
		% diary(jobs{p})		% Print the diary
		destroy(jobs{p})
	end
	results = GatherResults (pathToProcessesFolder, matlabCommands);	%@@@ get from jobs?
	if ~quiet
		fprintf (1, 'All processes finished: Elapsed time %s.\n', TimeIntervalString(toc(startTic)));
	end
	diary off
	GatherDiaries (functionName, pathToProcessesFolder, diaryName);
end

function args = SplitArguments (numProcesses, varargin)
	argLengths = cellfun(@length, varargin);
	splitableArgs = find(argLengths > 1 & cellfun(@(arg) isa(arg, 'numeric'), varargin));
	
	if isempty(splitableArgs)
		numProcesses = 1;
		longestArg = 0;
	else
		[argLength, longestArg] = max(argLengths(splitableArgs));
		longestArg = splitableArgs(longestArg);
		numProcesses = min(numProcesses, argLength);
		if (numProcesses) > 1
			argValueLists = DivvyUp (varargin{longestArg}, numProcesses);
		else
			numProcesses = 1;
			longestArg = 0;
		end
	end

	args = repmat(varargin, numProcesses, 1);
	for p = 1:numProcesses
		for a = 1:length(varargin)
			if a == longestArg
				args{p,a} = argValueLists{p};
			end
		end
	end
end

function results = GatherResults (pathToProcessesFolder, commands)

	pathToResults = [pathToProcessesFolder, filesep, '*', filesep, 'results.mat'];

	paths = ExpandWildcards ({pathToResults});
	
	results = [];
	for p = 1:length(paths)
		if exist(paths{p}, 'file')
			s = load(paths{p});
			if isstruct(s.results)
				results = AppendStructs (results, s.results);
			else
				results = [results, s.results];
			end
		else
			if nargin > 1 && ~isempty(commands)
				fprintf (2, 'WARNING:  Process %d did not finish. Command: %s\n', p, commands{p});
			else
				fprintf (2, 'WARNING:  Process %d did not finish.\n', p);
			end
		end
	end
end

function GatherDiaries (functionName, pathToProcessesFolder, diaryName)
	% On Windows and/or with the Parallel Computing Toolbox, there is a diary for
	% each process. Combine them.
	%
	pathToDiaries = [pathToProcessesFolder, filesep, '*', filesep, 'diary.txt'];

	paths = ExpandWildcards ({pathToDiaries});
	
	mainDiary = [functionName, filesep, diaryName, '.txt'];
	
	copyCommand = ['COPY "', mainDiary, '" /A'];
	for p = 1:length(paths)
		if exist(paths{p}, 'file')
			copyCommand = [copyCommand, ' + "', paths{p}, '" /A'];
		end
	end
	copyCommand = [copyCommand, ' "', mainDiary, '" /A'];
	
	for i = 1:5
		[status, output] = dos(copyCommand);	% Occasionally fails because the files are busy for some reason.
		if ~status
			return
		end
		pause(.5)
	end
	warning ('horizon:impulse:dosCopyFailed', 'dos command %s failed with error %d, output: %s', copyCommand, status, output)
end
