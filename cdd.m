function previousDirectory = cdd (directory)

	global globalDataDirectory

	if nargout > 0
		previousDirectory = globalDataDirectory;
	end
	
	globalDataDirectory = directory;
end
