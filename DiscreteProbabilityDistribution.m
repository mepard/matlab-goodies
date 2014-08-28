function [values, probabilities, cumulative] = DiscreteProbabilityDistribution (x, options)
	if nargin < 2
		options = {};
	end
	density = any(strcmpi(options, 'density'));
	
	x = sort(x(:));
	value_changed = find(diff(x) > 0);
	values = x([1;value_changed+1]);
	counts = diff([0;value_changed;length(x)]);
	if density
		probabilities = counts/trapz(values, counts);
	else
		probabilities = counts/sum(counts);
	end
	cumulative = cumsum(probabilities);
	cumulative(cumulative > 1) = 1;	% Removes off-by-eps values.
end
