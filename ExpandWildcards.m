function paths = ExpandWildcards (paths, options)
	if nargin < 2
		options = {};
	end
	if ischar(options)
		options = {options};
	end
	
	global globalDataDirectory
	
	if ~isempty(globalDataDirectory)
		previousFolder = cd (globalDataDirectory);
		restoreCurrentDirWhenDeleted = onCleanup(@() cd(previousFolder));	% Will fire on clear or (e.g. control-C).
	end
	
	requireExistance = any(strcmpi(options, 'exist')) || any(strcmpi(options, 'exists'));
	
	if ischar(paths)
		paths = {paths};
	end
	addPaths = {};
	removePaths = {};
	for i = 1:length(paths)
		pathName = paths{i};
		removeThisPath = pathName(1) == '!';
		if removeThisPath
			pathName(1) = [];
		end
		if (isempty(strfind(pathName, '*')))
			expansion = {pathName};
		else
			[path, leaf, extension] = fileparts(pathName);
			leaf = strcat(leaf, extension);
			if (isempty(strfind(path, '*')))
				expansion = {};
                if isempty(path) || isdir(path)
                    if ~isempty(path)
                        path = strcat(path, filesep);
                    end
                    list = dir(pathName);
                    for j = 1:length(list)
                        if (list(j).name(1) ~= '.')
                            expansion = [expansion; strcat(path, {list(j).name}')];
                        end
                    end
                end
			else
				expansion = ExpandWildcards({path});
				expansion = strcat(expansion, filesep, leaf);
				expansion = ExpandWildcards(expansion);
                
                % Remove expansions that don't exist.
                %
                fileExists = cellfun(@(f) exist(f, 'file') ~= 0, expansion);
                expansion(~fileExists) = [];
			end
		end
		if removeThisPath
			removePaths = [removePaths; expansion]; %#ok<*AGROW>
		else
			addPaths = [addPaths; expansion];
		end
    end
    if isempty(removePaths)
        paths = addPaths;
    else
        paths = addPaths(~any(StrCmpi2d(addPaths,removePaths), 2));
    end
    
	if requireExistance
		if isempty(paths)
			error('horizon:impulse:noFiles', 'There are no matching files')
		end
		fileExists = cellfun(@(f) exist(f, 'file') ~= 0, paths);
		if ~all(fileExists)
			error ('horizon:impulse:noFiles', 'Missing files: %s', ToString(paths(~fileExists).'))
		end
	end
end
