function t = PrintStruct (s, name, options)
	if nargin < 2
		name = inputname(1);
	end
	if nargin < 3
		options = {};
	end
	
	sorted = any(strcmpi(options, 'sort'));
	asCellArray = any(strcmpi(options, 'cell'));
	
	if isempty(s)
		t = {sprintf('%s = [];', name)};
	elseif ~isstruct(s)
		t = {sprintf('%% %s is not a struct', name)};
	elseif numel(s) > 1
		t = {};
		for m = 1:size(s,1)
			for n = 1:size(s,2)
				t = [t, PrintStruct(s(m,n), sprintf('%s(%d,%d)', name, m, n), [options, 'cell'])];
			end
		end
	else
		fields = fieldnames (s);
		if sorted
			fields = sort(fields);
		end
		
		t = {};
		for f = 1:length(fields)
			fieldName = fields{f};
			qualifiedName = [name, '.', fieldName];
			fieldValue = s.(fieldName);
			if isstruct(fieldValue)
				t = [t, PrintStruct(fieldValue, qualifiedName, [options, 'cell'])];
			else
				t = [t, sprintf('%s = %s;', qualifiedName, ToString(fieldValue))];
			end
		end
	end
	if ~asCellArray
		t = cellfun(@(s) sprintf('%s\n', s), t, 'uniformOutput', false);
		t = [t{:}];
	end
end
