function xlists = DivvyUp (x, numLists)
	numInEachList = repmat(floor(length(x)/numLists), 1, numLists);
	numLeft = length(x) - sum(numInEachList);
	numInEachList(1:numLeft) = numInEachList(1:numLeft)+1;
	
	xlists = cell(1, numLists);
	for p = 1:numLists
		s = sum(numInEachList(1:p-1));
		xlists{p} = x(s + (1:numInEachList(p)));
	end
end
