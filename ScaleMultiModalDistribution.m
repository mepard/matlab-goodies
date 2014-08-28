function x = ScaleMultiModalDistribution (x, scalePoints)
	numModes = length(scalePoints);
	pointsPerMode = floor(length(x)/numModes);
	numPoints = numModes * pointsPerMode;
	
	x_ = sort(x(1:numPoints));
	x_ = reshape(x_, pointsPerMode, numModes);
	xPoints = median(x_, 1);
	
	x = x - xPoints(1);
	x = x * (scalePoints(end) - scalePoints(1)) / (xPoints(end) - xPoints(1));
	x = x + scalePoints(1);
end

