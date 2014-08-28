function s = AddField (s, name, values)
	if nargin == 2
		values = name;
		name = inputname(2);
	end
	if ~iscell(values)
		if numel(values) == numel(s)
			values = num2cell(values(:));
		elseif size(values,1) == numel(s)
			values = mat2cell(values, ones(size(values,1), 1));
		else
			error ('horizon:impulse:sizeMismatch', 'values must have the same number of elements as the structure or size(values,1) be the same as the number of elements as the structure.')
		end
	end
	[s(:).(name)] = values{:};
end
