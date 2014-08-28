function y = Percentile (x, p)
	x = sort(x);
	y = x(round(p*length(x)));
end

