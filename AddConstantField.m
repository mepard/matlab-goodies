function s = AddConstantField (s, name, value)
	if ~isempty(s)
		values = repmat({value}, size(s));
		[s.(name)] = values{:};
	end
end

