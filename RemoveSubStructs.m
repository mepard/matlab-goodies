function s = RemoveSubStructs (s, fieldName)
	for e = 1:length(s)
		element = s(e).(fieldName);
		removedAny = false;
		subFields = fieldnames (element);
		for f = 1:length(subFields)
			subField = subFields{f};
			if isstruct(element.(subField))
				element = rmfield(element, subField);
				removedAny = true;
			end
		end
		if removedAny
			s(e).(fieldName) = element;
		end
	end
end

