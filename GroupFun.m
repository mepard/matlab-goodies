function varargout = GroupFun (fn, structOrTable, groupFields, varargin)
	groups = GroupBy (structOrTable, groupFields);
	numGroups = numel(groups);
	
    numOutputs = nargout;
	outputs = cell(numGroups, nargout);
	extraInputs = varargin;
    
	for p = 1:numGroups
		groupOutput = cell(1,numOutputs);
		[groupOutput{:}] = fn (groups(p), extraInputs{:});  
		outputs(p,:) = groupOutput;
	end
	for o = 1:nargout
		varargout{o} = vertcat(outputs{:,o}); %#ok<AGROW>
	end
end
