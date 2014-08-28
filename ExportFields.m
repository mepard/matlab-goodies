function ExportFields (someStruct)
	if numel(someStruct) ~= 1
		error ('horizon:impulse:invalidArgument', 'Exported struct array must have exactly one element')
	end
	
	fieldNames = fieldnames(someStruct);
	for f = 1:numel(fieldNames)	% Don't use cellfun because cellfun becomes the 'caller'
		assignin('caller', fieldNames{f}, someStruct.(fieldNames{f}))
	end
end
