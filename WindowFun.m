function y = WindowFun (x, fn, windowLength)
	y = nan(size(x));
	for p = 1:min([windowLength, numel(x)])
		y(p) = fn(x(1:p));
	end
	for p = windowLength+1:numel(x)
		y(p) = fn(x(p-windowLength+1:p));
    end
end
