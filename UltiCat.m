function [out, dim] = UltiCat (varargin)
	% The ultimate concatenation function.
	% Always concatenates along the last dimension plus 1.
	%
	% Particularly useful for expressions that return comma-separate lists like struct and cell arrays.
	%
	% out = UltiCat (structArray.field);
	% out = UltiCat (cellArray{:});
	%
	if isempty(varargin)
		out = [];
		dim = 0;
		return
	end
	
	firstElement = varargin{1};		% All must be same shape or cat will fail.
	if isscalar(firstElement) || isrow(firstElement)
		dim = 1;
	elseif iscolumn(firstElement)
		dim = 2;
	else
		dim = ndims(firstElement) + 1;
	end
	out = cat (dim, varargin{:});
end
