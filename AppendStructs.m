function s = AppendStructs (s, s2)
	if ~isempty(s2)
		if isempty(s)
			s = s2;
        else
			s = AddMissingFields (s, s2);
			s2 = AddMissingFields (s2, s);
            if iscolumn(s)
                s = [s; s2(:)];
            else
                s = [s, s2(:).'];
            end
		end
	end
end

function s = AddMissingFields (s, otherStruct)
	otherFields = fieldnames (otherStruct);
	for f = 1:length(otherFields)
		field = otherFields{f};
		if ~isfield(s, field)
            fieldValue = otherStruct(1).(field);
			if isstruct(fieldValue)
				value = repmat(fieldValue, 0, 0);
			elseif ischar(fieldValue)
				value = '';
			elseif iscell(fieldValue)
				value = {};
			elseif islogical(fieldValue)
				value = false;
			else
				value = nan(size(fieldValue));
			end
			s = AddConstantField (s, field, value);
		end
	end
end
