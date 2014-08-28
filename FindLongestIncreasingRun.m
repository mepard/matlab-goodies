function [startOfRun, endOfRun] = FindLongestIncreasingRun (x)

	if isempty(x)
		startOfRun = 0;
		endOfRun = 0;
		return
	end
	increasing = [true, diff(x) > 0];
	runLengths = ones(size(x));
	for i = 1:length(runLengths)
		nextBreak = find(~increasing(i+1:end), 1, 'first');
		if isempty(nextBreak)
			runLengths(i) = length(x) - i + 1;
			break
		else
			runLengths(i) = nextBreak;
		end
	end
	[~, startOfRun] = max(runLengths);
	endOfRun = startOfRun + runLengths(startOfRun) - 1;

	assert(all(diff(x(startOfRun:endOfRun)) > 0))
	assert(startOfRun == 1 || x(startOfRun) <= x(startOfRun-1))
	assert(endOfRun == length(x) || x(endOfRun) >= x(endOfRun+1))
end