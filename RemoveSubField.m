function s = RemoveSubField (s, fieldName, subFieldName)
	for e = 1:length(s)
		element = s(e).(fieldName);
		if isfield(element, subFieldName)
			element = rmfield(element, subFieldName);
			s(e).(fieldName) = element;
		end
	end
end
