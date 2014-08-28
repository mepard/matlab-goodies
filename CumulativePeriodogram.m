function [p, f] = CumulativePeriodogram (x, window, samplesPerSecond, removeDC)

	p = [];
	f = [];

	numPoints = length(window);
	numInstances = floor(length(x) / numPoints);
	if numInstances > 0
		x = x(1:numPoints*numInstances);
		x = reshape (x, numPoints, numInstances);
	
		for i = 1:numInstances
			x_ = x(:,i);
			if removeDC
				x_ = x_ - mean(x_);
			end
			if isempty(p)
				[p, f] = periodogram(x_, window, [], samplesPerSecond);
			else
				p = p + periodogram(x_, window, [], samplesPerSecond);
			end
		end
		p = p / numInstances;
	end
end

