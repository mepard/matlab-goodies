function originalStruct = UnfactorStruct (commonFields, differingFields)
	originalStruct = differingFields;
	if ~isempty(commonFields)
		commonFields = repmat(commonFields, size(differingFields));
		fieldNames = fieldnames(commonFields);
		for f = 1:numel(fieldNames)
			[originalStruct.(fieldNames{f})] = commonFields.(fieldNames{f});
		end
	end
end
