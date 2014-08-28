function [commonFields, differingFields] = FactorStruct (originalStruct)
	if isempty(originalStruct)
		commonFields = [];
		differingFields = [];
	elseif ~isstruct(originalStruct)
		error ('horizon:impulse:invalidArg', 'FactorStruct only makes sense on scructs\n');
	elseif numel(originalStruct) == 1
		commonFields = originalStruct;
		differingFields = [];
	else
		originalShape = size(originalStruct);
		originalStruct = originalStruct(:);

		commonFields = [];
		differingFields = originalStruct;		% Will remove fields that have constant values.
		
		fields = fieldnames(originalStruct);
		for f = 1:length(fields)
			fieldName = fields{f};
			
			if all(isequaln(originalStruct.(fieldName)))
				commonFields.(fieldName) = originalStruct(1).(fieldName);
				differingFields = rmfield(differingFields, fieldName);
			end
		end
		
		differingFields = reshape(differingFields, originalShape);
	end
end
