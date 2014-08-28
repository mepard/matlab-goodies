function dependancies = RequiredFilesAndProducts (pathNames)

	pathNames = ExpandWildcards(pathNames);
	
	dependancies = repmat(struct(), numel(pathNames), 1);
	for f = 1:numel(pathNames)
		[files, packages] = matlab.codetools.requiredFilesAndProducts (pathNames{f});
		dependancies(f).filePath = pathNames{f};
		dependancies(f).filesRequired = files;
		dependancies(f).packages = packages;
	end
end
