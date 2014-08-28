function pathName_out = SaveFigure (figures, inDirectory, options)
	if nargin < 1 || isempty(figures)
		figures = get(0,'children');
		if ~isempty(figures)
			if isobject(figures(1))
				figureNums = get(figures, 'Number');
				figureNums = [figureNums{:}];
			else
				figureNums = figures;
			end
			[~, byFigureNum] = sort(figureNums);
			figures = figures(byFigureNum);
		end
	end
	if nargin < 2 || isempty(inDirectory)
		inDirectory = [pwd(), filesep, 'Figures'];
	end
	if nargin < 3
		options = {};
	end
	
	if isempty(figures)
		% Don't go creatin' directories with nothing to put in them.
		if nargout > 0
			pathName_out = {};
		end
		return
	end
	
	replaceOld = any(strcmpi(options, 'replace'));
	separateDirs = any(strcmpi(options, 'separateDirs'));
	
	fileTypes = options(~strcmpi(options, 'replace') & ~strcmpi(options, 'separateDirs'));
	if isempty(fileTypes)
		fileTypes = {'pdf'};
	end

	fileTypes(strcmpi(fileTypes, 'jpeg')) = {'jpg'};
	fileTypes = unique(fileTypes);
	
	supportedTypes = {'fig', 'pdf', 'png', 'jpg'};
	
	typeIsSupported = false(size(fileTypes));
	for o = 1:length(fileTypes)
		typeIsSupported(o) = any(strcmpi(fileTypes{o}, supportedTypes));
	end
	if ~all(typeIsSupported)
		error ('horizon:nomad:invalidOptions', 'Each of %s must be one of %s.',ToString(fileTypes(~typeIsSupported)), ToString(supportedTypes))
	end
	assert(any(typeIsSupported))
	
	logProgress = nargout == 0;
	
	if separateDirs
		inDirectories = cellfun(@(t) [inDirectory, filesep, upper(t)], fileTypes, 'uniformOutput', false);
		for t = 1:length(inDirectories)
			if ~exist(inDirectories{t}, 'dir')
				mkdir (inDirectories{t})
			end
		end
	else
		if ~exist(inDirectory, 'dir')
			mkdir (inDirectory)
		end
		inDirectories = repmat({inDirectory}, size(fileTypes));
	end
	
	pathNames = {};
	
	for fig = figures(:)'
		for t = 1:length(fileTypes)
			pathName = SaveFiguresAs(fig, fileTypes{t}, inDirectories{t}, replaceOld, logProgress);
			pathNames = [pathNames; pathName]; %#ok<AGROW>
		end
    end

    if nargout > 0
        if length(pathNames) == 1
            pathName_out = pathNames{1};
        else
            pathName_out = pathNames;
        end
    end
end

function pathName = SaveFiguresAs(fig, fileType, inDirectory, replaceOld, logProgress)
	saveFigFile = strcmpi(fileType, 'fig');
	savePdfFile = strcmpi(fileType, 'pdf');
	savePngFile = strcmpi(fileType, 'png');
	saveJpgFile = strcmpi(fileType, 'jpg');
	
	if saveFigFile
		extension = 'fig';
	elseif savePngFile
		extension = 'png';
		driver = '-dpng';
	elseif saveJpgFile
		extension = 'jpeg';
		driver = '-djpeg';
    elseif savePdfFile
		extension = 'pdf';
		driver = '-dpdf';
    else
        assert(false)
	end
	
	fileName = get (fig, 'Name');
	if strcmp(filesep, '\')		% Windows
		invalidCharacters = '<>:"/\|?*';
	else
		invalidCharacters = '/\*"';
	end
	badChars = false(size(fileName));
	for i = 1:length(fileName)
		badChars(i) = any(invalidCharacters == fileName(i));
	end
	fileName(badChars) = '_';
	if isempty(fileName)
		fileName = sprintf('Figure%d', fig);
	end
	
	pathName = sprintf('%s%s%s.%s', inDirectory, filesep, fileName, extension);
	instanceNum = 1;
	while exist(pathName, 'file')
		if replaceOld
			delete (pathName)
			break
		end
		instanceNum = instanceNum + 1;
		pathName = sprintf('%s%s%s(%d).%s', inDirectory, filesep, fileName, instanceNum, extension);
	end
	
	if logProgress
		fprintf (1, 'Saving %s\n', pathName);
	end
	
	figure(fig)

	if saveFigFile
		saveas (fig, pathName) 
	else
		% See http://www.mathworks.com/support/solutions/en/data/1-3TQNHK/?product=ML&solution=1-3TQNHK
		%
		paperPositionMode = get (fig, 'PaperPositionMode');
		set (fig, 'PaperPositionMode', 'auto')

		print (driver, pathName)

		set (fig, 'PaperPositionMode', paperPositionMode);
	end
end
