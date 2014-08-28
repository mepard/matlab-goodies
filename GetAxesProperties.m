function values = GetAxesProperties (axisList, property)
	if length(axisList) > 1
		values = cell2mat(get(axisList, property));
	else
		values = get(axisList, property);
	end
end
