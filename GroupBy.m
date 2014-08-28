function groups = GroupBy (structArray, fieldNames)
    if istable(structArray)
        structArray = table2struct(structArray);
    end
    
	if isempty(fieldNames)
		groups.name = '';
		groups.members = 1:numel(structArray);
		groups.fields = struct ([]);
    else
        if ~iscell(fieldNames)
            fieldNames = {fieldNames};
        end
		numFields = numel(fieldNames);
		numElements = numel(structArray);
		fieldValues = cell(size(fieldNames));
		for f = 1:numFields
			fieldName = fieldNames{f};
			if isfield(structArray,fieldName)
				values = {structArray.(fieldName)};
                if any(~cellfun(@ischar, values))
                    values = [structArray.(fieldName)];
                end
			else
				values = repmat({''}, 1, numElements);
            end                
			fieldValues{f} = values;
		end
		
		uniqueFieldValues = cellfun(@unique, fieldValues, 'uniformOutput', false);
		numUniqueValues = cellfun(@numel, uniqueFieldValues);
		
		numGroups = prod(numUniqueValues);
		groups = repmat (struct('name', '', 'members', [], 'fields', struct([])), numGroups, 1);
		
		fieldIndices = ones(1, numFields);
		for g = 1:numGroups
			groupName = '';
			hasFieldValueForGroup = false(numElements, numFields);
			fields = struct();
			for f = 1:numFields
				uniqueValues = uniqueFieldValues{f};
                if iscell(uniqueValues)
					fieldValue = uniqueValues{fieldIndices(f)};
					groupName = sprintf ('%s %s', groupName, fieldValue);
					hasFieldValueForGroup(:,f) = strcmp(fieldValues{f}, fieldValue);
                else
					fieldValue = uniqueValues(fieldIndices(f));
					groupName = sprintf ('%s %s %g', groupName, fieldNames{f}, fieldValue);
					hasFieldValueForGroup(:,f) = fieldValues{f} == fieldValue;
                end
				fields.(fieldNames{f}) = fieldValue;
			end
			groups(g).name = strtrim(groupName);
			groups(g).members = find(all(hasFieldValueForGroup,2));
			groups(g).fields = fields;
			
			fieldIndices = Increment (fieldIndices, numUniqueValues);
		end
		assert (all(fieldIndices == 1))	% Wrapped around

		emptyGroups = cellfun(@isempty, {groups.members});
		groups(emptyGroups) = [];
	end
end

function fieldIndices = Increment (fieldIndices, maxValues)
	for f = numel(fieldIndices):-1:1
		fieldIndices(f) = fieldIndices(f) + 1;
		if fieldIndices(f) <= maxValues(f)
			break;
		end
		fieldIndices(f) = 1;
	end
end

