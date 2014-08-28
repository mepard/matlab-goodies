function m = StrCmpi2d (cellArrayOfStrings1, cellArrayOfStrings2)
	if ~iscell(cellArrayOfStrings1)
		cellArrayOfStrings1 = {cellArrayOfStrings1};
	end
	if ~iscell(cellArrayOfStrings2)
		cellArrayOfStrings2 = {cellArrayOfStrings2};
	end
	
	m = false(length(cellArrayOfStrings1), length(cellArrayOfStrings2));
	for i = 1:length(cellArrayOfStrings1)
		m(i,:) = strcmpi(cellArrayOfStrings1{i}, cellArrayOfStrings2);
	end
end
