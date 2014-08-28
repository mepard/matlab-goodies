function [bins, targetBin, hzPerBin] = BinsForBandwidth (basebandFrequencies, targetFrequency, bandwidth)
	hzPerBin = unique(diff(basebandFrequencies));
	assert(length(hzPerBin) == 1)

	binsOnEachSide = ceil((bandwidth/2)/hzPerBin);
	
	[~, targetBin] = min(abs(basebandFrequencies - targetFrequency));
	
	bins = targetBin + (-binsOnEachSide:binsOnEachSide);

	frequencyError = targetFrequency - basebandFrequencies(targetBin);
	assert(abs(frequencyError) <= hzPerBin/2)
	if abs(frequencyError) > hzPerBin/4
		% The targetFrequency is close to the middle between frequencies, so add a bin on the end
		%
		if frequencyError > 0
			bins = [bins bins(end)+1];
		else
			bins = [bins(1) - 1 bins];
		end
	end
end
