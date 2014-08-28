function result = R2 (fn, varargin)
	% Good for functions such as max and min that return the index as the 2nd result.
	
	[~, result] = fn(varargin{:});
end
