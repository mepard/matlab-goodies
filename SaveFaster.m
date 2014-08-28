function saved = SaveFaster (fileName, varargin)
	if any(~cellfun(@ischar, varargin))
		error ('horizon:impulse:invalidArg', 'Specify the names of the variables to save, not the variables themselves')
	end
	
	isFlag = cellfun(@(v) v(1) == '-', varargin);
	flags = varargin(isFlag);
	names = varargin(~isFlag);
	
	if isempty(names)
		names = evalin('caller', 'who');
	end
	
	values = cell(size(names));
	for v = 1:numel(values)	% Don't use cellfun here because cellfun will be the 'caller'
		values{v} = evalin('caller', [names{v},';']);
	end
	
	isFactored = false(size(values));
	for v = 1:numel(values)
		if isstruct(values{v}) && numel(values{v}) > 1
			%@@@ Could do better when many but not all elements have fields in commmon.
			[same, rest] = FactorStruct(values{v});
			if ~isempty(same)
				isFactored(v) = true;
				factoredStruct.same = same;
				factoredStruct.rest = rest;
				values{v} = factoredStruct;
			end
		end
	end
	
	if ~isempty(fileName)
		save (fileName, 'names', 'isFactored', 'values', flags{:});
	end
	
	if nargout > 0
		saved.names = names;
		saved.isFactored = isFactored;
		saved.values = values;
	end
end
