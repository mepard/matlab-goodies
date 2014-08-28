function cellArray = SplitStructArray (array, fieldNames)
	if isempty(array)
		cellArray = {};
		return
	end
	if iscell(array)
		cellArray = array;
	else
		cellArray = {array};
	end
	if isempty(fieldNames)
		return;
	end
	if ~iscell(fieldNames)
		fieldNames = {fieldNames};
	end

	oldNumElements = sum(cellfun(@length, cellArray));
	for f = 1:length(fieldNames)
		oldCellArray = cellArray;
		cellArray = {};
		for c = 1:length(oldCellArray)
			array = oldCellArray{c};
			
			remainingNames = fieldNames{f};
			fieldValues = arrayfun(@(e) e, array, 'UniformOutput', false);
			missingLevels = nan(size(array));
			
			level = 1;
			while ~isempty(remainingNames)
				[fieldName, remainingNames] = strtok(remainingNames, '.'); %#ok<STTOK>
				
				for e = 1:length(fieldValues)
					if ~isempty(fieldValues{e})
						if isfield(fieldValues{e}, fieldName)
							fieldValues{e} = fieldValues{e}.(fieldName);
						else
							fieldValues{e} = [];
							missingLevels(e) = level;
						end
					end
				end
				level = level + 1;
			end
			
			for level = unique(missingLevels)
				missing = missingLevels == level;
				cellArray = [cellArray, array(missing)];
				array(missing) = [];
				fieldValues(missing) = [];
			end
			
			uniqueValues = UniqueCells(fieldValues);
			for i = 1:length(uniqueValues)
				matchingValues = cellfun(@(v) isequaln(v, uniqueValues{i}), fieldValues);
				cellArray = [cellArray, array(matchingValues)];
			end
		end
	end
	newNumElements = sum(cellfun(@length, cellArray));
	assert(newNumElements == oldNumElements)
end
