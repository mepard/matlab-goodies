function range = iqr (x, dim)
	sz = size(x);
	if nargin < 2
		dim = find(sz > 1, 1, 'first');
		if isempty(dim)
			range = 0;
			return
		end
	end
	
	indices = arrayfun(@(s) 1:s, sz, 'UniformOutput', false);
	indices{dim} = round(size(x,dim)*[1 3]/4);

	x = sort(x, dim);
	x = x(indices{:});
	assert (size(x, dim) == 2)
	
	range = diff(x, 1, dim);
end

