function [averages, standardDeviations] = Average (averageFn, varargin)
	% Returns average (e.g. median or mean) of all the values passed in.
	% The result will be the same shape as the elements passed in.
	%
	% Particularly useful for expressions that return comma-separate lists like struct and cell arrays.
	%
	% averages = Average (@mean, structArray.field);
	% averages = Average (@mean, cellArray{:});
	%	
	[values, dim] = UltiCat (varargin{:});
	averages = averageFn (values, dim);
	
	if nargout > 1
		standardDeviations = std (values, 0, dim);
	end
end
