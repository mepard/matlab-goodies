function s = FlattenStruct (s, fieldName, prefix)
	if nargin < 3 || isempty(prefix)
		prefix = fieldName;
	end
	
	for i = 1:length(s)
		structToFlatten = s(i).(fieldName);
		if isstruct(structToFlatten)
			subFields = fieldnames(structToFlatten);
			for f = 1:length(subFields)
				subField = subFields{f};
				s(i).([prefix, '_', subField]) = structToFlatten.(subField);
			end
		end
	end
end
