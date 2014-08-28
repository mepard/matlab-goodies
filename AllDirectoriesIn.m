function directories = AllDirectoriesIn (pathToTopDir)
    directory = dir(fullfile(pathToTopDir, '*'));
    
    directories = {};
    directory = directory([directory.isdir]);
    for d = 1:numel(directory)
    	if directory(d).name(1) == '.'
    		continue	% . .. or invisible
    	end
    	
    	path = fullfile(pathToTopDir, directory(d).name);
    	directories = [directories; path]; %#ok<AGROW>
    	subdirectories = AllDirectoriesIn (path);
    	directories = [directories; subdirectories]; %#ok<AGROW>
    end
end


