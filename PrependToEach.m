function cellArrayOfStrings = PrependToEach (p, cellArrayOfStrings)
	cellArrayOfStrings = cellfun(@(s) ([p, s]), cellArrayOfStrings, 'UniformOutput', false);
end
