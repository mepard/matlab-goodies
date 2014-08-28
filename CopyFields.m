function s = CopyFields (s, otherStruct)
	if ~isempty(otherStruct)
		otherFields = fieldnames (otherStruct);
		for f = 1:length(otherFields)
			field = otherFields{f};
			if ~isfield(s, field)
				s.(field) = otherStruct.(field);
			end
		end
	end
end
